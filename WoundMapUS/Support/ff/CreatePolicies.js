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
 * @param teamUrl
 * @constructor
 */
function WMNavigationNode(o, stageUrl, parentNodeUrl, teamUrl) {
    var ignore = ['subnodes','requiredFlag','hidesStatusIndicator','numberHoursBeforeClose'];
    this.clazz = 'WMNavigationNode';
    for (var propName in o) {
        var index = ignore.indexOf(propName);
        if (index < 0) { // not in the ignore list, add this property
            this[propName] = o[propName];
        }
    }
    // mark as added to team
    if (teamUrl) {
    	this['teamFlag'] = true;
    } else {
    	this['teamFlag'] = false;
    }

    var flagNames = ['requiredFlag','hidesStatusIndicator'];
    setFlags.call(this, o, flagNames);

    if (stageUrl) {
        ff.addReferenceToObj(stageUrl, 'stage', this);
    }
    if (parentNodeUrl) {
        ff.addReferenceToObj(parentNodeUrl, 'parentNode', this);
    }
    if (teamUrl) {
        ff.addReferenceToObj(teamUrl, 'team', this);
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
        throw {statusCode: 400, statusMessage: paramsErrorMessage};
    }

    if (teamUrl) {
        // Verify that the team exists
        team = ff.getObjFromUri(teamUrl);
        if (!team) {
            throw {statusCode: 404, statusMessage: 'Could not find team with teamUrl "' + teamUrl + '"'};
        }

        // Verify that the active user created this team, or active user is system
        if (ff.getActiveUser().guid !== "system" && ff.getActiveUser().guid !== team.createdBy) {
            throw {statusCode: 403, statusMessage: 'You do not have permission to modify data for this team'};
        }

        userGuidForDataStoreOperations = team.createdBy;
    } else {
        // Require the user guid in the parameters
        if (!userGuid) {
            throw {statusCode: 400, statusMessage: paramsErrorMessage};
        }

        // Verify that the active user's guid matches (or is system)
        if (ff.getActiveUser().guid !== userGuid && ff.getActiveUser().guid !== 'system') {
            throw {statusCode: 403, statusMessage: 'Logged-in user mis-match with userGuid'};
        }

        userGuidForDataStoreOperations = userGuid;
    }

    //noinspection JSUnresolvedFunction
    var xml = fs.read(fs.workingDirectory() + '/WEB-INF/classes/resources/NavigationPolicies.plist');

    var json = ff.xml2json(xml);

    var jsObj = JSON.parse(json);

    // print (JSON.stringify(jsObj, null, 2));

    // Iterate over the raw tracks data from the PList, create the tracks in the data store
    var rawTracksData = jsObj['plist']['array'];
    var allPolicyObjects = [];
    for (var trackNum = 0; trackNum < rawTracksData.length; trackNum++) {
        // If the track with given title doesn't exist, then create it
        var track = ff.getObjFromUri("/WMNavigationTrack/" +
            "(createdBy eq '" + userGuidForDataStoreOperations + "'" +
            " and title eq '" + rawTracksData[trackNum]['title'] + "'" +
            ")" +
            "/self/(team.guid eq " + (team ? ("'" + team.guid + "'") : "null") + ")");
        if (! track) {
            track = new WMNavigationTrack(rawTracksData[trackNum], teamUrl);
            track = ff.createObjAtUri(track, "/WMNavigationTrack", userGuidForDataStoreOperations);
        }
        allPolicyObjects.push(track);
        // If this is a team, add the track to the team's 'navigationTracks' grabbag (if it's not already there)
        if (team) {
            if (!ff.getObjFromUri(team.ffUrl + "/navigationTracks/(guid eq '" + track.guid + "')")) {
                ff.grabBagAdd(track.ffUrl, team.ffUrl, 'navigationTracks', userGuidForDataStoreOperations);
            }
        }

        // Iterate over the stages for this track
        var rawStagesData = rawTracksData[trackNum]['stages'];
        for (var stageNum = 0; stageNum < rawStagesData.length; stageNum++) {
            // If the stage with given title, within this track, doesn't exist, then create it
            var stage = ff.getObjFromUri("/WMNavigationTrack/" +
                track.guid +
                "/stages" +
                "/(title eq '" + rawStagesData[stageNum]['title'] + "')");
            if (!stage) {
                stage = new WMNavigationStage(rawStagesData[stageNum], track.ffUrl);
                stage = ff.createObjAtUri(stage, "/WMNavigationStage", userGuidForDataStoreOperations);
            }
            // Add the stage to the track's 'stages' grabbag (if it's not already there)
            if (!ff.getObjFromUri(track.ffUrl + "/stages/(guid eq '" + stage.guid + "')")) {
                ff.grabBagAdd(stage.ffUrl, track.ffUrl, 'stages', userGuidForDataStoreOperations);
            }

            // Iterate over the nodes for this stage
            var rawNodesData = rawStagesData[stageNum]['nodes'];
            for (var nodeNum = 0; nodeNum < rawNodesData.length; nodeNum++) {
                // If the node with given title, within this stage, doesn't exist, then create it
                var node = ff.getObjFromUri("/WMNavigationStage/" +
                    stage.guid +
                    "/nodes" +
                    "/(title eq '" + rawNodesData[nodeNum]['title'] + "')");
                if (!node) {
                    node = new WMNavigationNode(rawNodesData[nodeNum], stage.ffUrl, null, teamUrl);
                    node = ff.createObjAtUri(node, "/WMNavigationNode", userGuidForDataStoreOperations);
                }
                // Add the node to the stage's 'nodes' grabbag (if it's not already there)
                if (!ff.getObjFromUri(stage.ffUrl + "/nodes/(guid eq '" + node.guid + "')")) {
                    ff.grabBagAdd(node.ffUrl, stage.ffUrl, 'nodes', userGuidForDataStoreOperations);
                }

                // Add sub-nodes (this is recursive)
                addNavigationSubNodes(track, stage, node, rawNodesData[nodeNum]['subnodes'], userGuidForDataStoreOperations, teamUrl);
            }
        }
    }

    //
    // TODO: Todd: You need to set these flags as I don't have the code which defines them
    //
    var kSelectPatientNode = 10;
    var kEditPatientNode = 20;
    var kAddPatientNode = 30;
    var kSelectWoundNode = 40;
    var kEditWoundNode = 50;
    var kAddWoundNode = 60;

    // Create the other Patient and Wound nodes
    var otherNodeData = [
        //
        // Patient nodes
        //
        {activeFlag:true,desc:"Select patient from patient list",disabledFlag:false,displayTitle:"Select Patient",icon:"patient_select",
        patientFlag:true,sortRank:1,taskIdentifier:kSelectPatientNode,title:"Select",woundFlag:false,hidesStatusIndicator:false}
        ,
        {activeFlag:true,desc:"Edit current patient",disabledFlag:false,displayTitle:"Edit Patient",icon:"patient_edit",
        patientFlag:true,sortRank:2,taskIdentifier:kEditPatientNode,title:"Edit",woundFlag:false,hidesStatusIndicator:true}
        ,
        {activeFlag:true,desc:"Add a new patient",disabledFlag:false,displayTitle:"Add Patient",icon:"patient_add",
        patientFlag:true,sortRank:0,taskIdentifier:kAddPatientNode,title:"Add",woundFlag:false,hidesStatusIndicator:true}
        //
        // Wound nodes
        //
        ,
        {activeFlag:true,desc:"Select wound from identified wounds",disabledFlag:false,displayTitle:"Select Wound",icon:"wound_select",
        patientFlag:false,sortRank:1,taskIdentifier:kSelectWoundNode,title:"Select",woundFlag:true,hidesStatusIndicator:true}
        ,
        {activeFlag:true,desc:"Edit current wound",disabledFlag:false,displayTitle:"Edit Wound",icon:"wound_edit",
        patientFlag:false,sortRank:2,taskIdentifier:kEditWoundNode,title:"Edit",woundFlag:true,hidesStatusIndicator:true}
        ,
        {activeFlag:true,desc:"Add a new wound",disabledFlag:false,displayTitle:"Add Wound",icon:"wound_add",
        patientFlag:false,sortRank:0,taskIdentifier:kAddWoundNode,title:"Add",woundFlag:true,hidesStatusIndicator:true}
    ];

    for (var otherNodeNum = 0; otherNodeNum < otherNodeData.length; otherNodeNum++) {
        // If the node with given displayTitle doesn't exist, then create it
        // For these nodes, they don't exist within a stage, so we check for stage.guid eq null
        // However we are still checking for team.guid, which will be set for the 'team' policies
        var otherNode = ff.getObjFromUri("/WMNavigationNode/" +
            "(createdBy eq '" + userGuidForDataStoreOperations + "'" +
            " and displayTitle eq '" + otherNodeData[otherNodeNum]['displayTitle'] + "'" +
            ")" +
            "/self" +
            "/(stage.guid eq null and team.guid eq " + (team ? ("'" + team.guid + "'") : "null") + ")");
        if (!otherNode) {
            otherNode = new WMNavigationNode(
                otherNodeData[otherNodeNum],
                null,
                null,
                teamUrl
            );
            otherNode = ff.createObjAtUri(otherNode, "/WMNavigationNode", userGuidForDataStoreOperations);
        }
        allPolicyObjects.push(otherNode);
    }


    // Get all of the references and grabBagItems in one go
    var depthResponse = ff.executeDepthQuery(allPolicyObjects, 6, 6, userGuidForDataStoreOperations);

    // Return results to the client in one big response
    ff.response().wrap = false;
    ff.response().result = {
        statusMessage: 'Created policies successfully from PList',
        result: allPolicyObjects,
        references: depthResponse.references,
        grabBagItems: depthResponse.grabBagItems
    }
};

function addNavigationSubNodes(track, stage, node, rawSubNodeData, userGuidForDataStoreOperations, teamUrl) {
    if (rawSubNodeData && rawSubNodeData.length) {
        for (var subNodeNum = 0; subNodeNum < rawSubNodeData.length; subNodeNum++) {
            // If the sub-node with given title, within this node, doesn't exist, then create it
            var subNode = ff.getObjFromUri("/WMNavigationNode/" +
                node.guid +
                "/subnodes" +
                "/(title eq '" + rawSubNodeData[subNodeNum]['title'] + "')");
            if (!subNode) {
                subNode = new WMNavigationNode(rawSubNodeData[subNodeNum], stage.ffUrl, node.ffUrl, teamUrl);
                subNode = ff.createObjAtUri(subNode, "/WMNavigationNode", userGuidForDataStoreOperations);
            }
            // Add the subNode to the parent node's 'subNodes' grabbag (if it's not already there)
            if (!ff.getObjFromUri(node.ffUrl + "/subnodes/(guid eq '" + subNode.guid + "')")) {
                ff.grabBagAdd(subNode.ffUrl, node.ffUrl, 'subnodes', userGuidForDataStoreOperations);
            }

            // Add sub-nodes (this is recursive)
            addNavigationSubNodes (track, stage, subNode, rawSubNodeData[subNodeNum]['subnodes'], userGuidForDataStoreOperations, teamUrl);
        }
    }
}
