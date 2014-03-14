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
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

static const NSInteger WMMaxQueueConcurrency = 24;

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
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                        if (participant.team) {
                            [ff queueGrabBagAddItemAtUri:participant.ffUrl toObjAtUri:participant.team.ffUrl grabBagName:@"participants"];
                        }
                    }];
                }
            }];
        } else {
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMParticipant entityName]];
            [ff createObj:participant atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                    }];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff queueCreateObj:participant atUri:ffUrl];
            }];
        }
    }];
    [_operationQueue addOperation:participantOperation];
    WMTeam *team = participant.team;
    if (nil != team) {
        NSManagedObjectID *teamD = [team objectID];
        NSBlockOperation *teamOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMTeam *team = (WMTeam *)[managedObjectContext objectWithID:teamD];
            if (team.ffUrl) {
                [ff updateObj:team onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        if (response.statusCode == 401) {
                            DLog(@"Participant not logged in: %@", error);
                        }
                        [WMUtilities logError:error];
                    } else {
                        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                        }];
                    }
                }];
            } else {
                NSString *ffUrl = [NSString stringWithFormat:@"/%@", [WMTeam entityName]];
                [ff createObj:team atUri:ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                        }];
                    }
                } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    [ff queueCreateObj:team atUri:ffUrl];
                }];
            }
        }];
        [participantOperation addDependency:teamOperation];
        [_operationQueue addOperation:teamOperation];
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
        }];
    }];
    [participantOperation addDependency:personOperation];
    [_operationQueue addOperation:personOperation];
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
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                    }];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff queueCreateObj:address atUri:ffUrl];
            }];
        }];
        [personOperation addDependency:addressOperation];
        [_operationQueue addOperation:addressOperation];
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
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                    }];
                }
            } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff queueCreateObj:telecom atUri:ffUrl];
            }];
        }];
        [personOperation addDependency:telecomOperation];
        [_operationQueue addOperation:telecomOperation];
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
