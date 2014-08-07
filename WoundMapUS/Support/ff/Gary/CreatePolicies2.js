var print = print;
var require = require;
var exports = exports;

var fs = require('fs'); // CommonJS file-system module
var ff = require('ffef/FatFractal'); // FatFractal server-side SDK

function createUserIfRequired(userName) {
    var user = ff.getObjFromUri("/FFUser/" + userName);
    if (!user) {
        user = ff.registerUser(
            {
                guid: userName,
                firstName: "Lone",
                lastName: "User",
                email: userName + "@example.com",
                userName: userName
            },
            "Password1",
            true,
            false);
    }
    return user;
}
exports.createTestData = function() {
    if (ff.getActiveUser().guid !== 'system')
        throw {statusCode:403, statusMessage:'Forbidden'};

    var userName = 'loneUser';
    var loneUser = createUserIfRequired(userName);

    userName = 'teamUser';
    var teamUser = createUserIfRequired(userName);

    var team = ff.getObjFromUri("/WMTeam/TestTeam");
    if (!team) {
        team = ff.createObjAtUri({clazz:'WMTeam',guid:'TestTeam',name:'Test Team'}, "/WMTeam", teamUser.guid);
    }

    ff.response().result = {
        loneUser:loneUser,
        teamUser:teamUser,
        team:team
    };
};

exports.deleteTestData = function() {
    if (ff.getActiveUser().guid !== 'system')
        throw {statusCode:403, statusMessage:'Forbidden'};

    ff.deleteAllForQuery("/WMNavigationNode/(createdBy eq 'loneUser' or createdBy eq 'teamUser')");
    ff.deleteAllForQuery("/WMNavigationStage/(createdBy eq 'loneUser' or createdBy eq 'teamUser')");
    ff.deleteAllForQuery("/WMNavigationTrack/(createdBy eq 'loneUser' or createdBy eq 'teamUser')");
    ff.deleteAllForQuery("/WMTeam/(createdBy eq 'loneUser' or createdBy eq 'teamUser')");
    ff.deleteAllForQuery("/FFUser/(guid eq 'loneUser' or guid eq 'teamUser')");
};

function setFlags(o, flagNames) {
    var flags = 0;
    // check the booleans, adjust the flags
    for (var propName in o) {
        {
            var index = flagNames.indexOf(propName);
            if (index >= 0 && o[propName]) {
                flags |= (0x01 << index);
            }
        }
    }
    this['flags'] = flags;
}

/**
 * @param o
 * @param teamUrl
 * @constructor
 */
function WMNavigationTrack(o, teamUrl) {
    var ignore = ['stages', 'ignoresStagesFlag', 'ignoresSignInFlag', 'limitToSinglePatientFlag', 'skipCarePlanFlag', 'skipPolicyEditor'];
    this.clazz = 'WMNavigationTrack';
    var flags = 0;
    for (var propName in o) {
        var index = ignore.indexOf(propName);
        if (index < 0) { // not in the ignore list, add this property
            this[propName] = o[propName];
        }
    }

    var flagNames = ['ignoresStagesFlag', 'ignoresSignInFlag', 'limitToSinglePatientFlag', 'skipCarePlanFlag', 'skipPolicyEditor'];
    setFlags.call(this, o, flagNames);

    if (teamUrl) {
        ff.addReferenceToObj(teamUrl, 'team', this);
    }
}

/**
 *
 * @param o
 * @param trackUrl
 * @constructor
 */
function WMNavigationStage(o, trackUrl) {
    var ignore = ['nodes','activeFlag'];
    this.clazz = 'WMNavigationStage';
    for (var propName in o) {
        if (ignore.indexOf(propName) < 0) { // not in the ignore list, add this property
            this[propName] = o[propName];
        }
    }
    ff.addReferenceToObj(trackUrl, 'track', this);
}

/**
 *
 * @param o
 * @param stageUrl
 * @param parentNodeUrl
 * @constructor
 */
function WMNavigationNode(o, stageUrl, parentNodeUrl) {
    var ignore = ['subnodes','requiredFlag','hidesStatusIndicator','numberHoursBeforeClose'];
    this.clazz = 'WMNavigationNode';
    for (var propName in o) {
        var index = ignore.indexOf(propName);
        if (index < 0) { // not in the ignore list, add this property
            this[propName] = o[propName];
        }
    }

    var flagNames = ['requiredFlag','hidesStatusIndicator'];
    setFlags.call(this, o, flagNames);

    if (stageUrl) {
        ff.addReferenceToObj(stageUrl, 'stage', this);
    }
    if (parentNodeUrl) {
        ff.addReferenceToObj(parentNodeUrl, 'parentNode', this);
    }
}

exports.createPolicies = function() {
    var request = ff.getExtensionRequestData();

    if (request.httpContent) { // Try the request body first
        var teamUrl = request.httpContent['teamUrl'];
        var userGuid = request.httpContent['userGuid'];
    } else { // Try the httpParameters
        teamUrl = request.httpParameters['teamUrl'];
        userGuid = request.httpParameters['userGuid'];
    }

    var team;
    var userGuidForDataStoreOperations;

    var paramsErrorMessage = 'Either teamUrl or userGuid should be supplied, but not both';
    if (userGuid && teamUrl) {
        throw {statusCode:400, statusMessage:paramsErrorMessage};
    }

    if (teamUrl) {
        // Verify that the team exists
        team = ff.getObjFromUri(teamUrl);
        if (!team) {
            throw {statusCode:404, statusMessage:'Could not find team with teamUrl "' + teamUrl + '"'};
        }

        // Verify that the active user created this team, or active user is system
        if (ff.getActiveUser().guid !== "system" && ff.getActiveUser().guid !== team.createdBy) {
            throw {statusCode:403, statusMessage:'You do not have permission to modify data for this team'};
        }

        userGuidForDataStoreOperations = team.createdBy;
    } else {
        // Require the user guid in the parameters
        if (!userGuid) {
            throw {statusCode:400, statusMessage: paramsErrorMessage};
        }

        // Verify that the active user's guid matches (or is system)
        if (ff.getActiveUser().guid !== userGuid && ff.getActiveUser().guid !== 'system' ) {
            throw {statusCode:403, statusMessage:'Logged-in user mis-match with userGuid'};
        }

        userGuidForDataStoreOperations = userGuid;
    }

    // TODO Check at every level if the track / stage / node / subnode object already exists
    // TODO in case data has only been partially created by a previous execution
    // For now, however, we'll check for a track and if it's there we'll assume we're good
    var existingTracks;

    if (userGuid) {
        // Acting as lone user - check for tracks created by this user where the 'team' reference is null
        existingTracks = ff.getArrayFromUri(
                "/WMNavigationTrack/(createdBy eq '" + userGuidForDataStoreOperations + "')" +
                "/self/(team.guid eq null)"
        );
    } else {
        // Acting as team owner - check for tracks created by this user where the 'team' reference is NOT null
        existingTracks = ff.getArrayFromUri(
                "/WMNavigationTrack/(createdBy eq '" + userGuidForDataStoreOperations + "')" +
                "/self/(team.guid eq '" + team.guid + "')"
        );
    }
    if (existingTracks.length !== 0) {
        throw {statusCode:409, statusMessage:'Data already exists'};
    }

    //noinspection JSUnresolvedFunction
    var xml = fs.read(fs.workingDirectory() + '/WEB-INF/classes/resources/NavigationPolicies.plist');

    var json = ff.xml2json(xml);

    var jsObj = JSON.parse(json);

    // print (JSON.stringify(jsObj, null, 2));

    // Iterate over the raw tracks data, create the tracks in the data store
    var rawTracksData = jsObj['plist']['array'];
    var createdTracks = [];
    for (var trackNum = 0; trackNum < rawTracksData.length; trackNum++) {
        // create the track
        var track = new WMNavigationTrack(rawTracksData[trackNum], teamUrl);
        track = ff.createObjAtUri(track, "/WMNavigationTrack", userGuidForDataStoreOperations);
        createdTracks.push(track);

        // If this is a team, add the track to the team's 'navigationTracks' grabbag
        if (team) {
            ff.grabBagAdd(track.ffUrl, team.ffUrl, 'navigationTracks', userGuidForDataStoreOperations);
        }

        // Iterate over the stages for this track
        var rawStagesData = rawTracksData[trackNum]['stages'];
        for (var stageNum = 0; stageNum < rawStagesData.length; stageNum++) {
            // Create the stage
            var stage = new WMNavigationStage(rawStagesData[stageNum], track.ffUrl);
            stage = ff.createObjAtUri(stage, "/WMNavigationStage", userGuidForDataStoreOperations);

            // Add the stage to the track's 'stages' grabbag
            ff.grabBagAdd(stage.ffUrl, track.ffUrl, 'stages', userGuidForDataStoreOperations);

            // Iterate over the nodes for this stage
            var rawNodesData = rawStagesData[stageNum]['nodes'];
            for (var nodeNum = 0; nodeNum < rawNodesData.length; nodeNum++) {
                // Create tne node
                var node = new WMNavigationNode(rawNodesData[nodeNum], stage.ffUrl, null);
                node = ff.createObjAtUri(node, "/WMNavigationNode", userGuidForDataStoreOperations);

                // Add the node to the stage's 'nodes' grabbag
                ff.grabBagAdd(node.ffUrl, stage.ffUrl, 'nodes', userGuidForDataStoreOperations);

                // Add sub-nodes (this is recursive)
                addNavigationSubNodes (track, stage, node, rawNodesData[nodeNum]['subnodes'], userGuidForDataStoreOperations);
            }
        }
    }

    var depthResponse = ff.executeDepthQuery(createdTracks, 6, 6, userGuidForDataStoreOperations);

    // Return results to the client in one big response
    ff.response().wrap = false;
    ff.response().result = {
        statusMessage:'Created policies successfully',
        result:createdTracks,
        references:depthResponse.references,
        grabBagItems:depthResponse.grabBagItems
    }
};

function addNavigationSubNodes(track, stage, node, rawSubNodeData, userGuidForDataStoreOperations) {
    if (rawSubNodeData && rawSubNodeData.length) {
        for (var subNodeNum = 0; subNodeNum < rawSubNodeData.length; subNodeNum++) {
            var subNode = new WMNavigationNode(rawSubNodeData[subNodeNum], stage.ffUrl, node.ffUrl);
            subNode = ff.createObjAtUri(subNode, "/WMNavigationNode", userGuidForDataStoreOperations);

            // Add the subNode to the parent node's 'subNodes' grabbag
            ff.grabBagAdd(subNode.ffUrl, node.ffUrl, 'subnodes', userGuidForDataStoreOperations);

            // Add sub-nodes (this is recursive)
            addNavigationSubNodes (track, stage, subNode, rawSubNodeData[subNodeNum]['subnodes'], userGuidForDataStoreOperations);
        }
    }
}
