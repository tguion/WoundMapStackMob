var print = print;
var require = require;
var exports = exports;

var ff = require('ffef/FatFractal'); // FatFractal server-side SDK

//CREATE HANDLER notifyReferreeOfReferral_create POST ON /WMPatientReferral CREATE AS \
//  javascript:require('scripts/Notifications').notifyReferreeOfReferral_create();
/**
 * This event handler fires when an object is created in the /WMPatientReferral collection.
 * It notifies the referree (the person to whom the patient has been referred)
 */
exports.notifyReferreeOfReferral_create = function() {
    var referral = ff.getEventHandlerData();
    var userToNotify = ff.getObjFromUri(referral.ffUrl + '/referree/()/user');
    if (!userToNotify) {
        ff.logger.forceWarn ("Notifications.notifyReferreeOfReferral: Could not navigate to FFUser record of the referree of this referral");
        return;
    }
    var patient = ff.getObjFromUri(referral.ffUrl + '/patient');
    if (!patient) {
        ff.logger.forceWarn ("This referral's patient is null ...");
        return;
    }
    ff.sendPushNotifications(
        [userToNotify.guid],
        {
            ios: {
                aps: {
                    alert: "A patient has been referred to you"
                },
                patientGuid: patient.guid
            }
        },
        false);
};

//CREATE HANDLER notifyReferreeOfReferral_update POST ON /WMPatientReferral UPDATE AS \
//  javascript:require('scripts/Notifications').notifyReferreeOfReferral_update();
/**
 * This event handler fires when an object is created in the /WMPatientReferral collection.
 * It notifies the referree (the person to whom the patient has been referred)
 */
exports.notifyReferreeOfReferral_update = function() {
    var preUpdate = ff.getUpdateEventHandlerData()['old'];
    var postUpdate = ff.getUpdateEventHandlerData()['new'];

    if (preUpdate.referree !== postUpdate.referree) {
		var userToNotify = ff.getObjFromUri(postUpdate.ffUrl + '/referree/()/user');
		if (!userToNotify) {
			ff.logger.forceWarn ("Notifications.notifyReferreeOfReferral: Could not navigate to FFUser record of the referree of this referral");
			return;
		}
		var patient = ff.getObjFromUri(postUpdate.ffUrl + '/patient');
		if (!patient) {
			ff.logger.forceWarn ("This referral's patient is null ...");
			return;
		}
		ff.sendPushNotifications(
			[userToNotify.guid],
			{
				ios: {
					aps: {
						alert: "A patient has been referred to you"
					},
					patientGuid: patient.guid
				}
			},
			false);
    }
};

//CREATE HANDLER notifyInvitedToTeam POST ON /WMTeamInvitation CREATE AS \
// javascript:require('scripts/Notifications').notifyInvitedToTeam();
/**
 * This event handler fires when an object is created in the /WMTeamInvitation collection.
 * It notifies the invitee that they have been invited to join a team.
 */
exports.notifyInvitedToTeam = function() {
    var invitation = ff.getEventHandlerData();
    var userToNotify = ff.getObjFromUri(invitation.ffUrl + '/invitee/()/user');
    if (!userToNotify) {
        ff.logger.forceWarn ("Notifications.notifyInvitedToTeam: Could not navigate to FFUser record of the invitee of this invitation");
        return;
    }
    ff.sendPushNotifications(
        [userToNotify.guid],
        {
            ios: {
                aps: {
                    alert: "You have been invited to join a team"
                },
                invitationGuid: invitation.guid
            }
        },
        false);
};

//CREATE HANDLER notifyInvitationAccepted POST ON /WMTeamInvitation UPDATE AS \
// javascript:require('scripts/Notifications').notifyInvitationAccepted();
/**
 * This event handler fires when an object in /WMTeamInvitation has its acceptedFlag updated to true.
 * It notifies the team leader that an invitation has been accepted
 */
exports.notifyInvitationAccepted = function() {
    var preUpdate = ff.getUpdateEventHandlerData()['old'];
    var postUpdate = ff.getUpdateEventHandlerData()['new'];

    if (preUpdate.acceptedFlag !== postUpdate.acceptedFlag && postUpdate.acceptedFlag === true) {
        // Todd: My assumption is that the invitation was createdBy the team leader
        var userGuidToNotify = preUpdate.createdBy;
        ff.sendPushNotifications(
            [userGuidToNotify],
            {
                ios: {
                    aps: {
                        alert: preUpdate.inviteeUserName + " has accepted your invitation"
                    },
                    invitationGuid: preUpdate.guid
                }
            },
            false);
    }
};

//CREATE HANDLER notifyAddedToTeam POST ON /WMTeam GRABBAG_ADD AS \
// javascript:require('scripts/Notifications').notifyAddedToTeam();
/**
 * This event handler fires when any grabbag in a /WMTeam object has something added to it.
 * We specifically are only interested here in when a member is added to a team - i.e. the 'participants' grabbag
 */
exports.notifyAddedToTeam = function() {
    var gbEvent = ff.getEventHandlerData();
    var team = gbEvent.parentObj;

    // we're only caring about the participants grab bag
    if (gbEvent.grabBagName == 'participants') {
        var addedParticipant = gbEvent.itemObj;
        var userToNotify = ff.getObjFromUri(addedParticipant.ffUrl + '/user');
        if (!userToNotify) {
            ff.logger.forceWarn ("Notifications.notifyAddedToTeam: Could not navigate to user of the participant added to the team");
            return;
        }
        ff.sendPushNotifications(
            [userToNotify.guid],
            {
                ios: {
                    aps: {
                        alert: "You have been added to a team"
                    },
                    teamGuid: team.guid
                }
            },
            false);
    }
};
