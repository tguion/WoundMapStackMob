//
//  WMFatFractalManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractalManager.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMTeam.h"
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

static const NSInteger WMMaxQueueConcurrency = 24;

typedef void (^WMOperationCallback)(NSError *error, NSManagedObject *object);

@interface WMFatFractalManager ()

@property (nonatomic) NSNumber *lastRefreshTime;
@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableArray *operationCache;

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
    
    _operationCache = [[NSMutableArray alloc] init];
    
    return self;
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
    } else {
        CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
        [self fetchPatients:coreDataHelper.context];
    }
}

#pragma mark - Fetch

- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *patientsExisting = [WMPatient MR_findAllInContext:managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
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
        }
    }];
}

- (void)fetchCollection:(NSString *)collection
                  query:(NSString *)query
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
             onComplete:(FFHttpMethodCompletion)onComplete
{
    NSString *queryString = [NSString stringWithFormat:@"/%@/(updatedAt gt %@ and %@)?depthGb=1&depthRef=1", collection, self.lastRefreshTimeMap[collection], query];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [[[ff newReadRequest] prepareGetFromCollection:queryString] executeAsyncWithBlock:^(FFReadResponse *response) {
        if (response.error) {
            [WMUtilities logError:response.error];
            onComplete(response.error, response.objs, response.httpResponse);
        } else {
            [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
                onComplete(response.error, response.objs, response.httpResponse);
            }];
        }
    }];
}

#pragma mark - Operations

- (void)clearOperationCache
{
    [_operationCache removeAllObjects];
}

- (void)submitOperationsToQueue
{
    [_operationQueue addOperations:_operationCache waitUntilFinished:NO];
}

- (void)registerParticipant:(WMParticipant *)participant password:(NSString *)password completionHandler:(void (^)(NSError *))handler
{
    NSParameterAssert(nil == participant.ffUrl);
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff registerUser:participant password:password onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [self createParticipant:participant];
        handler(error);
    }];
}

// create participant, with reference objects person and team
- (void)createParticipant:(WMParticipant *)participant
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectID *participantID = [participant objectID];
    NSBlockOperation *participantOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMParticipant *participant = (WMParticipant *)[managedObjectContext objectWithID:participantID];
        if (participant.ffUrl) {
            [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    if (response.statusCode == 401) {
                        DLog(@"Participant not logged in: %@", error);
                    }
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    if (participant.team) {
                        [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                    }
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueUpdateObj:participant];
                    if (participant.team) {
                        [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                    }
                }
            }];
        } else {
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMParticipant entityName]];
            [ff createObj:participant atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    if (participant.team) {
                        [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                    }
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueCreateObj:participant atUri:ffUrl];
                    if (participant.team) {
                        [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                    }
                }
            }];
        }
    }];
    [_operationCache addObject:participantOperation];
    WMTeam *team = participant.team;
    if (nil != team) {
        NSManagedObjectID *teamID = [team objectID];
        NSBlockOperation *teamOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMTeam *team = (WMTeam *)[managedObjectContext objectWithID:teamID];
            if (team.ffUrl) {
                [ff updateObj:team onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                    }
                } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        [ff queueUpdateObj:team];
                    }
                }];
            } else {
                NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMTeam entityName]];
                [ff createObj:team atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                    }
                } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        [ff queueCreateObj:team atUri:ffUrl];
                    }
                }];
            }
        }];
        [participantOperation addDependency:teamOperation];
        [_operationCache addObject:teamOperation];
    }
    WMPerson *person = participant.person;
    NSManagedObjectID *personID = [person objectID];
    NSBlockOperation *personOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMPerson *person = (WMPerson *)[managedObjectContext objectWithID:personID];
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMPerson entityName]];
        [ff createObj:person atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    for (WMAddress *address in person.addresses) {
                        [ff queueGrabBagAddItemAtUri:address.ffUrl toObjAtUri:person.ffUrl grabBagName:@"addresses"];
                    }
                    for (WMTelecom *telecom in person.telecoms) {
                        [ff queueGrabBagAddItemAtUri:telecom.ffUrl toObjAtUri:person.ffUrl grabBagName:@"telecoms"];
                    }
                }];
            }
        } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff queueCreateObj:person atUri:ffUrl];
            for (WMAddress *address in person.addresses) {
                [ff queueGrabBagAddItemAtUri:address.ffUrl toObjAtUri:person.ffUrl grabBagName:@"addresses"];
            }
            for (WMTelecom *telecom in person.telecoms) {
                [ff queueGrabBagAddItemAtUri:telecom.ffUrl toObjAtUri:person.ffUrl grabBagName:@"telecoms"];
            }
        }];
    }];
    [participantOperation addDependency:personOperation];
    [_operationCache addObject:personOperation];
    for (WMAddress *address in person.addresses) {
        NSManagedObjectID *addressID = [address objectID];
        NSBlockOperation *addressOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMAddress *address = (WMAddress *)[managedObjectContext objectWithID:addressID];
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMAddress entityName]];
            [ff createObj:address atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueCreateObj:address atUri:ffUrl];
                }
            }];
        }];
        [personOperation addDependency:addressOperation];
        [_operationCache addObject:addressOperation];
    }
    for (WMTelecom *telecom in person.telecoms) {
        NSManagedObjectID *telecomID = [telecom objectID];
        NSBlockOperation *telecomOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMTelecom *telecom = (WMTelecom *)[managedObjectContext objectWithID:telecomID];
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMTelecom entityName]];
            [ff createObj:telecom atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueCreateObj:telecom atUri:ffUrl];
                }
            }];
        }];
        [personOperation addDependency:telecomOperation];
        [_operationCache addObject:telecomOperation];
    }
}

- (void)addParticipantToTeam:(WMParticipant *)participant
{
    NSParameterAssert([participant.ffUrl length] > 0);
    NSParameterAssert(nil != participant.team);
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMTeam *team = participant.team;
    NSManagedObjectID *teamID = [team objectID];
    NSBlockOperation *teamOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMTeam *team = (WMTeam *)[managedObjectContext objectWithID:teamID];
        if (team.ffUrl) {
            [ff updateObj:team onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueUpdateObj:team];
                    [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                }
            }];
        } else {
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMTeam entityName]];
            [ff createObj:team atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff queueCreateObj:team atUri:ffUrl];
                    [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                }
            }];
        }
    }];
    [_operationCache addObject:teamOperation];
}

- (void)createPatient:(WMPatient *)patient
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    NSBlockOperation *patientOperation = [weakSelf createOperation:patient collection:[WMPatient entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
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
    }];
    [_operationCache addObject:patientOperation];
    // bradenScales
    for (WMBradenScale *bradenScale in patient.bradenScales) {
        NSBlockOperation *bradenScaleOperation = [weakSelf createOperation:bradenScale collection:[WMBradenScale entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueBradenScaleGrabBagAdd:(WMBradenScale *)object ff:ff];
        }];
        [patientOperation addDependency:bradenScaleOperation];
        [_operationCache addObject:bradenScaleOperation];
        // sections
        for (WMBradenSection *section in bradenScale.sections) {
            NSBlockOperation *sectionOperation = [weakSelf createOperation:section collection:[WMBradenSection entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [bradenScaleOperation addDependency:sectionOperation];
            [_operationCache addObject:sectionOperation];
            // cells
            for (WMBradenCell *cell in section.cells) {
                NSBlockOperation *cellOperation = [weakSelf createOperation:cell collection:[WMBradenCell entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                    // nothing
                }];
                [sectionOperation addDependency:cellOperation];
                [_operationCache addObject:cellOperation];
            }
        }
    }
    // carePlanGroups
    for (WMCarePlanGroup *carePlanGroup in patient.carePlanGroups) {
        NSBlockOperation *carePlanGroupOperation = [weakSelf createOperation:carePlanGroup collection:[WMCarePlanGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueCarePlanGroupGrabBagAdd:(WMCarePlanGroup *)object ff:ff];
        }];
        [patientOperation addDependency:carePlanGroupOperation];
        [_operationCache addObject:carePlanGroupOperation];
        // interventionEvents
        for (WMCarePlanInterventionEvent *event in carePlanGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [carePlanGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMCarePlanValue *value in carePlanGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMCarePlanValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [carePlanGroupOperation addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // deviceGroups
    for (WMDeviceGroup *deviceGroup in patient.deviceGroups) {
        NSBlockOperation *deviceGroupOperation = [weakSelf createOperation:deviceGroup collection:[WMDeviceGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueDeviceGroupGrabBagAdd:(WMDeviceGroup *)object ff:ff];
        }];
        [patientOperation addDependency:deviceGroupOperation];
        [_operationCache addObject:deviceGroupOperation];
        // interventionEvents
        for (WMDeviceInterventionEvent *event in deviceGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [deviceGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMDeviceValue *value in deviceGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMDeviceValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [deviceGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // ids
    for (WMId *anId in patient.ids) {
        NSBlockOperation *anIdOperation = [weakSelf createOperation:anId collection:[WMId entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            // nothing
        }];
        [patientOperation addDependency:anIdOperation];
        [_operationCache addObject:anIdOperation];
    }
    // medicationGroups
    for (WMMedicationGroup *medicationGroup in patient.medicationGroups) {
        NSBlockOperation *medicationGroupOperation = [weakSelf createOperation:medicationGroup collection:[WMMedicationGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueMedicationGroupGrabBagAdd:(WMMedicationGroup *)object ff:ff];
        }];
        [patientOperation addDependency:medicationGroupOperation];
        [_operationCache addObject:medicationGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in medicationGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [medicationGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:medicationGroupOperation];
        }
        // medications should have been loaded in the seed
    }
    // patientConsultants
    for (WMPatientConsultant *patientConsultant in patient.patientConsultants) {
        NSBlockOperation *patientConsultantOperation = [weakSelf createOperation:patientConsultant collection:[WMPatientConsultant entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            // nothing
        }];
        [patientOperation addDependency:patientConsultantOperation];
        [_operationCache addObject:patientConsultantOperation];
    }
    // psychosocialGroups
    for (WMPsychoSocialGroup *psychosocialGroup in patient.psychosocialGroups) {
        NSBlockOperation *psychosocialGroupOperation = [weakSelf createOperation:psychosocialGroup collection:[WMPsychoSocialGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queuePsychoSocialGroupGrabBagAdd:(WMPsychoSocialGroup *)object ff:ff];
        }];
        [patientOperation addDependency:psychosocialGroupOperation];
        [_operationCache addObject:psychosocialGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in psychosocialGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [psychosocialGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMPsychoSocialValue *value in psychosocialGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMDeviceValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [psychosocialGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // skinAssessmentGroups
    for (WMSkinAssessmentGroup *skinAssessmentGroup in patient.skinAssessmentGroups) {
        NSBlockOperation *skinAssessmentGroupOperation = [weakSelf createOperation:skinAssessmentGroup collection:[WMSkinAssessmentGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueSkinAssessmentGroupGrabBagAdd:(WMSkinAssessmentGroup *)object ff:ff];
        }];
        [patientOperation addDependency:skinAssessmentGroupOperation];
        [_operationCache addObject:skinAssessmentGroupOperation];
        // interventionEvents
        for (WMInterventionEvent *event in skinAssessmentGroup.interventionEvents) {
            NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [skinAssessmentGroupOperation addDependency:interventionEventOperation];
            [_operationCache addObject:interventionEventOperation];
        }
        // values
        for (WMSkinAssessmentValue *value in skinAssessmentGroup.values) {
            NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMSkinAssessmentValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [skinAssessmentGroupOperation   addDependency:valueOperation];
            [_operationCache addObject:valueOperation];
        }
    }
    // wounds
    for (WMWound *wound in patient.wounds) {
        NSBlockOperation *woundOperation = [weakSelf createOperation:wound collection:[WMWound entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
            [weakSelf queueWoundGrabBagAdd:(WMWound *)object ff:ff];
        }];
        [patientOperation addDependency:woundOperation];
        [_operationCache addObject:woundOperation];
        // measurementGroups
        for (WMWoundMeasurementGroup *measurementGroup in wound.measurementGroups) {
            NSBlockOperation *measurementGroupOperation = [weakSelf createOperation:measurementGroup collection:[WMWoundMeasurementGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                [weakSelf queueWoundMeasurementGroupGrabBagAdd:(WMWoundMeasurementGroup *)object ff:ff];
            }];
            [woundOperation addDependency:measurementGroupOperation];
            [_operationCache addObject:measurementGroupOperation];
            // interventionEvents
            for (WMInterventionEvent *event in measurementGroup.interventionEvents) {
                NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                    // nothing
                }];
                [measurementGroupOperation addDependency:interventionEventOperation];
                [_operationCache addObject:interventionEventOperation];
            }
            // values
            for (WMWoundMeasurementValue *value in measurementGroup.values) {
                NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMWoundMeasurementValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                    // nothing
                }];
                [measurementGroupOperation addDependency:valueOperation];
                [_operationCache addObject:valueOperation];
            }
        }
        // photos
        for (WMWoundPhoto *woundPhoto in wound.photos) {
            NSBlockOperation *woundPhotoOperation = [weakSelf createOperation:woundPhoto collection:[WMWoundPhoto entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                [weakSelf queueWoundPhotoGrabBagAdd:(WMWoundPhoto *)object ff:ff];
            }];
            [woundOperation addDependency:woundPhotoOperation];
            [_operationCache addObject:woundPhotoOperation];
            // measurementGroups - already handled with wound
            // photos
            for (WMPhoto *photo in woundPhoto.photos) {
                NSBlockOperation *photoOperation = [weakSelf createOperation:photo collection:[WMPhoto entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
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
            NSBlockOperation *woundPositionOperation = [weakSelf createOperation:value collection:[WMWoundPositionValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                // nothing
            }];
            [woundOperation addDependency:woundPositionOperation];
            [_operationCache addObject:woundPositionOperation];
        }
        // treatmentGroups
        for (WMWoundTreatmentGroup *treatmentGroup in wound.treatmentGroups) {
            NSBlockOperation *treatmentGroupOperation = [weakSelf createOperation:treatmentGroup collection:[WMWoundTreatmentGroup entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                [weakSelf queueWoundTreatmentGroupGrabBagAdd:(WMWoundTreatmentGroup *)object ff:ff];
            }];
            [woundOperation addDependency:treatmentGroupOperation];
            [_operationCache addObject:treatmentGroupOperation];
            // interventionEvents
            for (WMInterventionEvent *event in treatmentGroup.interventionEvents) {
                NSBlockOperation *interventionEventOperation = [weakSelf createOperation:event collection:[WMInterventionEvent entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                    // nothing
                }];
                [treatmentGroupOperation addDependency:interventionEventOperation];
                [_operationCache addObject:interventionEventOperation];
            }
            // values
            for (WMWoundTreatmentValue *value in treatmentGroup.values) {
                NSBlockOperation *valueOperation = [weakSelf createOperation:value collection:[WMWoundTreatmentValue entityName] ff:ff block:^(NSError *error, NSManagedObject *object) {
                    // nothing
                }];
                [treatmentGroupOperation addDependency:valueOperation];
                [_operationCache addObject:valueOperation];
            }
        }
    }
}

- (NSBlockOperation *)createOperation:(NSManagedObject *)object collection:(NSString *)collection ff:(WMFatFractal *)ff block:(WMOperationCallback)block
{
    NSParameterAssert([[object valueForKey:@"ffUrl"] length] == 0);
    NSManagedObjectID *objectID = [object objectID];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSManagedObject *object = [managedObjectContext objectWithID:objectID];
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        [ff createObj:object atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
            }
            block(error, object);
        } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [ff queueCreateObj:object atUri:ffUrl];
            }
            block(error, object);
        }];
    }];
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
