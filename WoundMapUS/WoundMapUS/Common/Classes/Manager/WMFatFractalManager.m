//
//  WMFatFractalManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractalManager.h"
#import "WMNavigationTrack.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMOrganization.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "WMAddress.h"
#import "WMTelecom.h"
#import "WMPatient.h"
#import "WMBradenScale.h"
#import "WMBradenSection.h"
#import "WMBradenCell.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanValue.h"
#import "WMDeviceGroup.h"
#import "WMDeviceValue.h"
#import "WMDeviceInterventionEvent.h"
#import "WMId.h"
#import "WMMedicationGroup.h"
#import "WMMedication.h"
#import "WMPatientConsultant.h"
#import "WMPsychoSocialGroup.h"
#import "WMPsychoSocialValue.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentValue.h"
#import "WMNavigationStage.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMWoundPositionValue.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentValue.h"
#import "WMCarePlanInterventionEvent.h"
#import "WMInterventionEvent.h"
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMFatFractalManager ()

@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;      // map of objectID or collection to refresh times

@property (strong, nonatomic) NSMutableSet *updatedObjectIDs;       // collected when parent context did save
@property (strong, nonatomic) NSMutableSet *deletedObjectIDs;       // collected when parent context did save

@end

@implementation WMFatFractalManager

+ (WMFatFractalManager *)sharedInstance
{
    static WMFatFractalManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMFatFractalManager alloc] init];
    });
    return SharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _updatedObjectIDs = [[NSMutableSet alloc] init];
    _deletedObjectIDs = [[NSMutableSet alloc] init];
    
    __weak __typeof(&*self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:[NSManagedObjectContext MR_rootSavingContext]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [weakSelf handleDefaultManagedObjectContextDidSave:notification];
                                                  }];
    
    return self;
}

- (void)handleDefaultManagedObjectContextDidSave:(NSNotification *)notification
{
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    [_updatedObjectIDs addObjectsFromArray:[[updatedObjects allObjects] valueForKeyPath:@"objectID"]];
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    [_deletedObjectIDs addObjectsFromArray:[[deletedObjects allObjects] valueForKeyPath:@"objectID"]];
}

#pragma mark - FFQueueDelegate

- (void)queuedOperationCompleted:(FFQueuedOperation *)queuedOperation
{
    WM_ASSERT_MAIN_THREAD;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - Sign In

- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Enter", nil];
    [prompt setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [prompt show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSError *error = nil;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff loginWithUserName:[[alertView textFieldAtIndex:0] text]
              andPassword:[[alertView textFieldAtIndex:1] text] error:&error];
    if (error) {
        [self showLoginWithTitle:@"Sign In Failed - please try again" andMessage:[error localizedDescription]];
    }
}

#pragma mark - Updates and Deletes

- (void)processUpdatesAndDeletes
{
    NSArray *updatedObjectIDs = [_updatedObjectIDs allObjects];
    [_updatedObjectIDs removeAllObjects];
    NSArray *deletedObjectIDs = [_deletedObjectIDs allObjects];
    [_deletedObjectIDs removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WMFatFractal *ff = [WMFatFractal instance];
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSError *error = nil;
        for (NSManagedObjectID *objectID in updatedObjectIDs) {
            NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
            BOOL canUpdate = [[managedObject valueForKey:@"ffUrl"] length] > 0;
            if (canUpdate) {
                [ff updateObj:managedObject error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
        }
        for (NSManagedObjectID *objectID in deletedObjectIDs) {
            NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
            BOOL canDelete = [[managedObject valueForKey:@"ffUrl"] length] > 0;
            if (canDelete) {
                [ff deleteObj:managedObject error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
        }
    });
}

#pragma mark - Fetch

- (void)updateParticipant:(WMParticipant *)participant completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@/?depthGb=1&depthRef=1",[WMParticipant entityName], [participant.ffUrl lastPathComponent]];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        NSAssert(nil != object && [object isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", object);
        if (error && completionHandler) {
            completionHandler(error);
        } else {
            // make sure we fetch the ALIAS defined on WMParticipant - I'm not sure we have to do this since depthGb=1 in fetch above
            // NOTE: we could also fetch as so: see bottom of http://fatfractal.com/docs/data-modeling/#grab-bags
            // NSString *query = [NSString stringWithFormat:@"/%@/%@/%@", [WMParticipant entityName], [participant.ffUrl lastPathComponent], WMParticipantRelationships.patients];
            // NSArray *participantPatients = [ff getArrayFromUri:query error:&error];
            [self acquireGrabBagsForObjects:@[object] aliases:[WMParticipant relationshipNamesNotToSerialize] ff:ff completionHandler:^(NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
            }];
            // update team
            WMTeam *team = participant.team;
            if (team) {
                NSParameterAssert(team.ffUrl);
                NSString *queryString = [NSString stringWithFormat:@"/%@/%@/?depthGb=1&depthRef=1",[WMTeam entityName], [team.ffUrl lastPathComponent]];
                [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    WM_ASSERT_MAIN_THREAD;
                    NSAssert(nil != object && [object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
                    [self acquireGrabBagsForObjects:@[object] aliases:[WMTeam relationshipNamesNotToSerialize] ff:ff completionHandler:^(NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                    }];
                }];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            if (completionHandler) {
                completionHandler(error);
            }
        }
    }];
    self.lastRefreshTimeMap[[participant objectID]] = [FFUtils unixTimeStampFromDate:[NSDate date]];
}

- (void)acquireParticipantForUser:(FFUser *)user completionHandler:(WMObjectCallback)completionHandler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@/?depthGb=1&depthRef=1",[WMParticipant entityName], user.guid];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        NSAssert(nil != object && [object isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", object);
        if (completionHandler) {
            completionHandler(error, object);
        }
        [self acquireGrabBagsForObjects:@[object] aliases:[WMParticipant relationshipNamesNotToSerialize] ff:ff completionHandler:^(NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            }
        }];
    }];
}

- (void)updateTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler
{
    NSParameterAssert(team.ffUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
        NSString *queryString = [NSString stringWithFormat:@"/%@/%@/?depthGb=1&depthRef=1",[WMTeam entityName], [team.ffUrl lastPathComponent]];
        [ff getObjFromUri:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            NSAssert(nil != object && [object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
            [managedObjectContext saveToPersistentStoreAndWait];
            if (completionHandler) {
                completionHandler(error, object);
            }
            [self acquireGrabBagsForObjects:@[object] aliases:[WMTeam relationshipNamesNotToSerialize] ff:ff completionHandler:^(NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
            }];
        }];
    });
    self.lastRefreshTimeMap[[team objectID]] = [FFUtils unixTimeStampFromDate:[NSDate date]];
}

- (void)acquireGrabBagsForObjects:(NSArray *)objects aliases:(NSSet *)aliases ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    WM_ASSERT_MAIN_THREAD;
    id object = [objects firstObject];
    if (nil == object) {
        return;
    }
    // else
    for (object in objects) {
        for (NSString *alias in aliases) {
            [ff grabBagGetAllForObj:object
                        grabBagName:alias
                         onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                             WM_ASSERT_MAIN_THREAD;
                             completionHandler(error);
                         }];
        }
    }
}

- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    WM_ASSERT_MAIN_THREAD;
    NSParameterAssert(completionHandler);
    // Fetch any events that have been updated on the backend
    // Guide to query language is here: http://fatfractal.com/prod/docs/queries/
    // and full syntax reference here: http://fatfractal.com/prod/docs/reference/#query-language
    // Note use of the "depthGb" parameter - see here: http://fatfractal.com/prod/docs/queries/#retrieving-related-objects-inline
    NSString *collection = [WMPatient entityName];
    id lastRefreshTime = self.lastRefreshTimeMap[collection];
    if (nil == lastRefreshTime) {
        lastRefreshTime = @(0);
    }
    NSString *queryString = [NSString stringWithFormat:@"/%@/(updatedAt gt %@)?depthGb=1&depthRef=1", collection, lastRefreshTime];
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        if (response.error) {
            completionHandler(response.error);
        } else {
            [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                completionHandler(error);
            }];
        }
    }];
}

- (void)fetchCollection:(NSString *)collection
                  query:(NSString *)query
                depthGb:(NSInteger)depthGb
               depthRef:(NSInteger)depthRef
                     ff:(WMFatFractal *)ff
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
      completionHandler:(FFHttpMethodCompletion)completionHandler
{
    NSString *queryString = nil;
    id lastRefreshTime = self.lastRefreshTimeMap[collection];
    if (nil == lastRefreshTime) {
        lastRefreshTime = @(0);
    }
    if (query) {
        queryString = [NSString stringWithFormat:@"/%@/(updatedAt gt %@ and %@)?depthGb=%ld&depthRef=%ld", collection, lastRefreshTime, query, (long)depthGb, (long)depthRef];
    } else {
        queryString = [NSString stringWithFormat:@"/%@/(updatedAt gt %@)?depthGb=%ld&depthRef=%ld", collection, lastRefreshTime, (long)depthGb, (long)depthRef];
    }
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        if (response.error) {
            [WMUtilities logError:response.error];
            completionHandler(response.error, response.objs, response.httpResponse);
        } else {
            [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
                completionHandler(response.error, response.objs, response.httpResponse);
            }];
        }
    }];
}

#pragma mark - Backend Updates

// create participant after successful FFUser registration
- (void)createParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    WM_ASSERT_MAIN_THREAD;
    NSParameterAssert(completionHandler);
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    [ff createObj:participant atUri:[NSString stringWithFormat:@"/%@", [WMParticipant entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            completionHandler(error);
        }];
    }];

}

- (void)updateParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    WM_ASSERT_MAIN_THREAD;
    NSParameterAssert(completionHandler);
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    WMOrganization *organization = participant.organization;
    if (organization) {
        [ff createObj:organization atUri:[NSString stringWithFormat:@"/%@", [WMOrganization entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                completionHandler(error);
            } else {
                for (WMAddress *address in organization.addresses) {
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:nil];
                }
                for (WMId *anId in organization.ids) {
                    [ff createObj:anId atUri:[NSString stringWithFormat:@"/%@", [WMId entityName]] onComplete:nil];
                }
            }
        }];
    }
    WMPerson *person = participant.person;
    [ff createObj:person atUri:[NSString stringWithFormat:@"/%@", [WMPerson entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        for (WMAddress *address in person.addresses) {
            [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:nil];
        }
        for (WMTelecom *telecom in person.telecoms) {
            [ff createObj:telecom atUri:[NSString stringWithFormat:@"/%@", [WMTelecom entityName]] onComplete:nil];
        }
        [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                completionHandler(error);
            }];
        }];
    }];
}

- (void)createTeamWithParticipant:(WMParticipant *)participant user:(id<FFUserProtocol>)user ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
{
    WM_ASSERT_MAIN_THREAD;
    NSParameterAssert(completionHandler);
    NSParameterAssert([participant.ffUrl length] > 0);
    NSParameterAssert(participant.isTeamLeader);
    NSParameterAssert(completionHandler);
    NSParameterAssert(participant.team);
    WMTeam *team = participant.team;
    NSParameterAssert(team);
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    FFUserGroup *participantGroup = team.participantGroup;
    // create FFUserGroup that will hold the FFUser instance in team
    [ff createObj:participantGroup atUri:@"/FFUserGroup" onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            completionHandler(error);
        } else {
            NSAssert([object isKindOfClass:[FFUserGroup class]], @"Expected FFUserGroup but got %@", object);
            // create team
            [ff createObj:team atUri:[NSString stringWithFormat:@"/%@", [WMTeam entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    completionHandler(error);
                } else {
                    NSAssert([object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
                    // add participant (user) to FFUserGroup
                    [team.participantGroup addUser:user error:&error];
                    if (error) {
                        completionHandler(error);
                    } else {
                        // update participant
                        [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                completionHandler(error);
                            } else {
                                // add invitations
                                for (WMTeamInvitation *invitation in team.invitations) {
                                    [ff queueCreateObj:invitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]]];
                                }
                                // seed team with navigation track, stage, node
                                [WMNavigationTrack seedDatabaseForTeam:team completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                                    // update backend
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
                                        for (NSManagedObjectID *objectID in objectIDs) {
                                            NSManagedObject *object = [managedObjectContext objectWithID:objectID];
                                            NSLog(@"*** WoundMap: Will create collection backend: %@", object);
                                            [ff queueCreateObj:object atUri:ffUrl];
                                        }
                                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                                    });
                                }];
                                [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                                    completionHandler(error);
                                }];
                            }
                        }];

                    }
                }
            }];
        }
    }];
}

- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([teamInvitation.ffUrl length] == 0);
    NSParameterAssert(nil != teamInvitation.team);
    NSParameterAssert([teamInvitation.team.ffUrl length] > 0);
    NSParameterAssert(nil != teamInvitation.invitee);
    NSParameterAssert([teamInvitation.invitee.ffUrl length] > 0);
    [ff createObj:teamInvitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        NSAssert([object isKindOfClass:[WMTeamInvitation class]], @"Expected WMTeamInvitation but got %@", object);
        [[teamInvitation managedObjectContext] MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)revokeTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    NSParameterAssert([teamInvitation.ffUrl length]);
    [ff deleteObj:teamInvitation onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        completionHandler(error);
    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
        completionHandler(error);
    }];
}

- (void)addParticipantToTeamFromTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    NSManagedObjectContext *managedObjectContext = [teamInvitation managedObjectContext];
    NSParameterAssert([teamInvitation.ffUrl length]);
    WMParticipant *invitee = teamInvitation.invitee;
    FFUser *user = teamInvitation.invitee.user;
    BOOL canUpdateInvitee = (nil != user);
    if (nil == user) {
        NSParameterAssert(invitee.guid);
        NSString *ffUrl = [NSString stringWithFormat:@"/FFUser/%@", invitee.guid];
        user = [ff getObjFromUri:ffUrl];
    }
    NSParameterAssert([user isKindOfClass:[FFUser class]]);
    if (canUpdateInvitee) {
        // only invitee (WMParticipant) can do this
        invitee.team = teamInvitation.team;
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [ff updateObj:invitee onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(error);
        }];
    } else {
        // only team leader can do this
        FFUserGroup *participantGroup = teamInvitation.team.participantGroup;
        NSParameterAssert(participantGroup);
        NSError *error = nil;
        [participantGroup addUser:user error:&error];
    }
}

- (void)removeParticipantFromTeam:(WMParticipant *)teamMember ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    NSParameterAssert([teamMember.ffUrl length]);
    FFUser *user = teamMember.user;
    NSParameterAssert(user);
    FFUserGroup *participantGroup = teamMember.team.participantGroup;
    NSParameterAssert(participantGroup);
    NSError *error = nil;
    [participantGroup removeUser:user error:&error];
    completionHandler(error);
}

#pragma mark - Patient

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    
}

- (void)updatePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    
}

#pragma mark - Refresh

- (NSMutableDictionary *)lastRefreshTimeMap
{
    if (nil == _lastRefreshTimeMap) {
        WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
        _lastRefreshTimeMap = [userDefaultsManager.lastRefreshTimeMap mutableCopy];
    }
    return _lastRefreshTimeMap;
}

- (NSNumber *)lastRefreshTime:(NSString *)collection
{
    NSDictionary *lastRefreshTimeMap = self.lastRefreshTimeMap;
    NSNumber *lastRefreshTime = lastRefreshTimeMap[collection];
    if (lastRefreshTime == nil) {
        lastRefreshTime = @(0);
    }
    return lastRefreshTime;
}

- (void)setLastRefreshTime:(NSNumber *)lastRefreshTime forCollection:(NSString *)collection
{
    NSMutableDictionary *lastRefreshTimeMap = self.lastRefreshTimeMap;
    lastRefreshTimeMap[collection] = lastRefreshTime;
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    userDefaultsManager.lastRefreshTimeMap = lastRefreshTimeMap;
}

@end
