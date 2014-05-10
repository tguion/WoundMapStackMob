//
//  WMFatFractalManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractalManager.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMMedicalHistoryItem.h"
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
#import "WMInterventionEvent.h"
#import "WMTelecomType.h"
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "Faulter.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMFatFractalManager ()

@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;      // map of objectID or collection to refresh times

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
    
    __weak __typeof(&*self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:[NSManagedObjectContext MR_rootSavingContext]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [weakSelf handleRootManagedObjectContextDidSave:notification];
                                                  }];
    
    return self;
}

- (void)handleRootManagedObjectContextDidSave:(NSNotification *)notification
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion httpMethodCompletion = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    if (_processDeletesOnNSManagedObjectContextObjectsDidChangeNotification) {
        NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
        for (id object in deletedObjects) {
            [ff deleteObj:object onComplete:httpMethodCompletion];
        }
    }
    if (_processUpdatesOnNSManagedObjectContextObjectsDidChangeNotification) {
        /**
         2014-04-08 11:58:44.663 WoundMapUS[38741:60b] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Illegal attempt to establish a relationship 'participant' between objects in different contexts (source = <WMPerson: 0x11cacea0> (entity: WMPerson; id: 0xbecfd00 <x-coredata://2D3D83B0-FE6E-4058-92B3-2FCC63C58AEB/WMPerson/p1> ; data: {

         */
        NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
        for (id object in updatedObjects) {
            [ff updateObj:object onComplete:httpMethodCompletion];
        }
    }
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

- (void)truncateStoreForSignIn:(NSString *)userName completionHandler:(dispatch_block_t)completionHandler
{
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    NSString *lastUserName = userDefaultsManager.lastUserName;
    if (lastUserName && ![lastUserName isEqualToString:userName]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [WMPatient MR_truncateAllInContext:managedObjectContext];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler();
            });
        });
    } else {
        completionHandler();
    }
}

#pragma mark - Fetch

- (void)updateParticipant:(WMParticipant *)participant completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
//    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=4&depthRef=4",[WMParticipant entityName], [participant.ffUrl lastPathComponent]];
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMParticipant entityName], [participant.ffUrl lastPathComponent]];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        NSAssert(nil != object && [object isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", object);
        if (error) {
            completionHandler(error);
        } else {
            // update team
            WMTeam *team = participant.team;
            WMTeamInvitation *teamInvitation = participant.teamInvitation;
            if (team) {
                NSParameterAssert(team.ffUrl);
//                NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=4&depthRef=4",[WMTeam entityName], [team.ffUrl lastPathComponent]];
                NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMTeam entityName], [team.ffUrl lastPathComponent]];
                [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    WM_ASSERT_MAIN_THREAD;
                    NSAssert(nil != object && [object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    // get patients
                    [ffm fetchPatients:managedObjectContext ff:ff completionHandler:^(NSError *error) {
                        // move any patients track to team track
                        [self movePatientsForParticipant:participant toTeam:team completionHandler:^(NSError *error) {
                            if (teamInvitation && ![team.invitations containsObject:teamInvitation]) {
                                // may have been deleted on back end
                                participant.teamInvitation = nil;
                                [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                                [managedObjectContext MR_saveToPersistentStoreAndWait];
                                completionHandler(error);
                            } else {
                                completionHandler(error);
                            }
                        }];
                    }];
                }];
            } else if (teamInvitation) {
                NSParameterAssert(teamInvitation.ffUrl);
                NSString *queryString = [NSString stringWithFormat:@"/%@/%@",[WMTeamInvitation entityName], [teamInvitation.ffUrl lastPathComponent]];
                [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    // may have been deleted on back end
                    if (response.statusCode == 404) {
                        // it was deleted
                        participant.teamInvitation = nil;
                        [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                    }
                    completionHandler(error);
                }];
            } else {
                completionHandler(nil);
            }
        }
    }];
    self.lastRefreshTimeMap[[participant objectID]] = [FFUtils unixTimeStampFromDate:[NSDate date]];
}

- (void)acquireParticipantForUser:(FFUser *)user completionHandler:(WMObjectCallback)completionHandler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
//    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=4&depthRef=4",[WMParticipant entityName], user.guid];
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMParticipant entityName], user.guid];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        id participant = object;
        __block NSInteger counter = 0;
        WMErrorCallback errorCallback = ^(NSError *error) {
            if (--counter == 0) {
                [coreDataHelper.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                    completionHandler(error, participant);
                }];
            }
        };
        // acquire nodes now and medical history items
        NSString *backendSeedEntityName = [WMNavigationNode entityName];
        if (![coreDataHelper isBackendDataAcquiredForEntityName:backendSeedEntityName]) {
            ++counter;
            [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=2", [WMNavigationNode entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [coreDataHelper markBackendDataAcquiredForEntityName:[WMNavigationNode entityName]];
                errorCallback(error);
            }];
        }
        backendSeedEntityName = [WMMedicalHistoryItem entityName];
        if (![coreDataHelper isBackendDataAcquiredForEntityName:backendSeedEntityName]) {
            ++counter;
            [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=1", [WMMedicalHistoryItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [coreDataHelper markBackendDataAcquiredForEntityName:[WMNavigationNode entityName]];
                errorCallback(error);
            }];
        }
    }];
}

- (void)updateTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler
{
    NSParameterAssert(team.ffUrl);
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
//    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=4&depthRef=4",[WMTeam entityName], [team.ffUrl lastPathComponent]];
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMTeam entityName], [team.ffUrl lastPathComponent]];
    [ff getObjFromUri:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        NSAssert(nil != object && [object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
        FFUserGroup *participantGroup = team.participantGroup;
        NSLog(@"participantGroup %@ users %@", participantGroup, [participantGroup getUsersWithError:&error]);
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
            NSLog(@"fetching alias %@ for object %@", alias, object);
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
    // Fetch any patients that have been updated on the backend
    // Guide to query language is here: http://fatfractal.com/prod/docs/queries/
    // and full syntax reference here: http://fatfractal.com/prod/docs/reference/#query-language
    // Note use of the "depthGb" parameter - see here: http://fatfractal.com/prod/docs/queries/#retrieving-related-objects-inline
    NSString *collection = [WMPatient entityName];
    id lastRefreshTime = self.lastRefreshTimeMap[collection];
    if (nil == lastRefreshTime) {
        lastRefreshTime = @(0);
    }
    NSMutableSet *localPatients = [NSMutableSet setWithArray:[WMPatient MR_findAllInContext:managedObjectContext]];
    NSString *queryString = [NSString stringWithFormat:@"/%@?depthGb=1&depthRef=1", collection];
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        if (response.error) {
            completionHandler(response.error);
        } else {
            NSSet *patients = [NSSet setWithArray:response.objs];
            [localPatients minusSet:patients];
            [managedObjectContext MR_deleteObjects:localPatients];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(nil);
        }
    }];
}

- (void)updateWoundsForPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSMutableSet *localWounds = [patient.wounds mutableCopy];
    [ff grabBagGetAllForObj:patient grabBagName:WMPatientRelationships.wounds onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            completionHandler(error);
        } else {
            NSSet *wounds = [NSSet setWithArray:object];
            [localWounds minusSet:wounds];
            [managedObjectContext MR_deleteObjects:localWounds];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(nil);
        }
    }];
}

- (void)updateGrabBags:(NSArray *)grabBagNames aggregator:(NSManagedObject *)aggregator ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [aggregator managedObjectContext];
    __block NSInteger counter = 0;
    WMErrorCallback onComplete = ^(NSError *error) {
        if (counter > 0) {
            if (error) {
                counter = NSIntegerMin;
                completionHandler(error);
            } else {
                --counter;
                if (counter == 0) {
                    completionHandler(error);
                }
            }
        }
    };
    for (NSString *grabBagName in grabBagNames) {
        NSMutableSet *localGrabBagObjects = [[aggregator valueForKey:grabBagName] mutableCopy];
        ++counter;
        [ff grabBagGetAllForObj:aggregator grabBagName:grabBagName onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                onComplete(error);
            } else {
                NSSet *remoteGrabBag = [NSSet setWithArray:object];
                [localGrabBagObjects minusSet:remoteGrabBag];
                [managedObjectContext MR_deleteObjects:localGrabBagObjects];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                onComplete(nil);
            }
        }];
    }
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
- (void)createParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
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

- (void)updateParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    WM_ASSERT_MAIN_THREAD;
    NSParameterAssert(completionHandler);
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    [self updatePerson:participant.person ff:ff completionHandler:^(NSError *error) {
        if (error) {
            completionHandler(error);
        } else {
            [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                completionHandler(error);
            }];
        }
    }];
}

- (void)updatePerson:(WMPerson *)person ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            counter = 0;
            completionHandler(error);
        } else {
            --counter;
            if (counter == 0) {
                completionHandler(error);
            }
        }
    };
    ++counter;
    [ff updateObj:person onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            for (WMAddress *address in person.addresses) {
                ++counter;
                if (!address.ffUrl) {
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            block(error);
                        } else {
                            WMAddress *localAddress = (WMAddress *)object;
                            [ff grabBagAddItemAtFfUrl:localAddress.ffUrl toObjAtFfUrl:person.ffUrl grabBagName:WMPersonRelationships.addresses onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                block(error);
                            }];
                        }
                    }];
                } else {
                    [ff updateObj:address onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            for (WMTelecom *telecom in person.telecoms) {
                ++counter;
                if (!telecom.ffUrl) {
                    [ff createObj:telecom atUri:[NSString stringWithFormat:@"/%@", [WMTelecom entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            block(error);
                        } else {
                            WMTelecom *localTelecom = (WMTelecom *)object;
                            [ff grabBagAddItemAtFfUrl:localTelecom.ffUrl toObjAtFfUrl:person.ffUrl grabBagName:WMPersonRelationships.telecoms onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                block(error);
                            }];
                        }
                    }];
                } else {
                    [ff updateObj:telecom onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            block(nil);
        }
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
    
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            counter = 0;
            completionHandler(error);
        } else {
            --counter;
            if (counter == 0) {
                completionHandler(error);
            }
        }
    };
    
    FFHttpMethodCompletion httpMethodCompletion = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        block(error);
    };
    
    // create FFUserGroup that will hold the FFUser instance in team
    ++counter;// 1
    [ff createObj:participantGroup atUri:@"/FFUserGroup" onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            NSAssert([object isKindOfClass:[FFUserGroup class]], @"Expected FFUserGroup but got %@", object);
            // create team
            [ff createObj:team atUri:[NSString stringWithFormat:@"/%@", [WMTeam entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                // 1
                if (error) {
                    block(error);
                } else {
                    NSAssert([object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
                    // add participant (user) to FFUserGroup
                    [team.participantGroup addUser:user error:&error];
                    if (error) {
                        block(error);
                    } else {
                        // update participant
                        [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            // 1
                            if (error) {
                                block(error);
                            } else {
                                // add to grab bag
                                ++counter; // 2
                                [ff grabBagAddItemAtFfUrl:participant.ffUrl
                                             toObjAtFfUrl:team.ffUrl
                                              grabBagName:WMTeamRelationships.participants
                                               onComplete:httpMethodCompletion];
                                // add invitations 1
                                for (WMTeamInvitation *invitation in team.invitations) {
                                    ++counter; // 2
                                    [ff createObj:invitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                        NSParameterAssert([object isKindOfClass:[WMTeamInvitation class]]);
                                        WMTeamInvitation *teamInvitation = (WMTeamInvitation *)object;
                                        [ff grabBagAddItemAtFfUrl:teamInvitation.ffUrl
                                                     toObjAtFfUrl:team.ffUrl
                                                      grabBagName:WMTeamRelationships.invitations
                                                       onComplete:httpMethodCompletion];
                                    }];
                                }
                                // seed team with navigation track, stage, node 1
                                [WMNavigationTrack seedDatabaseForTeam:team completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection, dispatch_block_t callBack) {
                                    // update backend
                                    NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
                                    for (NSManagedObjectID *objectID in objectIDs) {
                                        NSManagedObject *object = [managedObjectContext objectWithID:objectID];
                                        NSLog(@"*** WoundMap: Will create collection backend: %@", object);
                                        [ff createObj:object atUri:ffUrl];
                                    }
                                    if (callBack) {
                                        callBack();
                                    }
                                    block(nil); // 0
                                }];
                            }
                        }];
                    }
                }
            }];
        }
    }];
}
- (void)updateOrganization:(WMOrganization *)organization ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            counter = 0;
            completionHandler(error);
        } else {
            --counter;
            if (counter == 0) {
                completionHandler(error);
            }
        }
    };
    ++counter;
    [ff updateObj:organization onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            for (WMAddress *address in organization.addresses) {
                ++counter;
                if (!address.ffUrl) {
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            block(error);
                        } else {
                            [ff grabBagAddItemAtFfUrl:address.ffUrl toObjAtFfUrl:organization.ffUrl grabBagName:WMOrganizationRelationships.addresses onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                block(error);
                            }];
                        }
                    }];
                } else {
                    [ff updateObj:address onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            for (WMId *anId in organization.ids) {
                ++counter;
                if (!anId.ffUrl) {
                    [ff createObj:anId atUri:[NSString stringWithFormat:@"/%@", [WMId entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            block(error);
                        } else {
                            [ff grabBagAddItemAtFfUrl:anId.ffUrl toObjAtFfUrl:organization.ffUrl grabBagName:WMOrganizationRelationships.ids onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                block(error);
                            }];
                        }
                    }];
                } else {
                    [ff updateObj:anId onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            block(nil);
        }
    }];
}

- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([teamInvitation.ffUrl length] == 0);
    NSParameterAssert(nil != teamInvitation.team);
    NSParameterAssert([teamInvitation.team.ffUrl length] > 0);
    NSParameterAssert(nil != teamInvitation.invitee);
    NSManagedObjectContext *managedObjectContext = [teamInvitation managedObjectContext];
    [ff createObj:teamInvitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            completionHandler(error);
        } else {
            [ff grabBagAddItemAtFfUrl:teamInvitation.ffUrl
                         toObjAtFfUrl:teamInvitation.team.ffUrl
                          grabBagName:WMTeamRelationships.invitations
                           onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                               [managedObjectContext MR_saveToPersistentStoreAndWait];
                               completionHandler(error);
                           }];
        }
    }];
}

- (void)revokeTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([teamInvitation.ffUrl length]);
    [ff deleteObj:teamInvitation onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        completionHandler(error);
    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
        completionHandler(error);
    }];
}

- (void)addParticipantToTeamFromTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = teamInvitation.managedObjectContext;
    NSParameterAssert([teamInvitation.ffUrl length]);
    WMParticipant *invitee = teamInvitation.invitee;
    NSParameterAssert([invitee isKindOfClass:[WMParticipant class]]);
    FFUser *user = teamInvitation.invitee.user;
    NSParameterAssert([user isKindOfClass:[FFUser class]]);
    WMTeam *team = teamInvitation.team;
    // only team leader can do this
    invitee.team = team;
    if (nil == invitee.dateAddedToTeam) {
        invitee.dateAddedToTeam = [NSDate date];
    }
    invitee.dateTeamSubscriptionExpires = [WMUtilities dateByAddingMonths:2 toDate:invitee.dateTeamSubscriptionExpires];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    FFUserGroup *participantGroup = teamInvitation.team.participantGroup;
    NSParameterAssert(participantGroup);
    NSError *error = nil;
    [participantGroup addUser:user error:&error];
    __weak __typeof(&*self)weakSelf = self;
    [ff updateObj:invitee onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [ff grabBagAddItemAtFfUrl:invitee.ffUrl
                     toObjAtFfUrl:team.ffUrl
                      grabBagName:WMTeamRelationships.participants
                       onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                           [ff deleteObj:teamInvitation onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                               [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                               // fetch patients
                               [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPatient entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                   [weakSelf movePatientsForParticipant:invitee toTeam:team completionHandler:completionHandler];
                               }];
                           }];
                       }];
    }];
}

- (void)removeParticipantFromTeam:(WMParticipant *)teamMember ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
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

#pragma mark - Blobs

- (void)uploadPhotosForWoundPhoto:(WMWoundPhoto *)woundPhoto photo:(WMPhoto *)photo
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSParameterAssert(managedObjectContext == [photo managedObjectContext]);
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [Faulter faultObjectWithID:[woundPhoto objectID] inContext:managedObjectContext];
        [Faulter faultObjectWithID:[photo objectID] inContext:managedObjectContext];
    };
    FFHttpMethodCompletion uploadWoundPhotoComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (--counter == 0) {
            [ff updateBlob:UIImagePNGRepresentation(photo.photo)
              withMimeType:@"image/png"
                    forObj:photo
                memberName:WMPhotoAttributes.photo
                onComplete:onComplete onOffline:onComplete];
        }
    };
    counter = 3;
    [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnail)
      withMimeType:@"image/png"
            forObj:woundPhoto
        memberName:WMWoundPhotoAttributes.thumbnail
        onComplete:uploadWoundPhotoComplete onOffline:uploadWoundPhotoComplete];
    [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailLarge)
      withMimeType:@"image/png"
            forObj:woundPhoto
        memberName:WMWoundPhotoAttributes.thumbnailLarge
        onComplete:uploadWoundPhotoComplete onOffline:uploadWoundPhotoComplete];
    [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailMini)
      withMimeType:@"image/png"
            forObj:woundPhoto
        memberName:WMWoundPhotoAttributes.thumbnailMini
        onComplete:uploadWoundPhotoComplete onOffline:uploadWoundPhotoComplete];
}

#pragma mark - Patient

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler
{
    NSParameterAssert(nil == patient.ffUrl);
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            counter = 0;
            completionHandler(error, patient);
        } else {
            --counter;
            if (counter == 0) {
                completionHandler(error, patient);
            }
        }
    };
    FFUserGroup *consultantGroup = patient.consultantGroup;
    // create FFUserGroup that will hold the FFUser instance in team
    ++counter;
    [ff createObj:consultantGroup atUri:@"/FFUserGroup" onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            [ff createObj:patient atUri:[NSString stringWithFormat:@"/%@", [WMPatient entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    block(error);
                } else {
                    [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:patient.participant.ffUrl grabBagName:WMParticipantRelationships.patients onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                    if (patient.participant.team) {
                        ++counter;
                        [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:patient.participant.team.ffUrl grabBagName:WMTeamRelationships.patients onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            block(error);
                        }];
                    }
                }
            }];
        }
    }];
}

- (void)updatePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert(patient.ffUrl);
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __block NSInteger counter = 0;
    WMErrorCallback localCompletionHandler = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            --counter;
            if (counter == 0) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                completionHandler(error);
            }
        }
    };
    for (NSString *relationshipName in [WMPatient toManyRelationshipNames]) {
        NSSet *items = [patient valueForKey:relationshipName];
        for (id item in items) {
            ++counter;
            [self insertOrUpdateGrabBagItem:item
                                 aggregator:patient
                                grabBagName:relationshipName
                                         ff:ff
                          completionHandler:localCompletionHandler];
        }
    }
    ++counter;
    [ff updateObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        localCompletionHandler(error);
    }];
}

- (void)movePatientsForParticipant:(WMParticipant *)participant toTeam:(WMTeam *)team completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    NSParameterAssert(managedObjectContext == [team managedObjectContext]);
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        --counter;
        if (counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(error);
        }
    };
    NSArray *patients = [WMPatient MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team = nil"] inContext:managedObjectContext];
    counter = [patients count];
    if (counter == 0) {
        completionHandler(nil);
    } else {
        for (WMPatient *patient in patients) {
            WMNavigationTrack *track = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"team == %@ AND title == %@", team, patient.stage.track.title] inContext:managedObjectContext];
            WMNavigationStage *stage = [WMNavigationStage MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"track == %@ AND title == %@", track, patient.stage.title] inContext:managedObjectContext];
            patient.stage = stage;
            patient.team = team;
            [ff updateObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:team.ffUrl grabBagName:WMTeamRelationships.patients onComplete:onComplete];
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:team.ffUrl grabBagName:WMTeamRelationships.patients onComplete:onComplete];
            }];
        }
    }
}

#pragma mark - Inserts and Updates

- (void)insertOrUpdateGrabBagItem:(NSManagedObject *)item
                       aggregator:(NSManagedObject *)aggregator
                      grabBagName:(NSString *)grabBagName
                               ff:(WMFatFractal *)ff
                completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([item managedObjectContext] == [aggregator managedObjectContext]);
    NSString *itemFFUrl = [item valueForKey:@"ffUrl"];
    NSString *aggregatorFFUrl = [aggregator valueForKey:@"ffUrl"];
    if (nil == itemFFUrl) {
        [ff createObj:item atUri:[NSString stringWithFormat:@"/%@", [[item entity] name]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
                completionHandler(error);
            } else {
                NSString *itemFFUrl = [object valueForKey:@"ffUrl"];
                [ff grabBagAddItemAtFfUrl:itemFFUrl toObjAtFfUrl:aggregatorFFUrl grabBagName:grabBagName onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    completionHandler(error);
                }];
            }
        }];
    } else {
        [ff grabBagAddItemAtFfUrl:itemFFUrl toObjAtFfUrl:aggregatorFFUrl grabBagName:grabBagName onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
                completionHandler(error);
            } else {
                completionHandler(error);
            }
        }];
    }
}

#pragma mark - Seed updates

- (BOOL)updateTelecomType:(WMFatFractal *)ff managedObjectContext:(NSManagedObjectContext *)managedObjectContext completionHandler:(FFHttpMethodCompletion)completionHandler
{
    if ([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0) {
        // fetch from back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSString *query = [NSString stringWithFormat:@"/%@", [WMTelecomType entityName]];
        [ff getArrayFromUri:query onComplete:completionHandler];
        return YES;
    }
    // else
    return NO;
}

- (BOOL)updateMedication:(WMFatFractal *)ff managedObjectContext:(NSManagedObjectContext *)managedObjectContext completionHandler:(FFHttpMethodCompletion)completionHandler
{
    if ([WMMedication MR_countOfEntitiesWithContext:managedObjectContext] == 0) {
        // fetch from back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSString *query = [NSString stringWithFormat:@"/%@", [WMMedication entityName]];
        [ff getArrayFromUri:query onComplete:completionHandler];
        return YES;
    }
    // else
    return NO;
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
