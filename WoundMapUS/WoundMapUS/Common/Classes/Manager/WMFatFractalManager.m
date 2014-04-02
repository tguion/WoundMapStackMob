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
#import "WCAppDelegate.h"
#import "WMUtilities.h"

static const NSInteger WMMaxQueueConcurrency = 1;//24;

@interface WMFatFractalManager ()

@property (nonatomic) NSNumber *lastRefreshTime;
@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSOperationQueue *serialQueue;
@property (strong, nonatomic) NSMutableArray *operationCache;

@property (strong, nonatomic) NSMutableSet *updatedObjectIDs;
@property (strong, nonatomic) NSMutableSet *deletedObjectIDs;

@end

@implementation WMFatFractalManager

@synthesize lastRefreshTime=_lastRefreshTime;

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
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.name = @"FatFractal Queue";
    _operationQueue.maxConcurrentOperationCount = WMMaxQueueConcurrency;
    
    _serialQueue = [[NSOperationQueue alloc] init];
    _serialQueue.name = @"Serial Queue";
    _serialQueue.maxConcurrentOperationCount = 1;

    _operationCache = [[NSMutableArray alloc] init];
    
    _updatedObjectIDs = [[NSMutableSet alloc] init];
    _deletedObjectIDs = [[NSMutableSet alloc] init];
    
    __weak __typeof(&*self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:[NSManagedObjectContext MR_defaultContext]
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

#pragma mark - Fetch

- (void)updateFromCloudParticipant:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSString *queryString = [NSString stringWithFormat:@"/%@/%@/?depthGb=1&depthRef=1",[WMParticipant entityName], [participant.ffUrl lastPathComponent]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        WMParticipant *participant = [ff getObjFromUri:queryString error:&error];
        NSAssert(nil != participant && [participant isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", participant);
        if (error && completionHandler) {
            completionHandler(error);
        } else {
            // make sure we fetch the ALIAS defined on WMParticipant - I'm not sure we have to do this since depthGb=1 in fetch above
            // NOTE: we could also fetch as so: see bottom of http://fatfractal.com/docs/data-modeling/#grab-bags
            // NSString *query = [NSString stringWithFormat:@"/%@/%@/%@", [WMParticipant entityName], [participant.ffUrl lastPathComponent], WMParticipantRelationships.patients];
            // NSArray *participantPatients = [ff getArrayFromUri:query error:&error];
            [ff grabBagGetAllForObj:participant grabBagName:WMParticipantRelationships.acquiredConsults error:&error];
            [ff grabBagGetAllForObj:participant grabBagName:WMParticipantRelationships.interventionEvents error:&error];
            [ff grabBagGetAllForObj:participant grabBagName:WMParticipantRelationships.patients error:&error];
            NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            if (completionHandler) {
                completionHandler(error);
            }
        }
    });
    self.lastRefreshTimeMap[[WMParticipant entityName]] = [FFUtils unixTimeStampFromDate:[NSDate date]];
}

- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext ff:(WMFatFractal *)ff completionHandler:(FFHttpMethodCompletion)completionHandler
{
    NSArray *patientsExisting = [WMPatient MR_findAllInContext:managedObjectContext];
    // Fetch any events that have been updated on the backend
    // Guide to query language is here: http://fatfractal.com/prod/docs/queries/
    // and full syntax reference here: http://fatfractal.com/prod/docs/reference/#query-language
    // Note use of the "depthGb" parameter - see here: http://fatfractal.com/prod/docs/queries/#retrieving-related-objects-inline
    NSString *queryString = [NSString stringWithFormat:@"/WMPatient/(updatedAt gt %@)?depthGb=1&depthRef=1", self.lastRefreshTime];
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        NSArray *patientsRetrieved = response.objs;
        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            }
        }];
        NSMutableArray *patientObjectIDs = [[NSMutableArray alloc] init];
        if (response.error) {
            [WMUtilities logError:response.error];
        } else {
            self.lastRefreshTime = [FFUtils unixTimeStampFromDate:[NSDate date]];
            BOOL newAdditions = NO;
            for (WMPatient *patientRetrieved in patientsRetrieved) {
                BOOL foundLocally = NO;
                for (WMPatient *patientExisting in patientsExisting) {
                    if ([patientExisting.ffUrl isEqualToString:patientRetrieved.ffUrl]) {
                        foundLocally = YES;
                        break;
                    } else {
                        [patientObjectIDs addObject:[patientRetrieved objectID]];
                    }
                }
                if (foundLocally) {
                    DLog(@"   WMPatient with ffUrl %@ from backend found locally", patientRetrieved.ffUrl);
                } else {
                    DLog(@"   Adding new WMPatient with ffUrl %@ from backend", patientRetrieved.ffUrl);
                    newAdditions = YES;
                }
            }
            if (newAdditions) {
                DLog(@"   Got new stuff from backend; reloading data");
            }
            completionHandler(response.error, patientObjectIDs, nil);
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

#pragma mark - Create

- (NSBlockOperation *)createObject:(id)object
                             ffUrl:(NSString *)ffUrl
                                ff:(WMFatFractal *)ff
                        addToQueue:(BOOL)addToQueue
                 completionHandler:(WMOperationCallback)completionHandler
{
    return [self createObject:object
                        ffUrl:ffUrl
                           ff:ff
                   addToQueue:addToQueue
                 insertAtHead:NO
            completionHandler:completionHandler];
}

- (NSBlockOperation *)createObject:(id)object
                             ffUrl:(NSString *)ffUrl
                                ff:(WMFatFractal *)ff
                        addToQueue:(BOOL)addToQueue
                      insertAtHead:(BOOL)insertAtHead
                 completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [self createOperation:object collection:ffUrl ff:ff completionHandler:completionHandler];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        if (insertAtHead) {
            [_operationCache insertObject:operation atIndex:0];
        } else {
            [_operationCache addObject:operation];
        }
    }
    return operation;
}

- (NSBlockOperation *)createArray:(NSArray *)objectIDs
                       collection:(NSString *)collection
                               ff:(WMFatFractal *)ff
                       addToQueue:(BOOL)addToQueue
                 reverseEnumerate:(BOOL)reverseEnumerate
                completionHandler:(void (^)(NSError *))completionHandler;
{
    NSBlockOperation *operation = [self createArrayOperation:objectIDs collection:collection reverseEnumerate:reverseEnumerate ff:ff completionHandler:completionHandler];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

- (NSBlockOperation *)createArray:(NSArray *)objectIDs
                       collection:(NSString *)collection
                               ff:(WMFatFractal *)ff
                       addToQueue:(BOOL)addToQueue
                completionHandler:(void (^)(NSError *))completionHandler;
{
    return [self createArray:objectIDs collection:collection ff:ff addToQueue:addToQueue reverseEnumerate:NO completionHandler:completionHandler];
}

#pragma mark - Updates

- (NSBlockOperation *)updateObject:(NSManagedObject *)object ff:(WMFatFractal *)ff addToQueue:(BOOL)addToQueue completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [self updateOperation:object ff:ff completionHandler:completionHandler];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

#pragma mark - Deletes

- (NSBlockOperation *)deleteObject:(NSManagedObject *)object ff:(WMFatFractal *)ff addToQueue:(BOOL)addToQueue completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [self deleteOperation:object ff:ff completionHandler:completionHandler];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

#pragma mark - Load Blobs

- (NSBlockOperation *)loadBlobs:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [self loadBlobsOperation:object ff:ff completionHandler:completionHandler];
    [_operationQueue addOperation:operation];
    return operation;
}

#pragma mark - Operations Cache

- (BOOL)isCacheEmpty
{
    return [_operationCache count] == 0;
}

- (void)clearOperationCache
{
    [_operationCache removeAllObjects];
}

- (void)submitOperationsToQueue
{
    [_operationQueue addOperations:_operationCache waitUntilFinished:NO];
}


#pragma mark - Backend Updates

// create participant, with reference objects person and team
- (void)updateParticipant:(NSManagedObjectID *)participantObjectID ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMParticipant *participant = (WMParticipant *)[managedObjectContext objectWithID:participantObjectID];
        WMOrganization *organization = participant.organization;
        if (organization) {
            if (organization.ffUrl && [_updatedObjectIDs containsObject:[organization objectID]]) {
                [_updatedObjectIDs removeObject:[organization objectID]];// TODO finish this will other updates
                [ff updateObj:organization];
            } else {
                [ff createObj:organization atUri:[NSString stringWithFormat:@"/%@", [WMOrganization entityName]]];
            }
            for (WMAddress *address in organization.addresses) {
                if (address.ffUrl && [_updatedObjectIDs containsObject:[address objectID]]) {
                    [_updatedObjectIDs removeObject:[address objectID]];
                    [ff updateObj:address];
                } else {
                    [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]]];
                }
            }
            for (WMId *anId in organization.ids) {
                if (anId.ffUrl && [_updatedObjectIDs containsObject:[anId objectID]]) {
                    [_updatedObjectIDs removeObject:[anId objectID]];
                    [ff updateObj:anId];
                } else {
                    [ff createObj:anId atUri:[NSString stringWithFormat:@"/%@", [WMId entityName]]];
                }
            }
            [managedObjectContext MR_saveOnlySelfAndWait];
        }
        WMPerson *person = participant.person;
        participant.person = nil;
        NSAssert(person.participant == nil, @"expected participant to be nil");
        if (person.ffUrl && [_updatedObjectIDs containsObject:[person objectID]]) {
            [_updatedObjectIDs removeObject:[person objectID]];
            [ff updateObj:person];
        } else {
            [ff createObj:person atUri:[NSString stringWithFormat:@"/%@", [WMPerson entityName]]];
        }
        for (WMAddress *address in person.addresses) {
            if (address.ffUrl && [_updatedObjectIDs containsObject:[address objectID]]) {
                [_updatedObjectIDs removeObject:[address objectID]];
                [ff updateObj:address];
            } else {
                [ff createObj:address atUri:[NSString stringWithFormat:@"/%@", [WMAddress entityName]]];
            }
        }
        for (WMTelecom *telecom in person.telecoms) {
            if (telecom.ffUrl && [_updatedObjectIDs containsObject:[telecom objectID]]) {
                [_updatedObjectIDs removeObject:[telecom objectID]];
                [ff updateObj:telecom];
            } else {
                [ff createObj:telecom atUri:[NSString stringWithFormat:@"/%@", [WMTelecom entityName]]];
            }
        }
        participant.person = person;
        if (participant.ffUrl && [_updatedObjectIDs containsObject:[participant objectID]]) {
            [_updatedObjectIDs removeObject:[participant objectID]];
            [ff updateObj:participant];
        } else {
            [ff createObj:participant atUri:[NSString stringWithFormat:@"/%@", [WMParticipant entityName]]];
        }
        // acquiredConsultants
        for (WMPatientConsultant *patientConsultant in participant.acquiredConsults) {
            if (patientConsultant.ffUrl && [_updatedObjectIDs containsObject:[patientConsultant objectID]]) {
                [_updatedObjectIDs removeObject:[patientConsultant objectID]];
                [ff updateObj:patientConsultant];
            } else {
                [ff createObj:patientConsultant atUri:[NSString stringWithFormat:@"/%@",[WMPatientConsultant entityName]]];
            }
        }
        // interventionEvents
        for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
            if (interventionEvent.ffUrl && [_updatedObjectIDs containsObject:[interventionEvent objectID]]) {
                [_updatedObjectIDs removeObject:[interventionEvent objectID]];
                [ff updateObj:interventionEvent];
            } else {
                [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@",[WMInterventionEvent entityName]]];
            }
        }
        // team
        [self updateTeam:participant.team ff:ff completionHandler:nil];
        // teamInvitations
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [NSManagedObjectContext MR_clearContextForCurrentThread];
        if (completionHandler) {
            completionHandler(nil);
        }
    });
}

- (void)updateTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler
{
    
}

- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler
{
    NSParameterAssert([teamInvitation.ffUrl length] == 0);
    NSParameterAssert(nil != teamInvitation.team);
    NSParameterAssert([teamInvitation.team.ffUrl length] > 0);
    NSParameterAssert(nil != teamInvitation.invitee);
    NSParameterAssert([teamInvitation.invitee.ffUrl length] > 0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        id object = (WMTeamInvitation *)[teamInvitation MR_inContext:managedObjectContext];
        NSError *error = nil;
        [ff createObj:object atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] error:&error];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(error);
        }
    });
}

- (void)createTeamWithParticipant:(WMParticipant *)participant user:(FFUser *)user ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
{
    NSParameterAssert([participant.ffUrl length] > 0);
    NSParameterAssert(participant.isTeamLeader);
    NSParameterAssert(completionHandler);
    NSManagedObjectID *participantObjectID = [participant objectID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMParticipant *participant = (WMParticipant *)[managedObjectContext objectWithID:participantObjectID];
        WMTeam *team = participant.team;
        NSParameterAssert(team != nil && [team.ffUrl length] == 0);
        NSError *error = nil;
        FFUserGroup *participantGroup = team.participantGroup;
        id object = [ff createObj:participantGroup atUri:@"/FFUserGroup" error:&error];
        NSAssert([object isKindOfClass:[FFUserGroup class]], @"Expected FFUserGroup but got %@", object);
        if (error) {
            completionHandler(error);
        }
        object = [ff createObj:team atUri:[NSString stringWithFormat:@"/%@", [WMTeam entityName]] error:&error];
        NSAssert([object isKindOfClass:[WMTeam class]], @"Expected WMTeam but got %@", object);
        if (error) {
            completionHandler(error);
        }
        object = [ff updateObj:participant error:&error];
        NSAssert([object isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but got %@", object);
        if (error) {
            completionHandler(error);
        }
        // add participant (user) to FFUserGroup
        [team.participantGroup addUser:user error:&error];
        if (error) {
            completionHandler(error);
        }
        // add invitations
        for (WMTeamInvitation *invitation in team.invitations) {
            object = [ff createObj:invitation atUri:[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]] error:&error];
            NSAssert([object isKindOfClass:[WMTeamInvitation class]], @"Expected WMTeamInvitation but got %@", object);
            if (error) {
                completionHandler(error);
            }
        }
        // seed team with navigation track, stage, node
        [WMNavigationTrack seedDatabaseForTeam:team completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
            // update backend
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
            for (NSManagedObjectID *objectID in objectIDs) {
                NSManagedObject *object = [managedObjectContext objectWithID:objectID];
                NSLog(@"*** WoundMap: Will create collection backend: %@", object);
                [ff createObj:object atUri:ffUrl];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [NSManagedObjectContext MR_clearContextForCurrentThread];
        completionHandler(nil);
    });
}

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff
{
    __weak __typeof(&*self)weakSelf = self;
    NSBlockOperation *patientOperation = [weakSelf createOperation:patient collection:[WMPatient entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
        WMPatient *patient = (WMPatient *)object;
        [weakSelf queuePatientGrabBagAdd:patient ff:ff];
        if (patient.thumbnail) {
            [ff updateBlob:UIImagePNGRepresentation(patient.thumbnail)
              withMimeType:@"image/png" //application/octet-stream image/png
                    forObj:patient
                memberName:WMPatientAttributes.thumbnail
                onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
             }];
        }
        // consultantGroup REFERENCE /FFUserGroup, participantGroup REFERENCE /FFUserGroup
        
    }];
    [_operationCache addObject:patientOperation];
    // bradenScales
    for (WMBradenScale *bradenScale in patient.bradenScales) {
        NSBlockOperation *bradenScaleOperation = [weakSelf createOperation:bradenScale collection:[WMBradenScale entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueBradenScaleGrabBagAdd:(WMBradenScale *)object ff:ff];
        }];
        [patientOperation addDependency:bradenScaleOperation];
        [_operationCache addObject:bradenScaleOperation];
        // sections
        for (WMBradenSection *section in bradenScale.sections) {
            NSBlockOperation *sectionOperation = [weakSelf createOperation:section collection:[WMBradenSection entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [bradenScaleOperation addDependency:sectionOperation];
            [_operationCache addObject:sectionOperation];
            // cells
            for (WMBradenCell *cell in section.cells) {
                NSBlockOperation *cellOperation = [weakSelf createOperation:cell collection:[WMBradenCell entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // nothing
                }];
                [sectionOperation addDependency:cellOperation];
                [_operationCache addObject:cellOperation];
            }
        }
    }
    // carePlanGroups
    for (WMCarePlanGroup *carePlanGroup in patient.carePlanGroups) {
        NSBlockOperation *carePlanGroupOperation = [weakSelf createOperation:carePlanGroup collection:[WMCarePlanGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueCarePlanGroupGrabBagAdd:(WMCarePlanGroup *)object ff:ff];
        }];
        [patientOperation addDependency:carePlanGroupOperation];
        [_operationCache addObject:carePlanGroupOperation];
        // interventionEvents
        for (WMCarePlanInterventionEvent *event in carePlanGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [carePlanGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMCarePlanValue *value in carePlanGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMCarePlanValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [carePlanGroupOperation addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // deviceGroups
    for (WMDeviceGroup *deviceGroup in patient.deviceGroups) {
        NSBlockOperation *deviceGroupOperation = [weakSelf createOperation:deviceGroup collection:[WMDeviceGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueDeviceGroupGrabBagAdd:(WMDeviceGroup *)object ff:ff];
        }];
        [patientOperation addDependency:deviceGroupOperation];
        [_operationCache addObject:deviceGroupOperation];
        // interventionEvents
        for (WMDeviceInterventionEvent *event in deviceGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [deviceGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMDeviceValue *value in deviceGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMDeviceValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [deviceGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // ids
    for (WMId *anId in patient.ids) {
        NSBlockOperation *anIdOperation = [weakSelf createOperation:anId collection:[WMId entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            // nothing
        }];
        [patientOperation addDependency:anIdOperation];
        [_operationCache addObject:anIdOperation];
    }
    // medicationGroups
    for (WMMedicationGroup *medicationGroup in patient.medicationGroups) {
        NSBlockOperation *medicationGroupOperation = [weakSelf createOperation:medicationGroup collection:[WMMedicationGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueMedicationGroupGrabBagAdd:(WMMedicationGroup *)object ff:ff];
        }];
        [patientOperation addDependency:medicationGroupOperation];
        [_operationCache addObject:medicationGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in medicationGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [medicationGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:medicationGroupOperation];
        }
        // medications should have been loaded in the seed
    }
    // patientConsultants
    for (WMPatientConsultant *patientConsultant in patient.patientConsultants) {
        NSBlockOperation *patientConsultantOperation = [weakSelf createOperation:patientConsultant collection:[WMPatientConsultant entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            // nothing
        }];
        [patientOperation addDependency:patientConsultantOperation];
        [_operationCache addObject:patientConsultantOperation];
    }
    // psychosocialGroups
    for (WMPsychoSocialGroup *psychosocialGroup in patient.psychosocialGroups) {
        NSBlockOperation *psychosocialGroupOperation = [weakSelf createOperation:psychosocialGroup collection:[WMPsychoSocialGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queuePsychoSocialGroupGrabBagAdd:(WMPsychoSocialGroup *)object ff:ff];
        }];
        [patientOperation addDependency:psychosocialGroupOperation];
        [_operationCache addObject:psychosocialGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in psychosocialGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [psychosocialGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMPsychoSocialValue *value in psychosocialGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMDeviceValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [psychosocialGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // skinAssessmentGroups
    for (WMSkinAssessmentGroup *skinAssessmentGroup in patient.skinAssessmentGroups) {
        NSBlockOperation *skinAssessmentGroupOperation = [weakSelf createOperation:skinAssessmentGroup collection:[WMSkinAssessmentGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueSkinAssessmentGroupGrabBagAdd:(WMSkinAssessmentGroup *)object ff:ff];
        }];
        [patientOperation addDependency:skinAssessmentGroupOperation];
        [_operationCache addObject:skinAssessmentGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in skinAssessmentGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [skinAssessmentGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMSkinAssessmentValue *value in skinAssessmentGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMSkinAssessmentValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [skinAssessmentGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // wounds
    for (WMWound *wound in patient.wounds) {
        NSBlockOperation *woundOperation = [weakSelf createOperation:wound collection:[WMWound entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [weakSelf queueWoundGrabBagAdd:(WMWound *)object ff:ff];
        }];
        [patientOperation addDependency:woundOperation];
        [_operationCache addObject:woundOperation];
        // measurementGroups
        for (WMWoundMeasurementGroup *measurementGroup in wound.measurementGroups) {
            NSBlockOperation *measurementGroupOperation = [weakSelf createOperation:measurementGroup collection:[WMWoundMeasurementGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                [weakSelf queueWoundMeasurementGroupGrabBagAdd:(WMWoundMeasurementGroup *)object ff:ff];
            }];
            [woundOperation addDependency:measurementGroupOperation];
            [_operationCache addObject:measurementGroupOperation];
            // interventionEvents
            for (WMInterventionEvent *event in measurementGroup.interventionEvents) {
                NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // nothing
                }];
                [measurementGroupOperation addDependency:interventionEventOperation];
                [_operationCache addObject:interventionEventOperation];
            }
            // values
            for (WMWoundMeasurementValue *value in measurementGroup.values) {
                NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMWoundMeasurementValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // nothing
                }];
                [measurementGroupOperation addDependency:valueOperation];
                [_operationCache addObject:valueOperation];
            }
        }
        // photos
        for (WMWoundPhoto *woundPhoto in wound.photos) {
            NSBlockOperation *woundPhotoOperation = [weakSelf createOperation:woundPhoto collection:[WMWoundPhoto entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                [weakSelf queueWoundPhotoGrabBagAdd:(WMWoundPhoto *)object ff:ff];
            }];
            [woundOperation addDependency:woundPhotoOperation];
            [_operationCache addObject:woundPhotoOperation];
            // measurementGroups - already handled with wound
            // photos
            for (WMPhoto *photo in woundPhoto.photos) {
                NSBlockOperation *photoOperation = [weakSelf createOperation:photo collection:[WMPhoto entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // add blob
                    WMPhoto *photo = (WMPhoto *)object;
                    [ff updateBlob:UIImagePNGRepresentation(photo.photo)
                      withMimeType:@"image/png" //application/octet-stream image/png
                            forObj:patient
                        memberName:WMPhotoAttributes.photo
                        onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                        }];
                }];
                [woundPhotoOperation addDependency:photoOperation];
                [_operationCache addObject:photoOperation];
            }
        }
        // positionValues
        for (WMWoundPositionValue *value in wound.positionValues) {
            NSBlockOperation *woundPositionOperation = [weakSelf createOperation:value collection:[WMWoundPositionValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // nothing
            }];
            [woundOperation addDependency:woundPositionOperation];
            [_operationCache addObject:woundPositionOperation];
        }
        // treatmentGroups
        for (WMWoundTreatmentGroup *treatmentGroup in wound.treatmentGroups) {
            NSBlockOperation *treatmentGroupOperation = [weakSelf createOperation:treatmentGroup collection:[WMWoundTreatmentGroup entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                [weakSelf queueWoundTreatmentGroupGrabBagAdd:(WMWoundTreatmentGroup *)object ff:ff];
            }];
            [woundOperation addDependency:treatmentGroupOperation];
            [_operationCache addObject:treatmentGroupOperation];
            // interventionEvents
            for (WMInterventionEvent *event in treatmentGroup.interventionEvents) {
                NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // nothing
                }];
                [treatmentGroupOperation addDependency:interventionEventOperation];
                [_operationCache addObject:interventionEventOperation];
            }
            // values
            for (WMWoundTreatmentValue *value in treatmentGroup.values) {
                NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMWoundTreatmentValue entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                    // nothing
                }];
                [treatmentGroupOperation addDependency:valueOperation];
                [_operationCache addObject:valueOperation];
            }
        }
    }
}

/**
 Assumption here is that operations have been added to _operationCache for any model change deeper that 1. So for example, patient has to-many
 relationship wounds, and wound has to-many relationship measurementGroups. It is assumed that any measurement groups associated with the wound
 have operations in the cache, and we only need to handle the patient >> wounds model change here.
 */
- (void)updatePatient:(WMPatient *)patient insertedObjectIDs:(NSArray *)insertedObjectIDs updatedObjectIDs:(NSArray *)updatedObjectIDs ff:(WMFatFractal *)ff
{
    NSParameterAssert([patient.ffUrl length] > 0);
    // inserts for to-many relationships - depth 1 only
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSEntityDescription *entityDescription = [patient entity];
    NSDictionary *relationshipsByName = [entityDescription relationshipsByName];
    for (NSString *relationshipName in relationshipsByName) {
        NSArray *objects = [patient valueForKey:relationshipName];
        NSMutableSet *objectIDs = [[NSSet setWithArray:[objects valueForKey:@"objectID"]] mutableCopy];
        [objectIDs intersectSet:[NSSet setWithArray:insertedObjectIDs]];
        for (NSManagedObjectID *objectID in objectIDs) {
            NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
            NSAssert(nil == [managedObject valueForKey:@"ffUrl"], @"expected an inserted object to not have ffUrl");
            NSBlockOperation *operation = [self createOperation:managedObject
                                                     collection:[[managedObject entity] name]
                                                             ff:ff
                                              completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                                                  NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                                  object = [managedObjectContext objectWithID:objectID];
                                                  [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                  [ff queueGrabBagAddItemAtUri:[object valueForKey:@"ffUrl"] toObjAtUri:patient.ffUrl grabBagName:relationshipName];
                                              }];
            [_operationCache addObject:operation];
        }
    }
    // inserts for to-one relationships - nothing
    // updates
    for (NSManagedObjectID *objectID in updatedObjectIDs) {
        NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
        NSAssert([managedObject valueForKey:@"ffUrl"], @"expected an updated object to have ffUrl");
        NSBlockOperation *operation = [self updateOperation:managedObject ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }];
        [_operationCache addObject:operation];
    }
    // update patient
    NSBlockOperation *operation = [self updateOperation:patient ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    }];
    [_operationCache addObject:operation];
    // submit operations
    [self submitOperationsToQueue];
}

#pragma mark - Operations

- (NSBlockOperation *)createOperation:(id)object collection:(NSString *)collection ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler
{
    NSParameterAssert([[object valueForKey:@"ffUrl"] length] == 0);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        [ff createObj:object atUri:ffUrl];
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, object, NO);
        }
    }];
    return operation;
}

- (NSBlockOperation *)createArrayOperation:(NSArray *)objectIDs
                                collection:(NSString *)collection
                          reverseEnumerate:(BOOL)reverseEnumerate
                                        ff:(WMFatFractal *)ff
                         completionHandler:(void (^)(NSError *))completionHandler
{
    NSParameterAssert([collection length]);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSUInteger enumerationOptions = (reverseEnumerate ? NSEnumerationReverse:0);
        [objectIDs enumerateObjectsWithOptions:enumerationOptions usingBlock:^(id objectID, NSUInteger index, BOOL *stop) {
            id object = [managedObjectContext objectWithID:objectID];
            NSLog(@"*** WoundMap: Will create object backend: %@", object);
            [ff createObj:object atUri:ffUrl];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }];
        [NSManagedObjectContext MR_clearContextForCurrentThread];
        if (completionHandler) {
            completionHandler(nil);
        }
    }];
    return operation;
}

- (NSBlockOperation *)updateOperation:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler
{
    NSParameterAssert([[object valueForKey:@"ffUrl"] length] > 0);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [ff updateObj:object onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            BOOL signInRequired = NO;
            if (error) {
                if (response.statusCode == 401) {
                    signInRequired = YES;
                }
                [WMUtilities logError:error];
            } else if ([object isKindOfClass:[NSManagedObject class]]) {
                NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                object = [object MR_inContext:managedObjectContext];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
            }
            completionHandler(error, object, signInRequired);
        } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [ff queueUpdateObj:object];
            }
            completionHandler(error, object, NO);
        }];
    }];
    return operation;
}

- (NSBlockOperation *)deleteOperation:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler
{
    NSParameterAssert([[object valueForKey:@"ffUrl"] length] > 0);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [ff deleteObj:object onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            BOOL signInRequired = NO;
            if (error) {
                if (response.statusCode == 401) {
                    signInRequired = YES;
                } else {
                    [WMUtilities logError:error];
                }
            }
            if (completionHandler) {
                completionHandler(error, object, signInRequired);
            }
        } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [ff queueDeleteObj:object];
            }
            if (completionHandler) {
                completionHandler(error, object, NO);
            }
        }];
    }];
    return operation;
}

- (NSBlockOperation *)loadBlobsOperation:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [ff loadBlobsForObj:object onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            BOOL signInRequired = NO;
            if (error) {
                if (response.statusCode == 401) {
                    signInRequired = YES;
                }
                [WMUtilities logError:error];
            } else if ([object isKindOfClass:[NSManagedObject class]]) {
                NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                object = [object MR_inContext:managedObjectContext];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
            }
            completionHandler(error, object, signInRequired);
        }];
    }];
    return operation;
}

#pragma mark - Grab bags

- (NSBlockOperation *)grabBagAdd:(NSManagedObjectID *)itemObjectID
                              to:(NSManagedObjectID *)objectObjectID
                     grabBagName:(NSString *)name
                              ff:(WMFatFractal *)ff
                      addToQueue:(BOOL)addToQueue
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        id item = [managedObjectContext objectWithID:itemObjectID];
        id object = [managedObjectContext objectWithID:objectObjectID];
        NSString *itemFFURL = [item valueForKey:@"ffUrl"];
        NSString *objectFFURL = [object valueForKey:@"ffUrl"];
        NSParameterAssert([itemFFURL length] > 0);
        NSParameterAssert([objectFFURL length] > 0);
        [ff queueGrabBagAddItemAtUri:itemFFURL toObjAtUri:objectFFURL grabBagName:name];
    }];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

- (NSBlockOperation *)grabBagRemove:(NSManagedObjectID *)itemObjectID
                                 to:(NSManagedObjectID *)objectObjectID
                        grabBagName:(NSString *)name
                                 ff:(WMFatFractal *)ff
                         addToQueue:(BOOL)addToQueue
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        id item = [managedObjectContext objectWithID:itemObjectID];
        id object = [managedObjectContext objectWithID:objectObjectID];
        NSString *itemFFURL = [item valueForKey:@"ffUrl"];
        NSString *objectFFURL = [object valueForKey:@"ffUrl"];
        NSParameterAssert([itemFFURL length] > 0);
        NSParameterAssert([objectFFURL length] > 0);
        [ff queueGrabBagRemoveItemAtUri:itemFFURL fromObjAtUri:objectFFURL grabBagName:name];
    }];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

- (NSBlockOperation *)grabBagAddItemAtUri:(NSString *)itemUri
                               toObjAtUri:(NSString *)objUri
                              grabBagName:(NSString *)gbName
                                       ff:(WMFatFractal *)ff
                               addToQueue:(BOOL)addToQueue
                        completionHandler:(WMOperationCallback)completionHandler
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [ff grabBagAddItemAtFfUrl:itemUri
                     toObjAtFfUrl:objUri
                      grabBagName:gbName
                       onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                           if (completionHandler) {
                               completionHandler(error, object, NO);
                           }
                       }];
    }];
    if (addToQueue) {
        [_operationQueue addOperation:operation];
    } else {
        [_operationCache addObject:operation];
    }
    return operation;
}

- (void)queuePatientGrabBagAdd:(WMPatient *)patient ff:(WMFatFractal *)ff
{
    for (WMBradenScale *bradenScale in patient.bradenScales) {
        [ff queueGrabBagAddItemAtUri:bradenScale.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.bradenScales];
    }
    for (WMCarePlanGroup *carePlanGroup in patient.carePlanGroups) {
        [ff queueGrabBagAddItemAtUri:carePlanGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.carePlanGroups];
    }
    for (WMDeviceGroup *deviceGroup in patient.deviceGroups) {
        [ff queueGrabBagAddItemAtUri:deviceGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.deviceGroups];
    }
    for (WMId *anId in patient.ids) {
        [ff queueGrabBagAddItemAtUri:anId.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.ids];
    }
    for (WMMedicationGroup *medicationGroup in patient.medicationGroups) {
        [ff queueGrabBagAddItemAtUri:medicationGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.medicationGroups];
    }
    for (WMPatientConsultant *patientConsultant in patient.patientConsultants) {
        [ff queueGrabBagAddItemAtUri:patientConsultant.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.patientConsultants];
    }
    for (WMPsychoSocialGroup *psychosocialGroup in patient.psychosocialGroups) {
        [ff queueGrabBagAddItemAtUri:psychosocialGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.psychosocialGroups];
    }
    for (WMSkinAssessmentGroup *skinAssessmentGroup in patient.skinAssessmentGroups) {
        [ff queueGrabBagAddItemAtUri:skinAssessmentGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.skinAssessmentGroups];
    }
    for (WMWound *wound in patient.wounds) {
        [ff queueGrabBagAddItemAtUri:wound.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.wounds];
    }
}

- (void)queueBradenScaleGrabBagAdd:(WMBradenScale *)bradenScale  ff:(WMFatFractal *)ff
{
    for (WMBradenSection *bradenSection in bradenScale.sections) {
        [ff queueGrabBagAddItemAtUri:bradenSection.ffUrl toObjAtUri:bradenScale.ffUrl grabBagName:WMBradenScaleRelationships.sections];
    }
}

- (void)queueBradenSectionGrabBagAdd:(WMBradenSection *)bradenSection  ff:(WMFatFractal *)ff
{
    for (WMBradenCell *cell in bradenSection.cells) {
        [ff queueGrabBagAddItemAtUri:cell.ffUrl toObjAtUri:bradenSection.ffUrl grabBagName:WMBradenSectionRelationships.cells];
    }
}

- (void)queueCarePlanGroupGrabBagAdd:(WMCarePlanGroup *)carePlanGroup ff:(WMFatFractal *)ff
{
    for (WMCarePlanInterventionEvent *event in carePlanGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:carePlanGroup.ffUrl grabBagName:WMCarePlanGroupRelationships.interventionEvents];
    }
    for (WMCarePlanValue *value in carePlanGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:carePlanGroup.ffUrl grabBagName:WMCarePlanGroupRelationships.values];
    }
}

- (void)queueDeviceGroupGrabBagAdd:(WMDeviceGroup *)deviceGroup ff:(WMFatFractal *)ff
{
    for (WMDeviceInterventionEvent *event in deviceGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:deviceGroup.ffUrl grabBagName:WMDeviceGroupRelationships.interventionEvents];
    }
    for (WMDeviceValue *value in deviceGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:deviceGroup.ffUrl grabBagName:WMDeviceGroupRelationships.values];
    }
}

- (void)queueMedicationGroupGrabBagAdd:(WMMedicationGroup *)medicationGroup ff:(WMFatFractal *)ff
{
    for (WMInterventionEvent *event in medicationGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:medicationGroup.ffUrl grabBagName:WMMedicationGroupRelationships.interventionEvents];
    }
    for (WMMedication *medication in medicationGroup.medications) {
        [ff queueGrabBagAddItemAtUri:medication.ffUrl toObjAtUri:medicationGroup.ffUrl grabBagName:WMMedicationGroupRelationships.medications];
    }
}

- (void)queuePsychoSocialGroupGrabBagAdd:(WMPsychoSocialGroup *)psychoSocialGroup ff:(WMFatFractal *)ff
{
    for (WMInterventionEvent *event in psychoSocialGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:psychoSocialGroup.ffUrl grabBagName:WMPsychoSocialGroupRelationships.interventionEvents];
    }
    for (WMPsychoSocialValue *value in psychoSocialGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:psychoSocialGroup.ffUrl grabBagName:WMPsychoSocialGroupRelationships.values];
    }
}

- (void)queueSkinAssessmentGroupGrabBagAdd:(WMSkinAssessmentGroup *)skinAssessmentGroup ff:(WMFatFractal *)ff
{
    for (WMInterventionEvent *event in skinAssessmentGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.interventionEvents];
    }
    for (WMSkinAssessmentValue *value in skinAssessmentGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.values];
    }
}

- (void)queueWoundGrabBagAdd:(WMWound *)wound ff:(WMFatFractal *)ff
{
    for (WMWoundMeasurementGroup *measurementGroup in wound.measurementGroups) {
        [ff queueGrabBagAddItemAtUri:measurementGroup.ffUrl toObjAtUri:wound.ffUrl grabBagName:WMWoundRelationships.measurementGroups];
    }
    for (WMWoundPhoto *woundPhoto in wound.photos) {
        [ff queueGrabBagAddItemAtUri:woundPhoto.ffUrl toObjAtUri:wound.ffUrl grabBagName:WMWoundRelationships.photos];
    }
    for (WMWoundPositionValue *value in wound.positionValues) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:wound.ffUrl grabBagName:WMWoundRelationships.positionValues];
    }
    for (WMWoundTreatmentGroup *treatmentGroup in wound.treatmentGroups) {
        [ff queueGrabBagAddItemAtUri:treatmentGroup.ffUrl toObjAtUri:wound.ffUrl grabBagName:WMWoundRelationships.treatmentGroups];
    }
}

- (void)queueWoundMeasurementGroupGrabBagAdd:(WMWoundMeasurementGroup *)woundMeasurementGroup ff:(WMFatFractal *)ff
{
    for (WMInterventionEvent *event in woundMeasurementGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:woundMeasurementGroup.ffUrl grabBagName:WMWoundMeasurementGroupRelationships.interventionEvents];
    }
    for (WMWoundMeasurementValue *value in woundMeasurementGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:woundMeasurementGroup.ffUrl grabBagName:WMWoundMeasurementGroupRelationships.values];
    }
}

- (void)queueWoundPhotoGrabBagAdd:(WMWoundPhoto *)woundPhoto ff:(WMFatFractal *)ff
{
    for (WMWoundMeasurementGroup *measurementGroup in woundPhoto.measurementGroups) {
        [ff queueGrabBagAddItemAtUri:measurementGroup.ffUrl toObjAtUri:woundPhoto.ffUrl grabBagName:WMWoundPhotoRelationships.measurementGroups];
    }
    for (WMPhoto *photo in woundPhoto.photos) {
        [ff queueGrabBagAddItemAtUri:photo.ffUrl toObjAtUri:woundPhoto.ffUrl grabBagName:WMWoundPhotoRelationships.photos];
    }
}

- (void)queueWoundTreatmentGroupGrabBagAdd:(WMWoundTreatmentGroup *)woundTreatmentGroup ff:(WMFatFractal *)ff
{
    for (WMInterventionEvent *event in woundTreatmentGroup.interventionEvents) {
        [ff queueGrabBagAddItemAtUri:event.ffUrl toObjAtUri:woundTreatmentGroup.ffUrl grabBagName:WMWoundTreatmentGroupRelationships.interventionEvents];
    }
    for (WMWoundTreatmentValue *value in woundTreatmentGroup.values) {
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:woundTreatmentGroup.ffUrl grabBagName:WMWoundTreatmentGroupRelationships.values];
    }
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
