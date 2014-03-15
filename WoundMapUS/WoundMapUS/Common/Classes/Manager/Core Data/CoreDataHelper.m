//
//  CoreDataHelper.m
//  Grocery Cloud
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"
#import "Faulter.h"
#import "WMPatient.h"
#import "WMBradenCare.h"
#import "WMWoundType.h"
#import "WMDefinition.h"
#import "WMInstruction.h"
#import "IAPProduct.h"
#import "WMUtilities.h"
#import "WMNetworkReachability.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface CoreDataHelper () <UIAlertViewDelegate>

@property (nonatomic, strong) WMNetworkReachability *networkMonitor;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) UIAlertView *networkReachabilityAlertView;
- (void)alertUserNetworkReachabilityChanged:(WMNetworkStatus)status;

- (void)seedLocalDatabase;

@end

@implementation CoreDataHelper

#define debug 1

+ (CoreDataHelper *)sharedInstance
{
    static CoreDataHelper *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[CoreDataHelper alloc] init];
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

NSString *storeFilename = @"WoundMap.sqlite";
NSString *localStoreFilename = @"WoundMapLocal.sqlite";

#pragma mark - Alerts

- (void)alertUserNetworkReachabilityChanged:(WMNetworkStatus)status
{
    if (nil != _networkReachabilityAlertView) {
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
            message = @"The network is no longer reachable. You will not receive updates from team members, nor team members have access to patient data you enter until the network becomes reachable again.";
            break;
        }
        case WMNetworkStatusReachable: {
            message = @"The network is now reachable. You will receive updates from team members, and team members will have access to patient data you entered while the network was unavailable.";
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
    
    [self setupCoreData];
    // monitor network
    __weak __typeof(self) weakSelf = self;
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

- (NSManagedObjectModel *)model
{
    return [NSManagedObjectModel defaultManagedObjectModel];
}

- (NSPersistentStoreCoordinator *)coordinator
{
    return [NSPersistentStoreCoordinator defaultStoreCoordinator];
}

- (void)setupCoreData
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSPersistentStore MR_urlForStoreName:storeFilename]];
    _localStore = [self.coordinator MR_addSqliteStoreNamed:[NSPersistentStore MR_urlForStoreName:localStoreFilename] withOptions:nil configuration:@"Local"];
    [self seedLocalDatabase];

}

- (WMNetworkReachability *)networkReachability
{
    if (nil == _networkMonitor) {
        _networkMonitor = [[WMNetworkReachability alloc] init];
    }
    return _networkMonitor;
}

#pragma mark - Save

- (BOOL)saveContext:(NSManagedObjectContext *)managedObjectContext
{
    NSSet *updatedObjects = [managedObjectContext updatedObjects];
    NSSet *deletedObjects = [managedObjectContext deletedObjects];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffManager = [WMFatFractalManager sharedInstance];
    BOOL operationCacheIsEmpty = ffManager.isCacheEmpty;
    __block BOOL _signInRequired = NO;
    // now update backend - deletes
    for (NSManagedObject *deletedObject in deletedObjects) {
        if ([deletedObject valueForKey:@"ffUrl"]) {
            [ffManager deleteObject:deletedObject ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                _signInRequired = signInRequired;
            }];
        }
    }
    // now save local
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        // now update backend - inserts need to be handled separately
        // now update backend - updates
        for (NSManagedObject *updatedObject in updatedObjects) {
            [ffManager updateObject:updatedObject ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                _signInRequired = signInRequired;
            }];
        }
    }];
    if (operationCacheIsEmpty && !_signInRequired) {
        [ffManager submitOperationsToQueue];
    }
    return _signInRequired;
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

- (void)seedLocalDatabase
{
    NSManagedObjectContext *managedObjectContext = self.parentContext;
    NSPersistentStore *store = self.localStore;
    [managedObjectContext performBlock:^{
        [WMBradenCare seedDatabase:managedObjectContext persistentStore:store];// TODO remove store parameters
        [WMDefinition seedDatabase:managedObjectContext];
        [WMWoundType seedDatabase:managedObjectContext persistentStore:store];
        [IAPProduct seedDatabase:managedObjectContext persistentStore:store];
        [WMInstruction seedDatabase:managedObjectContext];
        [managedObjectContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (nil != error) {
                [WMUtilities logError:error];
            }
        }];
    }];
}

@end
