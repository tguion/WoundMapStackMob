//
//  WCAppDelegate.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "WMNavigationCoordinator_iPad.h"
#import "WMParticipant.h"
#import "WMSeedDatabaseManager.h"
#import "WMFatFractalManager.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "KeychainItemWrapper.h"

static NSString *baseUrl = @"http://localhost:8080/WoundMapUS";
static NSString *sslUrl = @"https://localhost:8443/WoundMapUS";
//static NSString *baseUrl = @"http://mobilehealthware/fatfractal.com/woundmapus";
//static NSString *sslUrl = @"https://mobilehealthware/fatfractal.com/woundmapus";

@implementation WMFatFractal

+ (WMFatFractal *)sharedInstance
{
    static WMFatFractal *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMFatFractal alloc] initWithBaseUrl:baseUrl sslUrl:sslUrl];
        [self initializeFatFractalInstance:SharedInstance];
    });
    return SharedInstance;
}

+ (WMFatFractal *)instance
{
    WMFatFractal *instance = [[WMFatFractal alloc] initWithBaseUrl:baseUrl sslUrl:sslUrl];
    [self initializeFatFractalInstance:instance];
    return instance;
}

+ (void)initializeFatFractalInstance:(WMFatFractal *)ff
{
    ff.debug = YES;
    ff.localStorage = [[FFLocalStorageSQLite alloc] initWithDatabaseKey:@"WoundMapFFStorage"];
    // must load blobs explicitely
    ff.autoLoadBlobs = NO;
    ff.autoLoadRefs = YES;
}

- (id)findExistingObjectWithClass:(Class)clazz
                            ffUrl:(NSString *)ffUrl
             managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  persistentStore:(NSPersistentStore *)store
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    if (store) {
        [request setAffectedStores:@[store]];
    }
    [request setPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl]];
    return [NSManagedObject MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
}

/**
 * Let the FatFractal SDK know how to handle your CoreData objects, by creating a [custom FatFractal subclass]
 * This is the code that holds everything together. We're over-riding
 - (id) createInstanceOfClass:(Class) class forObjectWithMetaData:(FFMetaData *)objMetaData
 * so that when the FatFractal SDK needs to create an instance of one of your objects, then you can control how that's done.
 * In this example, then if it's an NSManagedObject subclass, we're first checking to see if we already have that object locally, and if not then we're calling the appropriate CoreData initializer.
 */

- (id)createInstanceOfClass:(Class)clazz forObjectWithMetaData:(FFMetaData *)objMetaData
{
    if ([clazz isSubclassOfClass:[NSManagedObject class]]) {
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        id obj = [self findExistingObjectWithClass:clazz ffUrl:objMetaData.ffUrl managedObjectContext:managedObjectContext persistentStore:nil];
        if (obj) {
            DLog(@"Found existing %@ object with ffUrl %@ in managed context", NSStringFromClass(clazz), objMetaData.ffUrl);
            return obj;
        }
        // else
        DLog(@"Inserting new %@ object with ffUrl %@ into managed context", NSStringFromClass(clazz), objMetaData.ffUrl);
        return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(clazz) inManagedObjectContext:managedObjectContext];
    }
    // else
    return [[clazz alloc] init];
}

@end

// Instantiating KeychainItemWrapper class as a singleton through AppDelegate
static KeychainItemWrapper *_keychainItem;
// Keychain Identifier
static NSString *keychainIdentifier = @"WoundMapUSKeychain";

@interface WCAppDelegate ()

@property (nonatomic, strong, readwrite) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong, readwrite) WMFatFractal *ff;
@property (nonatomic, strong, readwrite) WMNavigationCoordinator *navigationCoordinator;

@end

@implementation WCAppDelegate

#define debug 1

+ (KeychainItemWrapper *)keychainItem
{
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

- (void)demo
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

#pragma mark - Backend

+ (BOOL)checkForAuthentication
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    if ([ff loggedIn] || ([_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] != nil && ![[_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] isEqual:@""])) {
        NSLog(@"checkForAuthentication: FFUser logged in.");
        // authenticated - look up participant
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        FFUser *ffUser = (FFUser *)[ff loggedInUser];
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
        WMParticipant *participant = nil;
        if (ffUser) {
            participant = [WMParticipant participantForUserName:ffUser.userName create:NO managedObjectContext:managedObjectContext];
        } else {
            // keychain says is logged in
            KeychainItemWrapper *keychainItem = [WCAppDelegate keychainItem];
            id object = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
            if ([object isKindOfClass:[NSString class]]) {
                NSString *userName = (NSString *)object;
                participant = [WMParticipant participantForUserName:userName create:NO managedObjectContext:managedObjectContext];
            }
        }
        appDelegate.participant = participant;
        WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
        userDefaultsManager.lastUserName = participant.userName;
        return (nil != participant);
    }
    // else
    NSLog(@"checkForAuthentication: No user logged in.");
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // initialize Core Data
    [self.coreDataHelper setupCoreData];
//    // create the KeychainItem singleton
//    _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:keychainIdentifier accessGroup:nil];
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
    [self initializeInterface];
    return YES;
}

- (void)initializeInterface
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil]];
    navigationController.delegate = self;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
//    [self testWoundTypeSeedBackend];
}

- (void)testWoundTypeSeedBackend
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSString *uri = [NSString stringWithFormat:@"/%@", [WMWoundType entityName]];
    NSArray *woundTypes = [ff getArrayFromUri:uri];
    for (WMWoundType *woundType in woundTypes) {
        [ff deleteObj:woundType];
    }
    [managedObjectContext MR_deleteObjects:woundTypes];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    id<FFUserProtocol> user = [ff loginWithUserName:@"todd" andPassword:@"todd"];
    if (nil == user) {
        NSLog(@"failed");
    }
    // first attempt to acquire data from backend
    [WMWoundType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
        // update backend
        [ffm createArray:objectIDs
              collection:[WMWoundType entityName]
                      ff:ff
              addToQueue:YES
        reverseEnumerate:YES
       completionHandler:nil];
    }];

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
    // TODO saves changes in the application's managed object context before the application terminates.
    
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
    [self demo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // TODO saves changes in the application's managed object context before the application terminates.

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
    return UIInterfaceOrientationMaskPortrait;
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
