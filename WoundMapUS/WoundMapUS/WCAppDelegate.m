//
//  WCAppDelegate.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "WMWelcomeToWoundMapViewController_iPad.h"
#import "MBProgressHUD.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "WMNavigationCoordinator_iPad.h"
#import "WMParticipant.h"
#import "WMSeedDatabaseManager.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMWoundType.h"
#import "WMUnhandledSilentUpdateNotification.h"
#import "IAPManager.h"
#import "WMPhotoManager.h"
#import "WMUtilities.h"
#import "KeychainItemWrapper.h"
#import <AudioToolbox/AudioToolbox.h>

NSString * const kPatientReferralNotification = @"PatientReferralNotification";
NSString * const kTeamInvitationNotification = @"TeamInvitationNotification";
NSString * const kTeamMemberAddedNotification = @"TeamMemberAddedNotification";
NSString * const kUpdatedContentFromCloudNotification = @"UpdatedContentFromCloudNotification";

NSInteger const kRemoteNotification = 4002;
NSInteger const kSessionTimeoutAlertViewTag = 1000;

// Keychain Identifier
static NSString *keychainIdentifier = @"WoundMapUSKeychain";

@interface WCAppDelegate () <UIAlertViewDelegate>

@property (nonatomic, strong, readwrite) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong, readwrite) WMFatFractal *ff;
@property (nonatomic, strong, readwrite) WMNavigationCoordinator *navigationCoordinator;
@property (strong, nonatomic) NSDictionary *remoteNotification;
@property (strong, nonatomic) UIAlertView *timeOutAlertView;
@property UIBackgroundTaskIdentifier bgTask;
@property (strong, nonatomic) KeychainItemWrapper *keychainItem;

@end

@implementation WCAppDelegate

#define debug 1     // DEBUG

- (KeychainItemWrapper *)keychainItem
{
    if (nil == _keychainItem) {
        // create the KeychainItem singleton
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:keychainIdentifier accessGroup:nil];

    }
    return _keychainItem;
}

- (CoreDataHelper *)coreDataHelper
{
    if (nil == _coreDataHelper) {
        _coreDataHelper = [CoreDataHelper sharedInstance];
    }
    return _coreDataHelper;
}

- (WMFatFractal *)ff
{
    if (nil == _ff) {
        _ff = [WMFatFractal sharedInstance];
    }
    return _ff;
}

- (UINavigationController *)initialViewController
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIViewController *viewController = (isPad ? [[WMWelcomeToWoundMapViewController_iPad alloc] initWithNibName:@"WMWelcomeToWoundMapViewController_iPad" bundle:nil]:[[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil]);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.delegate = self;
    return navigationController;
}

- (void)signOut
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    self.participant = nil;
    [self.navigationCoordinator clearPatientCache];
    _patient2StageMap = nil;
    [ff forgetAllObjs];
    [ff logout];
    [[NSManagedObjectContext MR_defaultContext] reset];
    [[NSManagedObjectContext MR_rootSavingContext] reset];
}

- (void)handleFatFractalSignout
{
    if (nil == _timeOutAlertView) {
        [self.timeOutAlertView show];
    }
}

- (UIAlertView *)timeOutAlertView
{
    if (nil == _timeOutAlertView) {
        _timeOutAlertView = [[UIAlertView alloc] initWithTitle:@"Session Expired"
                                                       message:@"Your session has expired. You will need to sign in again."
                                                      delegate:self
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles:nil];
        _timeOutAlertView.tag = kSessionTimeoutAlertViewTag;
    }
    return _timeOutAlertView;
}

#pragma mark - Memory

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [self.ff forgetAllObjs];
}

#pragma mark - Backend

- (void)saveUserCredentialsInKeychain:(NSString *)userName password:(NSString *)password
{
    KeychainItemWrapper *keychainItem = self.keychainItem;
    [keychainItem setObject:userName forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
    DLog(@"Successfully saved user %@ to keychain after signup.", [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]);
}

- (BOOL)authenticateWithKeychain
{
    BOOL success = NO;

    KeychainItemWrapper *keychainItem = self.keychainItem;
    if ([keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] != nil && ![[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] isEqual:@""]) {
        // authenticated - look up participant
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        
        NSString *username = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
        NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
        
        NSError *error = nil;
        
        // Step 1 - Login with FatFractal by initiating connection with server
        FFUser *ffUser = (FFUser *)[ff loginWithUserName:username andPassword:password error:&error];
        // Step 2 - handle response from ff
        if (error) {
            DLog(@"Error trying to log in from AppDelegate: %@", [error localizedDescription]);
            // Probably keychain item is corrupted, reset the keychain and force user to sign up/ login again.
            // Better error handling can be done in a production application.
            [keychainItem resetKeychainItem];
        } else if (ffUser) {
            DLog(@"Login from AppDelegate using keychain successful!");
            success = YES;
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            self.participant = [WMParticipant participantForUserName:ffUser.userName create:NO managedObjectContext:managedObjectContext];
        }
        
    }

    return success;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (debug==1) {
        DLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        DLog(@"Document: %@", [self applicationDocumentsDirectory]);
    }
    // initialize Core Data
    [self.coreDataHelper setupCoreData];
//    // if Keychain Item exists, attempt login
//    if ([_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] != nil && ![[_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] isEqual:@""]) {
//        NSLog(@"_keychainItem username exists, attempting login in background.");
//        NSString *username = [_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
//        NSString *password = [_keychainItem objectForKey:(__bridge id)(kSecValueData)];
//        // Login with FatFractal by initiating connection with server - Step 1
//        WMFatFractal *ff = [WMFatFractal sharedInstance];
//        [ff loginWithUserName:username andPassword:password onComplete:^(NSError *theErr, id theObj, NSHTTPURLResponse *theResponse) {
//            // Step 2
//            if (theErr) {
//                NSLog(@"Error trying to log in from AppDelegate: %@", [theErr localizedDescription]);
//                // Probably keychain item is corrupted, reset the keychain and force user to sign up/ login again.
//                // Better error handling can be done in a production application.
//                [_keychainItem resetKeychainItem];
//                return ;
//            }
//            // Step 3
//            if (theObj) {
//                NSLog(@"Login from AppDelegate using keychain successful!");
//            }
//            // initialize UI
//            [self initializeInterface];
//        }];
//    } else {
//        // initialize UI
//        [self initializeInterface];
//    }
    // Register the preference defaults early.
    NSDictionary *appDefaults = @{@"com.mobilehealthware.woundmap.shouldRequestPasswordForEmailAttachment": @YES,
                                  @"com.mobilehealthware.woundmap.defaultIdRoot": @"2.16.840.1.113883.3.933"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // set up IAP so it hears notifications
    [IAPManager sharedInstance];
    // account for iOS 8 new notification registration
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // use registerUserNotificationSettings
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    } else {
        // use registerForRemoteNotifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    return YES;
}

- (void)initializeInterface
{
    if (nil == _window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIViewController *viewController = (isPad ? [[WMWelcomeToWoundMapViewController_iPad alloc] initWithNibName:@"WMWelcomeToWoundMapViewController_iPad" bundle:nil]:[[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil]);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (!isPad) {
        navigationController.delegate = self;
    }
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // Start the long-running task and return immediately.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (nil == self.window.rootViewController) {
        [self initializeInterface];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // TODO saves changes in the application's managed object context before the application terminates.

}

#pragma mark - Remote Notifications

- (void)registerDeviceToken
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSError *localError = nil;
    localError = [ff registerNotificationID:[self.devToken description]];
    if (localError) {
        [WMUtilities logError:localError];
    }
}

// RPN
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    _devToken = devToken;
}

// RPN
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    // check for data synch
    id content_available = userInfo[@"aps"][@"content-available"];
    if (content_available) {
        // process
        [self downloadFFDataForCollection:userInfo[@"aps"] fetchCompletionHandler:handler];
    } else {
        // no data
        [self application:application didReceiveRemoteNotification:userInfo];
        handler(UIBackgroundFetchResultNoData);
    }
}

// RPN
//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
//{
//    
//}

// RPN
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    id alertMsg = nil;
    NSString *otherButton = nil;
    NSString *badge = nil;
    
    // check for data synch
    id content_available = userInfo[@"aps"][@"content-available"];
    if (content_available) {
        [self downloadFFDataForCollection:userInfo[@"aps"] fetchCompletionHandler:nil];
        return;
    }

    self.remoteNotification = userInfo;
    // user already saw the alert and started up the app that way. don't show it to them again.
    if ([application applicationState] == UIApplicationStateInactive) {
        [self processRemoteNotification];
        return;
    }
    // else
    if (userInfo[@"aps"][@"alert"]) {
        alertMsg = userInfo[@"aps"][@"alert"];
        if (![alertMsg isKindOfClass:[NSString class]])
            alertMsg = userInfo[@"aps"][@"alert"][@"body"];
    } else {
        alertMsg = @"{no alert message in dictionary}";
    }
    
    if (userInfo[@"aps"][@"badge"]) {
        badge = userInfo[@"aps"][@"badge"];
		[application setApplicationIconBadgeNumber:[badge integerValue]];
    }
    
    if (userInfo[@"aps"][@"sound"] != NULL)
    {
        //        sound = [[userInfo objectForKey:@"aps"] objectForKey:@"sound"];
    }
    
//    if (userInfo[@"aps"][@"alert"][@"action-loc-key"] != NULL) {
//        otherButton = userInfo[@"aps"][@"alert"][@"action-loc-key"];
//    }
    
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    UIAlertView *alert = nil;
    
    if ([otherButton isKindOfClass:[NSString class]]) {
        alert = [[UIAlertView alloc] initWithTitle: @"Alert"
                                           message: alertMsg
                                          delegate: nil
                                 cancelButtonTitle: @"Close"
                                 otherButtonTitles: otherButton, nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle: @"Alert"
                                           message: alertMsg
                                          delegate: nil
                                 cancelButtonTitle: @"Close"
                                 otherButtonTitles: nil];
    }
    alert.tag = kRemoteNotification;
    [alert setDelegate:self];
    
    [alert show];
}

- (NSArray *)sortedEntityNames
{
    if (nil == _sortedEntityNames) {
        _sortedEntityNames = [[[NSManagedObjectModel MR_defaultManagedObjectModel] entities] valueForKey:@"name"];
    }
    return _sortedEntityNames;
}

// RPN
- (void)downloadFFDataForCollection:(NSDictionary *)map fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    // bail if from same device
    NSString *deviceId = [[IAPManager sharedInstance] getIAPDeviceGuid];
    if ([deviceId isEqualToString:map[@"d"]]) {
        return;
    }
    // else
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
    // save the payload
    WMUnhandledSilentUpdateNotification *unhandledSilentUpdateNotification = [WMUnhandledSilentUpdateNotification MR_createInContext:managedObjectContext];
    unhandledSilentUpdateNotification.notification = map;
    unhandledSilentUpdateNotification.userNamme = [[WMUserDefaultsManager sharedInstance] lastUserName];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    // beging processing
    UIBackgroundFetchResult backgroundFetchResult = UIBackgroundFetchResultFailed;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    if (!ff.loggedIn) {
        [self authenticateWithKeychain];
    }
    if (ff.loggedIn) {
        NSString *patientGuid = map[@"p"];
        NSString *woundGuid = map[@"w"];
        NSString *woundPhotoGuid = map[@"wp"];
        NSArray *collections = map[@"c"];
        NSArray *objectGuids = map[@"o"];
        NSArray *actions = map[@"a"];
        // make sure we have patient
        BOOL patientAcquired = NO;
        BOOL woundAcquired = NO;
        BOOL woundPhotoAcquired = NO;
        NSError *error = nil;
        WMPatient *patient = [WMPatient MR_findFirstByAttribute:WMPatientAttributes.ffUrl withValue:[NSString stringWithFormat:@"/ff/resources/WMPatient/%@", patientGuid] inContext:managedObjectContext];
        if (nil == patient) {
            // just fetch the patient
            patient = [ff getObjFromUri:[NSString stringWithFormat:@"/%@/%@?depthRef=1&depthGb=2", [WMPatient entityName], patientGuid] error:&error];
            if (error) {
                [WMUtilities logError:error];
            }
            // just fetch the BackReferences
            [ff grabBagGetAllForObj:patient grabBagName:@"BackReferences" error:&error];
            if (error) {
                [WMUtilities logError:error];
            }
            patientAcquired = YES;
        }
        
        // else
        if (woundGuid) {
            WMWound *wound = [WMWound MR_findFirstByAttribute:WMWoundAttributes.ffUrl withValue:[NSString stringWithFormat:@"/ff/resources/WMWound/%@", woundGuid] inContext:managedObjectContext];
            if (nil == wound) {
                // just fetch the wound
                [ff getObjFromUri:[NSString stringWithFormat:@"/%@/%@?depthRef=1&depthGb=2", [WMWound entityName], woundGuid] error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                woundAcquired = YES;
            }
        }
        
        // else
        if (woundPhotoGuid) {
            WMWoundPhoto *woundPhoto = [WMWoundPhoto MR_findFirstByAttribute:WMWoundPhotoAttributes.ffUrl withValue:[NSString stringWithFormat:@"/ff/resources/WMWoundPhoto/%@", woundPhotoGuid] inContext:managedObjectContext];
            if (nil == woundPhoto || nil == woundPhoto.thumbnail || nil == woundPhoto.thumbnailLarge || nil == woundPhoto.thumbnailMini) {
                // just fetch the woundPhoto
                [ff getObjFromUri:[NSString stringWithFormat:@"/%@/%@?depthRef=1&depthGb=2", [WMWoundPhoto entityName], woundPhotoGuid] error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                FFReadResponse *response = [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnail]] executeSync];
                NSData *photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnail = [[UIImage alloc] initWithData:photoData];
                }
                response = [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailLarge]] executeSync];
                photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnailLarge = [[UIImage alloc] initWithData:photoData];
                }
                response = [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailMini]] executeSync];
                photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnailMini = [[UIImage alloc] initWithData:photoData];
                }
                woundPhotoAcquired = YES;
            }
        }
        
        NSArray *sortedEntityNames = self.sortedEntityNames;
        if (objectGuids && [objectGuids isKindOfClass:[NSArray class]]) {
            NSInteger index = 0;
            for (NSString *objectGuid in objectGuids) {
                NSNumber *collectionNumber = collections[index];
                NSString *collection = [sortedEntityNames objectAtIndex:[collectionNumber intValue]];
                if (patientAcquired && [collection isEqualToString:[WMPatient entityName]]) {
                    continue;
                }
                if (woundAcquired && [collection isEqualToString:[WMWound entityName]]) {
                    continue;
                }
                if (woundPhotoAcquired && [collection isEqualToString:[WMWoundPhoto entityName]]) {
                    continue;
                }
                
                NSString *action = actions[index];

                if ([action isEqualToString:@"D"]) {
                    // fetch object in store
                    Class clazz = NSClassFromString(collection);
                    if (clazz) {
                        NSManagedObject *objectToDelete = [clazz MR_findFirstByAttribute:WMPatientAttributes.ffUrl withValue:[NSString stringWithFormat:@"/ff/resources/%@/%@", collection, patientGuid] inContext:managedObjectContext];
                        if (objectToDelete) {
                            NSManagedObjectID *objectID = [objectToDelete objectID];
                            [managedObjectContext MR_deleteObjects:@[objectToDelete]];
                            // notify UI
                            [[NSNotificationCenter defaultCenter] postNotificationName:kBackendDeletedObjectIDs object:@[objectID]];
                        }
                    }
                    continue;
                }
                // else fetch the data
                id object = [ff getObjFromUri:[NSString stringWithFormat:@"/%@/%@", collection, objectGuid] error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                // get photo
                if ([collection isEqualToString:[WMPhoto entityName]]) {
                    // get blobs autoLoadBlobs
                    WMPhoto *photo = (WMPhoto *)object;
                    FFReadResponse *response = [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", photo.ffUrl, WMPhotoAttributes.photo]] executeSync];
                    NSData *photoData = [response rawResponseData];
                    if (response.httpResponse.statusCode > 300) {
                        DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                    } else {
                        photo.photo = [[UIImage alloc] initWithData:photoData];
                    }
                }
                // increment index
                ++index;
            }
            // check if patient stage has changed
            BOOL patientStageChangedFlag = patient.isStageUpdating;
            // save data
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
            // notify UI
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedContentFromCloudNotification object:map userInfo:@{@"patientStageChangedFlag":@(patientStageChangedFlag)}];
            // mark as success
            backgroundFetchResult = UIBackgroundFetchResultNewData;
        } else {
            // no data
            backgroundFetchResult = UIBackgroundFetchResultNoData;
        }
        // delete the payload
        [managedObjectContext MR_deleteObjects:@[unhandledSilentUpdateNotification]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    
    // finished
    if (handler) {
        handler(backgroundFetchResult);
    }
}

// RPN
- (void)processRemoteNotification
{
    NSString *patientGuid = self.remoteNotification[@"patientGuid"];        // WMPatient guid
    NSString *invitationGuid = self.remoteNotification[@"invitationGuid"];  // WMTeamInvitation guid
    NSString *teamGuid = self.remoteNotification[@"teamGuid"];              // WMTeam guid
    
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    if (!ff.loggedIn) {
        [self authenticateWithKeychain];
    }
    
    WMParticipant *participant = self.participant;
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    UIViewController *viewController = self.window.rootViewController;
    BOOL isViewLoaded = viewController.isViewLoaded;
    UIView *view = viewController.view;
    
    if (patientGuid) {
        [center postNotificationName:kPatientReferralNotification object:patientGuid];
    } else if (invitationGuid) {
        [center postNotificationName:kTeamInvitationNotification object:invitationGuid];
    } else if (teamGuid) {
        // get data now
        if (ff.loggedIn && participant) {
            // do not alert when the team leader is added
            if (participant.isTeamLeader) {
                return;
            }
            // else update the participant
            WMErrorCallback errorCallback = ^(NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                if (isViewLoaded) {
                    [MBProgressHUD hideAllHUDsForView:view animated:NO];
                    [center postNotificationName:kTeamMemberAddedNotification object:teamGuid];
                }
            };
            if (isViewLoaded) {
                [MBProgressHUD showHUDAddedToViewController:viewController animated:YES].labelText = @"Acquiring Team";
            }
            [ffm updateParticipant:participant completionHandler:errorCallback];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kRemoteNotification) {
        [self processRemoteNotification];
        self.remoteNotification = nil;
    } else if (alertView.tag == kSessionTimeoutAlertViewTag) {
        _timeOutAlertView = nil;
        [self signOut];
        __weak __typeof(&*self)weakSelf = self;
        UINavigationController *navigationController = self.initialViewController;
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            weakSelf.window.rootViewController = navigationController;
                        } completion:^(BOOL finished) {
                            // nothing
                        }];
    }
}

#pragma mark - Managers

- (WMNavigationCoordinator *)navigationCoordinator
{
    if (nil == _navigationCoordinator) {
        BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        if (isPad) {
            _navigationCoordinator = [WMNavigationCoordinator_iPad sharedInstance];
        } else {
            _navigationCoordinator = [WMNavigationCoordinator sharedInstance];
        }
    }
    return  _navigationCoordinator;
}

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    return (isPad ? UIInterfaceOrientationMaskAllButUpsideDown:UIInterfaceOrientationMaskPortrait);
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
