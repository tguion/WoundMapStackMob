//
//  CoreDataHelper.m
//  Grocery Cloud
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "Faulter.h"
#import "WMUtilities.h"
#import "WMNetworkReachability.h"
#import "WMUserDefaultsManager.h"
#import "WMSeedDatabaseManager.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface CoreDataHelper () <UIAlertViewDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) UIAlertView *networkReachabilityAlertView;
- (void)alertUserNetworkReachabilityChanged:(WMNetworkStatus)status;
@property (nonatomic) BOOL blockNetworkReachabiltyAlert;

@end

@implementation CoreDataHelper

#define debug 1

+ (CoreDataHelper *)sharedInstance
{
    static CoreDataHelper *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[CoreDataHelper alloc] init];
        SharedInstance.blockNetworkReachabiltyAlert = YES;
    });
    return SharedInstance;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMNetworkReachability *)networkMonitor
{
    if (nil == _networkMonitor) {
        _networkMonitor = [WMNetworkReachability sharedInstance];
    }
    return _networkMonitor;
}

#pragma mark - FILES

NSString *storeFilenameWithoutExtension = @"WoundMap";
NSString *storeFilename = @"WoundMap.sqlite";
NSString *localStoreFilename = @"WoundMapLocal.sqlite";

#pragma mark - Alerts

- (void)alertUserNetworkReachabilityChanged:(WMNetworkStatus)status
{
    if (nil != _networkReachabilityAlertView) {
        return;
    }
    // else don't show this on start up
    if (_blockNetworkReachabiltyAlert) {
        _blockNetworkReachabiltyAlert = NO;
        return;
    }
    // else
    NSString *title = @"Network reachability changed";
    NSString *message = nil;
    switch (status) {
        case WMNetworkStatusUnknown: {
            message = @"Network reachability in unknown";
            break;
        }
        case WMNetworkStatusNotReachable: {
            message = @"The network is no longer reachable. You will not receive updates from team members, nor will team members have access to patient data you enter until the network becomes reachable again.";
            break;
        }
        case WMNetworkStatusReachable: {
            message = @"The network is now reachable. Your patient records will now be updated through our secure network.  We recommend that you use a wifi connection whenever possible.";
            break;
        }
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
    _networkReachabilityAlertView = alertView;
}

#pragma mark - SETUP

- (id)init
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // monitor network
    __weak __typeof(&*self)weakSelf = self;
    [self.networkMonitor setNetworkStatusChangeBlock:^(WMNetworkStatus status) {
        [weakSelf alertUserNetworkReachabilityChanged:status];
        // other stuff ??
        switch (status) {
            case WMNetworkStatusUnknown:
                break;
            case WMNetworkStatusNotReachable:
                break;
            case WMNetworkStatusReachable:
                break;
        }
    }];

    return self;
}

- (void)setupCoreData
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL didMoveDatabase = [self moveStoreFromBundle];
    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSPersistentStore MR_urlForStoreName:storeFilename]];
    if (didMoveDatabase) {
        // must remove that we have navigation entities
        [self unmarkBackendDataAcquiredForEntityName:[WMNavigationTrack entityName]];
        [self unmarkBackendDataAcquiredForEntityName:[WMNavigationStage entityName]];
        [self unmarkBackendDataAcquiredForEntityName:[WMNavigationNode entityName]];
    }
}

- (BOOL)moveStoreFromBundle
{
    BOOL didMoveDatabase = NO;
    NSURL *destinationURL = [NSPersistentStore MR_urlForStoreName:storeFilename];
    NSString *destinationPath = destinationURL.path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    // If the expected store doesn't exist, copy the default store.
    NSArray *extensions = @[@"sqlite", @"sqlite-shm", @"sqlite-wal"];
    for (NSString *extension in extensions) {
        destinationPath = [[destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
        if (![fileManager fileExistsAtPath:destinationPath]) {
            [fileManager createDirectoryAtPath:[destinationPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                [WMUtilities logError:error];
            }
            NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:storeFilenameWithoutExtension withExtension:extension];
            NSString *sourcePath = sourceURL.path;
            if (sourceURL) {
                [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    didMoveDatabase = YES;
                    _seedDatabaseFound = YES;
                }
            }
        } else {
            _seedDatabaseFound = YES;
        }
    }
    return didMoveDatabase;
}

#pragma mark - Store metadata

- (void)markBackendDataAcquiredForEntityName:(NSString *)entityName
{
    NSMutableDictionary *metadata = [[self.coordinator metadataForPersistentStore:self.store] mutableCopy];
    metadata[entityName] = @YES;
    [self.coordinator setMetadata:metadata forPersistentStore:self.store];
}

- (void)unmarkBackendDataAcquiredForEntityName:(NSString *)entityName
{
    NSMutableDictionary *metadata = [[self.coordinator metadataForPersistentStore:self.store] mutableCopy];
    [metadata removeObjectForKey:entityName];
    [self.coordinator setMetadata:metadata forPersistentStore:self.store];
}

- (BOOL)isBackendDataAcquiredForEntityName:(NSString *)entityName
{
    return (nil != [self.coordinator metadataForPersistentStore:self.store][entityName]);
}

#pragma mark Network Reachability

- (WMNetworkReachability *)networkReachability
{
    if (nil == _networkMonitor) {
        _networkMonitor = [[WMNetworkReachability alloc] init];
    }
    return _networkMonitor;
}

#pragma mark - Accessors

- (NSManagedObjectContext *)context
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSManagedObjectContext *)parentContext
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

- (NSManagedObjectModel *)model
{
    return [NSManagedObjectModel MR_defaultManagedObjectModel];
}

- (NSPersistentStoreCoordinator *)coordinator
{
    return [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
}

- (NSPersistentStore *)store
{
    return [NSPersistentStore MR_defaultPersistentStore];
}

#pragma mark - Core

- (id<WMFFManagedObject>)ffManagedObjectForCollection:(NSString *)collection guid:(NSString *)guid managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Class aClass = NSClassFromString(collection);
    id<WMFFManagedObject> object = [aClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", [NSString stringWithFormat:@"/ff/Resources/%@", guid]] inContext:managedObjectContext];
    return object;
}

#pragma mark - VALIDATION ERROR HANDLING

- (void)showValidationError:(NSError *)anError
{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;  // holds all errors
        NSString *txt = @""; // the error message text of the alert
        
        // Populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        // Display the error(s)
        if (errors && errors.count > 0) {
            // Build error message text based on errors
            for (NSError * error in errors) {
                NSString *entity =
                [[[error.userInfo objectForKey:@"NSValidationErrorObject"]entity]name];
                
                NSString *property =
                [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:
                               @"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' property is missing (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too soon (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too late (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is invalid (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too long (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too short (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text doesn't match the specified pattern (Code %li).", property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:
                               @"generated validation error (Code %li)", (long)error.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:
                               @"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
            // display error message txt message
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"Validation Error"
             
                                       message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards",txt]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark – DATA IMPORT


@end
