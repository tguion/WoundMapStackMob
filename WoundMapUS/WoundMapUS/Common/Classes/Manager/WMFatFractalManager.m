//
//  WMFatFractalManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractalManager.h"
#import "WMPatient.h"
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMFatFractalManager ()

@property (nonatomic) NSNumber *lastRefreshTime;
@property (nonatomic) NSMutableDictionary *lastRefreshTimeMap;

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
