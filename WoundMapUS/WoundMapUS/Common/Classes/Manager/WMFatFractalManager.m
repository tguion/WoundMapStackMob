//
//  WMFatFractalManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractalManager.h"
#import "MBProgressHUD.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMMedicalHistoryItem.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMOrganization.h"
#import "WMTeam.h"
#import "WMTeamPolicy.h"
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
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

NSInteger const kNumberFreeMonthsFirstSubscription = 3;

@interface WMFatFractalManager ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;

@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;      // map of objectID or collection to refresh times

@end

@implementation WMFatFractalManager

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
        if (object) {
            [ff forgetObj:object];
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

// not called on main thread
- (void)queuedOperationCompleted:(FFQueuedOperation *)queuedOperation
{
    if ([queuedOperation.queuedObj isKindOfClass:[WMPhoto class]]) {
        WMPhoto *photo = (WMPhoto *)queuedOperation.queuedObj;
        WMWoundPhoto *woundPhoto = photo.woundPhoto;
        NSManagedObjectContext *managedObjectContext = [photo managedObjectContext];
        [Faulter faultObjectWithID:[photo objectID]
                         inContext:managedObjectContext];
        [Faulter faultObjectWithID:[woundPhoto objectID]
                         inContext:managedObjectContext];
    }
//    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
//    [managedObjectContext MR_saveToPersistentStoreAndWait];
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

- (void)truncateStoreForSignIn:(WMParticipant *)participant completionHandler:(dispatch_block_t)completionHandler
{
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMTeam *team = participant.team;
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    NSString *lastUserName = userDefaultsManager.lastUserName;
    BOOL participantHasChangedOnDevice = NO;
    if (lastUserName && ![lastUserName isEqualToString:participant.userName]) {
        // participant on this device has changed
        participantHasChangedOnDevice = YES;
        [WMNavigationNode MR_truncateAllInContext:managedObjectContext];
        [WMNavigationTrack MR_truncateAllInContext:managedObjectContext];
        [WMPatient MR_truncateAllInContext:managedObjectContext];
    }
    // determine if we need to move patients to team
    __block NSInteger patientCount = [WMPatient MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"%K = nil", WMPatientRelationships.team] inContext:managedObjectContext];
    BOOL assignPatientsToTeam = NO;
    if (patientCount && team) {
        // participant is on team, but has some patients not assigned to team
        assignPatientsToTeam = YES;
    }
    if (!participantHasChangedOnDevice && !assignPatientsToTeam) {
        completionHandler();
        return;
    }
    // else refetch patients
    [self fetchPatients:managedObjectContext ff:ff completionHandler:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        patientCount = [WMPatient MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"%K = nil", WMPatientRelationships.team] inContext:managedObjectContext];
        NSString *queryString = [NSString stringWithFormat:@"/%@/(teamFlag eq '%@')?depthRef=2", [WMNavigationNode entityName], team == nil ? @"false":@"true"];
        if (patientCount) {
            // if any patients not on team, get all nodes since we need all to move patients to team
            queryString = [NSString stringWithFormat:@"/%@?depthRef=2", [WMNavigationNode entityName]];
        }
        [ff getArrayFromUri:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            // patient and wound nodes are not connected to stage, so will not be acquired with last query
            NSError *localError = nil;
            NSArray *patientNavigationNodes = [WMNavigationNode patientNodes:managedObjectContext];
            if ([patientNavigationNodes count] == 0) {
                [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/(%@ eq 'true' or %@ eq 'true')", [WMNavigationNode entityName], WMNavigationNodeAttributes.patientFlag, WMNavigationNodeAttributes.woundFlag] error:&localError];
                if (localError) {
                    [WMUtilities logError:localError];
                }
            }
            // hold onto stage/track for each patient
            NSArray *patients = [WMPatient MR_findAllInContext:managedObjectContext];
            NSMutableDictionary *map = [NSMutableDictionary dictionary];
            for (WMPatient *patient in patients) {
                if (patient.ffUrl) {
                    if (nil == patient.team) {
                        NSString *string = [NSString stringWithFormat:@"%@|%@", patient.stage.track.title, patient.stage.title];
                        if (string) {
                            map[patient.ffUrl] = string;
                        }
                    }
                } else {
                    // patient may have been abandoned
                    [managedObjectContext MR_deleteObjects:@[patient]];
                }
            }
            weakSelf.appDelegate.patient2StageMap = map;
            if ([object isKindOfClass:[NSArray class]] && [object count]) {
                [coreDataHelper markBackendDataAcquiredForEntityName:[WMNavigationTrack entityName]];
                [coreDataHelper markBackendDataAcquiredForEntityName:[WMNavigationStage entityName]];
                [coreDataHelper markBackendDataAcquiredForEntityName:[WMNavigationNode entityName]];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
            }
            completionHandler();
        }];
    }];
}

#pragma mark - Fetch

- (void)updateParticipant:(WMParticipant *)participant completionHandler:(WMErrorCallback)completionHandler
{
    __block WMParticipant *localParticipant = participant;
    NSParameterAssert(localParticipant.person);
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [localParticipant managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    // check assess to data
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMParticipant entityName], [localParticipant.ffUrl lastPathComponent]];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        NSAssert(nil != object && [object isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", object);
        if (error) {
            completionHandler(error);
        } else {
            // check again for new member of team
            localParticipant = object;
            [weakSelf truncateStoreForSignIn:localParticipant completionHandler:^{
                // update team
                WMTeam *team = localParticipant.team;
                WMTeamInvitation *teamInvitation = localParticipant.teamInvitation;
                if (team) {
                    NSParameterAssert(team.ffUrl);
                    dispatch_block_t block = ^{
                        // get patients - patients may have been created or deleted on another device
                        [weakSelf fetchPatients:managedObjectContext ff:ff completionHandler:^(NSError *error) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                            // check that participant is still on team
                            if (nil != localParticipant.team) {
                                // move any patients track to team track
                                [weakSelf movePatientsForParticipant:localParticipant toTeam:team completionHandler:^(NSError *error) {
                                    if (teamInvitation && ![team.invitations containsObject:teamInvitation]) {
                                        // may have been deleted on back end
                                        localParticipant.teamInvitation = nil;
                                        [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                                        completionHandler(error);
                                    } else {
                                        completionHandler(error);
                                    }
                                }];
                            } else {
                                completionHandler(error);
                            }
                        }];
                    };
                    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMTeam entityName], [team.ffUrl lastPathComponent]];
                    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                        // if we did not resolve team, we may have been removed from team
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                        if (nil == object && response.statusCode == 403) {
                            localParticipant.team = nil;
                            block();
                        } else {
                            block();
                        }
                    }];
                } else if (teamInvitation) {
                    NSParameterAssert(teamInvitation.ffUrl);
                    NSString *queryString = [NSString stringWithFormat:@"/%@/%@",[WMTeamInvitation entityName], [teamInvitation.ffUrl lastPathComponent]];
                    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                        // may have been deleted on back end
                        if (response.statusCode == 404) {
                            // it was deleted
                            localParticipant.teamInvitation = nil;
                            [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                            [managedObjectContext MR_saveToPersistentStoreAndWait];
                        }
                        completionHandler(error);
                    }];
                } else {
                    completionHandler(nil);
                }
            }];
        }
    }];
    self.lastRefreshTimeMap[[localParticipant objectID]] = [FFUtils unixTimeStampFromDate:[NSDate date]];
}

- (void)acquireParticipantForUser:(FFUser *)user completionHandler:(WMObjectCallback)completionHandler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    WMObjectCallback objectCallback2 = ^(NSError *error, id participant) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        completionHandler(error, participant);
    };
    WMObjectCallback objectCallback = ^(NSError *error, id participant) {
        if (error) {
            [WMUtilities logError:error];
        }
        // explicite fetch patients - this appears to be needed since fetching the participant incurs some error
        [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPatient entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            objectCallback2(error, participant);
        }];
    };
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@?depthGb=1&depthRef=1",[WMParticipant entityName], user.guid];
    [ff getObjFromUri:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        id participant = object;
        // check assess to data
        [self truncateStoreForSignIn:participant completionHandler:^{
            objectCallback(error, participant);
        }];
    }];
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
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error);
        }
    };
    NSMutableSet *localPatients = [NSMutableSet setWithArray:[WMPatient MR_findAllInContext:managedObjectContext]];
    NSString *queryString = [NSString stringWithFormat:@"/%@?depthGb=1&depthRef=1", collection];
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        if (response.error) {
            completionHandler(response.error);
        } else {
            NSSet *patients = [NSSet setWithArray:response.objs];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [localPatients minusSet:patients];
            if ([localPatients count]) {
                // filter out any objects where ffUrl is nil
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ffUrl != nil"];
                [localPatients filterUsingPredicate:predicate];
                if ([localPatients count]) {
                    DLog(@"Will delete %@", localPatients);
                    for (WMPatient *patient in localPatients) {
                        [ff forgetObj:patient];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendDeletedObjectIDs object:[localPatients valueForKeyPath:@"objectID"]];
                    [managedObjectContext MR_deleteObjects:localPatients];
                }
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            // may need to get consultingGroup
            counter = [patients count];
            if (0 == counter) {
                completionHandler(nil);
            } else {
                for (WMPatient *patient in patients) {
                    [ff getObjFromUri:[NSString stringWithFormat:@"%@/%@", patient.ffUrl, @"consultantGroup"] onComplete:onComplete];
                }
            }
        }
    }];
}

- (void)updateGrabBags:(NSArray *)grabBagNames aggregator:(NSManagedObject *)aggregator ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = [aggregator managedObjectContext];
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
    __block NSInteger counter = [grabBagNames count];
    WMErrorCallback onComplete = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error);
        }
    };
    for (NSString *grabBagName in grabBagNames) {
        NSMutableSet *localGrabBagObjects = [[aggregator valueForKey:grabBagName] mutableCopy];
        [ff grabBagGetAllForObj:aggregator grabBagName:grabBagName onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                onComplete(error);
            } else {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                // do not delete local objects that are part of the seed
                NSEntityDescription *entityDescription = [aggregator entity];
                NSRelationshipDescription *relationshipDescription = [entityDescription relationshipsByName][grabBagName];
                NSEntityDescription *destinationEntity = relationshipDescription.destinationEntity;
                NSString *entityName = [destinationEntity name];
                if (![coreDataHelper isBackendDataAcquiredForEntityName:entityName]) {
                    NSSet *remoteGrabBag = [NSSet setWithArray:object];
                    [localGrabBagObjects minusSet:remoteGrabBag];
                    if ([localGrabBagObjects count]) {
                        // filter out any objects where ffUrl is nil
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ffUrl != nil"];
                        [localGrabBagObjects filterUsingPredicate:predicate];
                        if ([localGrabBagObjects count]) {
                            DLog(@"Will delete %@", localGrabBagObjects);
                            for (id localGrabBagObject in localGrabBagObjects) {
                                [ff forgetObj:localGrabBagObject];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:kBackendDeletedObjectIDs object:[localGrabBagObjects valueForKeyPath:@"objectID"]];
                            [managedObjectContext MR_deleteObjects:localGrabBagObjects];
                        }
                    }
                }
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                // post notification for WMWoundPhoto fetch from back end
                if ([grabBagName isEqualToString:WMWoundRelationships.photos] && [object isKindOfClass:[NSArray class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAcquiredWoundPhotosNotification object:[object valueForKeyPath:@"objectID"]];
                }
                onComplete(nil);
            }
        }];
    }
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
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        completionHandler(error);
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
        }
        [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            completionHandler(error);
        }];
    }];
}

- (void)updatePerson:(WMPerson *)person ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error);
        }
    };
    FFHttpMethodCompletion createAddressOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        WMAddress *localAddress = (WMAddress *)object;
        [ff queueGrabBagAddItemAtUri:localAddress.ffUrl toObjAtUri:person.ffUrl grabBagName:WMPersonRelationships.addresses];
        block(error);
    };
    FFHttpMethodCompletion createTelecomOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        WMTelecom *localTelecom = (WMTelecom *)object;
        [ff queueGrabBagAddItemAtUri:localTelecom.ffUrl toObjAtUri:person.ffUrl grabBagName:WMPersonRelationships.telecoms];
        block(error);
    };
    FFHttpMethodCompletion updatePersonOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            for (WMAddress *address in person.addresses) {
                ++counter;
                if (!address.ffUrl) {
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:createAddressOnComplete onOffline:createAddressOnComplete];
                } else {
                    [ff updateObj:address onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            for (WMTelecom *telecom in person.telecoms) {
                ++counter;
                if (!telecom.ffUrl) {
                    [ff createObj:telecom atUri:[NSString stringWithFormat:@"/%@", [WMTelecom entityName]] onComplete:createTelecomOnComplete onOffline:createTelecomOnComplete];
                } else {
                    [ff updateObj:telecom onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            block(nil);
        }
    };
    ++counter;
    [ff updateObj:person onComplete:updatePersonOnComplete onOffline:updatePersonOnComplete];
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
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error);
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
                                [ff grabBagAddItemAtFfUrl:participant.ffUrl
                                             toObjAtFfUrl:team.ffUrl
                                              grabBagName:WMTeamRelationships.participants
                                               onComplete:httpMethodCompletion];
                                // add invitations 1
                                for (WMTeamInvitation *invitation in team.invitations) {
                                    ++counter; // 2
                                    [ff createObj:invitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                        if (error) {
                                            [WMUtilities logError:error];
                                        }
                                        NSParameterAssert([object isKindOfClass:[WMTeamInvitation class]]);
                                        WMTeamInvitation *teamInvitation = (WMTeamInvitation *)object;
                                        [ff grabBagAddItemAtFfUrl:teamInvitation.ffUrl
                                                     toObjAtFfUrl:team.ffUrl
                                                      grabBagName:WMTeamRelationships.invitations
                                                       onComplete:httpMethodCompletion];
                                    }];
                                }
                                // seed team with navigation track, stage, node 1
                                counter += 5;   // WMNavigationTrack does 5 callbacks
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
                                    block(error); // 0
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
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error);
        }
    };
    FFHttpMethodCompletion createAddressOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            WMAddress *address = (WMAddress *)object;
            [ff queueGrabBagAddItemAtUri:address.ffUrl toObjAtUri:organization.ffUrl grabBagName:WMOrganizationRelationships.addresses];
            block(error);
        }
    };
    FFHttpMethodCompletion createIdOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            WMId *anId = (WMId *)object;
            [ff queueGrabBagAddItemAtUri:anId.ffUrl toObjAtUri:organization.ffUrl grabBagName:WMOrganizationRelationships.ids];
            block(error);
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
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]] onComplete:createAddressOnComplete onOffline:createAddressOnComplete];
                } else {
                    [ff updateObj:address onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    }];
                }
            }
            for (WMId *anId in organization.ids) {
                ++counter;
                if (!anId.ffUrl) {
                    [ff createObj:anId atUri:[NSString stringWithFormat:@"/%@", [WMId entityName]] onComplete:createIdOnComplete onOffline:createIdOnComplete];
                } else {
                    [ff updateObj:anId onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                        block(error);
                    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
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
                               if (error) {
                                   [WMUtilities logError:error];
                               }
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

- (void)addParticipantToTeamFromTeamInvitation:(WMTeamInvitation *)teamInvitation team:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSManagedObjectContext *managedObjectContext = teamInvitation.managedObjectContext;
    NSParameterAssert([teamInvitation.ffUrl length]);
    WMParticipant *invitee = teamInvitation.invitee;
    NSParameterAssert([invitee isKindOfClass:[WMParticipant class]]);
    FFUser *user = teamInvitation.invitee.user;
    if (nil == user) {
        NSError *localError = nil;
        user = [ff getObjFromUri:[NSString stringWithFormat:@"/FFUser/(userName eq '%@')", teamInvitation.inviteeUserName] error:&localError];
        if (localError) {
            [WMUtilities logError:localError];
        }
    }
    NSParameterAssert([user isKindOfClass:[FFUser class]]);
    // only team leader can do this
    invitee.team = team;
    if (nil == invitee.dateAddedToTeam) {
        invitee.dateAddedToTeam = [NSDate date];
    }
    invitee.dateTeamSubscriptionExpires = [WMUtilities dateByAddingMonths:kNumberFreeMonthsFirstSubscription toDate:invitee.dateTeamSubscriptionExpires];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    FFUserGroup *participantGroup = teamInvitation.team.participantGroup;
    NSParameterAssert(participantGroup);
    NSError *error = nil;
    [participantGroup addUser:user error:&error];
    [ff updateObj:invitee onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff grabBagAddItemAtFfUrl:invitee.ffUrl
                     toObjAtFfUrl:team.ffUrl
                      grabBagName:WMTeamRelationships.participants
                       onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                           if (error) {
                               [WMUtilities logError:error];
                           }
                           [ff deleteObj:teamInvitation onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                               if (error) {
                                   [WMUtilities logError:error];
                               }
                               [managedObjectContext MR_deleteObjects:@[teamInvitation]];
                               // do not move patients to team here - new team member will do on next sign in
                               completionHandler(error);
                           }];
                       }];
    }];
}

- (void)removeParticipant:(WMParticipant *)teamMember fromTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([teamMember.ffUrl length]);
    NSParameterAssert([team.ffUrl length]);
    FFUserGroup *participantGroup = team.participantGroup;
    NSParameterAssert(participantGroup);
    FFUser *user = teamMember.user;
    NSParameterAssert(user);

    NSManagedObjectContext *managedObjectContext = [team managedObjectContext];
    WMParticipant *teamLeader = team.teamLeader;
    
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            [ff forgetObj:teamMember];
            [managedObjectContext MR_deleteObjects:@[teamMember]];
            DLog(@"deleted objects:%@", managedObjectContext.deletedObjects);
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(error);
        }
    };
    // move the patients to team leader (signed in participant)
    NSArray *patients = [WMPatient MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMPatientRelationships.participant, teamMember]
                                                 inContext:managedObjectContext];
    counter = 3 * [patients count];
    for (WMPatient *patient in patients) {
        [ff grabBagRemoveItemAtFfUrl:patient.ffUrl
                      fromObjAtFfUrl:teamMember.ffUrl
                         grabBagName:WMParticipantRelationships.patients
                          onComplete:onComplete];
        patient.participant = teamLeader;
        [ff grabBagAddItemAtFfUrl:patient.ffUrl
                     toObjAtFfUrl:teamLeader.ffUrl
                      grabBagName:WMParticipantRelationships.patients
                       onComplete:onComplete];
        [ff updateObj:patient
           onComplete:onComplete
            onOffline:onComplete];
    }

    FFHttpMethodCompletion onRemoveFromTeam = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        NSError *localError = nil;
        [participantGroup removeUser:user error:&localError];
        if (localError) {
            [WMUtilities logError:localError];
        }
        onComplete(error, object, response);
    };
    
    ++counter;
    teamMember.team = nil;
    [ff updateObj:teamMember
       onComplete:onRemoveFromTeam
        onOffline:onRemoveFromTeam];
    ++counter;
    [ff grabBagRemoveItemAtFfUrl:teamMember.ffUrl
                  fromObjAtFfUrl:team.ffUrl
                     grabBagName:WMTeamRelationships.participants
                      onComplete:onComplete];
}

#pragma mark - Blobs

- (void)queueUploadPhotosForWoundPhoto:(WMWoundPhoto *)woundPhoto photo:(WMPhoto *)photo
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff queueUpdateBlob:UIImagePNGRepresentation(woundPhoto.thumbnail)
           withMimeType:@"image/png"
                 forObj:woundPhoto
             memberName:WMWoundPhotoAttributes.thumbnail];
    [ff queueUpdateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailLarge)
           withMimeType:@"image/png"
                 forObj:woundPhoto
             memberName:WMWoundPhotoAttributes.thumbnailLarge];
    [ff queueUpdateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailMini)
           withMimeType:@"image/png"
                 forObj:woundPhoto
             memberName:WMWoundPhotoAttributes.thumbnailMini];
    [ff queueUpdateBlob:UIImagePNGRepresentation(photo.photo)
      withMimeType:@"image/png"
            forObj:photo
        memberName:WMPhotoAttributes.photo];
}

- (void)uploadPhotosForWoundPhoto:(WMWoundPhoto *)woundPhoto photo:(WMPhoto *)photo
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSParameterAssert(managedObjectContext == [photo managedObjectContext]);
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:self.appDelegate.window.rootViewController.view animated:NO];
        [Faulter faultObjectWithID:[woundPhoto objectID] inContext:managedObjectContext];
        [Faulter faultObjectWithID:[photo objectID] inContext:managedObjectContext];
    };
    FFHttpMethodCompletion uploadWoundPhotoComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff updateBlob:UIImagePNGRepresentation(photo.photo)
          withMimeType:@"image/png"
                forObj:photo
            memberName:WMPhotoAttributes.photo
            onComplete:onComplete onOffline:onComplete];
    };
    FFHttpMethodCompletion onCompleteThumbnailLarge = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailMini)
          withMimeType:@"image/png"
                forObj:woundPhoto
            memberName:WMWoundPhotoAttributes.thumbnailMini
            onComplete:uploadWoundPhotoComplete onOffline:uploadWoundPhotoComplete];
    };
    FFHttpMethodCompletion onCompleteThumbnail = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnailLarge)
          withMimeType:@"image/png"
                forObj:woundPhoto
            memberName:WMWoundPhotoAttributes.thumbnailLarge
            onComplete:onCompleteThumbnailLarge onOffline:onCompleteThumbnailLarge];
    };
    [ff updateBlob:UIImagePNGRepresentation(woundPhoto.thumbnail)
      withMimeType:@"image/png"
            forObj:woundPhoto
        memberName:WMWoundPhotoAttributes.thumbnail
        onComplete:onCompleteThumbnail onOffline:onCompleteThumbnail];
}

- (NSInteger)deleteExpiredPhotos:(WMTeamPolicy *)teamPolicy
{
    NSManagedObjectContext *managedObjectContext = [teamPolicy managedObjectContext];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    NSDate *dateExpires = [WMUtilities dateByAddingMonths:-teamPolicy.numberOfMonthsToDeletePhotoBlobsValue toDate:nil];
    NSArray *woundPhotos = [WMWoundPhoto MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"%K < %@", WMWoundPhotoAttributes.createdAt, dateExpires] inContext:managedObjectContext];
    [self deletePhotosForWoundPhotos:woundPhotos onComplete:onComplete];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    return [woundPhotos count];
}

- (void)deletePhotosForPatient:(WMPatient *)patient
{
    NSArray *woundPhotos = [patient valueForKeyPath:[NSString stringWithFormat:@"%@.@distinctUnionOfSets.%@", WMPatientRelationships.wounds, WMWoundRelationships.photos]];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    [self deletePhotosForWoundPhotos:woundPhotos onComplete:onComplete];
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)deletePhotosForWoundPhotos:(NSArray *)woundPhotos onComplete:(FFHttpMethodCompletion)onComplete
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    for (WMWoundPhoto *woundPhoto in woundPhotos) {
        woundPhoto.photoDeletedPerTeamPolicy = YES;
        [ff deleteBlobForObj:woundPhoto
                  memberName:WMWoundPhotoAttributes.thumbnail
                  onComplete:onComplete onOffline:onComplete];
        woundPhoto.thumbnail = nil;
        [ff deleteBlobForObj:woundPhoto
                  memberName:WMWoundPhotoAttributes.thumbnailLarge
                  onComplete:onComplete onOffline:onComplete];
        woundPhoto.thumbnailLarge = nil;
        [ff deleteBlobForObj:woundPhoto
                  memberName:WMWoundPhotoAttributes.thumbnailMini
                  onComplete:onComplete onOffline:onComplete];
        woundPhoto.thumbnailMini = nil;
        WMPhoto *photo = woundPhoto.photo;
        if (photo) {
            [ff deleteBlobForObj:photo
                      memberName:WMPhotoAttributes.photo
                      onComplete:onComplete onOffline:onComplete];
            photo.photo = nil;
            [ff updateObj:photo onComplete:onComplete onOffline:onComplete];
        }
        [ff updateObj:woundPhoto onComplete:onComplete onOffline:onComplete];
    }
}

#pragma mark - Patient

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler
{
    NSParameterAssert(nil == patient.ffUrl);
    __block NSInteger counter = 0;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            completionHandler(error, patient);
        }
    };
    FFUserGroup *consultantGroup = patient.consultantGroup;
    // create FFUserGroup that will hold the FFUser instance in team
    FFHttpMethodCompletion createPatientOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            [ff queueGrabBagAddItemAtUri:patient.ffUrl toObjAtUri:patient.participant.ffUrl grabBagName:WMParticipantRelationships.patients];
            block(error);
            if (patient.participant.team) {
                ++counter;
                [ff queueGrabBagAddItemAtUri:patient.ffUrl toObjAtUri:patient.participant.team.ffUrl grabBagName:WMTeamRelationships.patients];
                block(error);
            }
            block(error);
        }
    };
    FFHttpMethodCompletion createConsultantGroupOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            block(error);
        } else {
            [ff createObj:patient atUri:[NSString stringWithFormat:@"/%@", [WMPatient entityName]] onComplete:createPatientOnComplete onOffline:createPatientOnComplete];
        }
    };
    ++counter;
    [ff createObj:consultantGroup atUri:@"/FFUserGroup" onComplete:createConsultantGroupOnComplete onOffline:createConsultantGroupOnComplete];
}

- (void)updatePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert(patient.ffUrl);
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __block NSInteger counter = 0;
    WMErrorCallback localCompletionHandler = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(error);
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
    } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
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
        if (counter == 0 || --counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler(error);
        }
    };
    NSArray *patients = [WMPatient MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team = nil"] inContext:managedObjectContext];
    counter = [patients count];
    if (counter == 0) {
        completionHandler(nil);
    } else {
        NSError *localError = nil;
        for (WMPatient *patient in patients) {
            id consultantGroup = [ff getObjFromUri:[NSString stringWithFormat:@"%@/%@", patient.ffUrl, @"consultantGroup"] error:&localError];
            if (localError) {
                [WMUtilities logError:localError];
            }
            NSParameterAssert(consultantGroup);
            patient.consultantGroup = consultantGroup;
            [patient updateNavigationToTeam:team patient2StageMap:self.appDelegate.patient2StageMap];
            [ff updateObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:team.ffUrl grabBagName:WMTeamRelationships.patients onComplete:onComplete];
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:patient.ffUrl toObjAtFfUrl:team.ffUrl grabBagName:WMTeamRelationships.patients onComplete:onComplete];
            }];
        }
    }
}

#pragma mark - Patient Encounter Credits

- (void)decrementPatientEncounterCreditForPatient:(WMPatient *)patient onComplete:(dispatch_block_t)onComplete
{
    WMParticipant *participant = self.appDelegate.participant;
    WMTeam *team = participant.team;
    if (nil == team) {
        onComplete();
        return;
    }
    // else
    BOOL shouldDecrementPatientEncounterCredit = NO;
    NSDate *now = [NSDate date];
    NSDate *lastWoundTreatmentGroup = [WMWoundTreatmentGroup lastWoundTreatmentGroupCreated:patient];
    if (nil == lastWoundTreatmentGroup) {
        shouldDecrementPatientEncounterCredit = YES;
    } else {
        // check if 24 hours apart
        if ([now timeIntervalSinceDate:lastWoundTreatmentGroup] > 60.0*60.0*24.0) {
            shouldDecrementPatientEncounterCredit = YES;
        }
    }
    if (shouldDecrementPatientEncounterCredit) {
        NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
        // update back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        FFHttpMethodCompletion onUpdateTeamComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            onComplete();
        };
        team.purchasedPatientCountValue = (team.purchasedPatientCountValue - 1);
        [ff updateObj:team onComplete:onUpdateTeamComplete onOffline:onUpdateTeamComplete];
    } else {
        onComplete();
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
    FFHttpMethodCompletion createOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
            completionHandler(error);
        } else {
            NSString *itemFFUrl = [object valueForKey:@"ffUrl"];
            [ff queueGrabBagAddItemAtUri:itemFFUrl toObjAtUri:aggregatorFFUrl grabBagName:grabBagName];
            completionHandler(error);
        }
    };
    if (nil == itemFFUrl) {
        [ff createObj:item atUri:[NSString stringWithFormat:@"/%@", [[item entity] name]] onComplete:createOnComplete onOffline:createOnComplete];
    } else {
        [ff queueGrabBagAddItemAtUri:itemFFUrl toObjAtUri:aggregatorFFUrl grabBagName:grabBagName];
        completionHandler(nil);
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
