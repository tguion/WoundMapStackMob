//
//  WCAppDelegate.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "WMLocalStoreManager.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "WMNavigationCoordinator_iPad.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

static NSString *baseUrl = @"https://localhost:8443/WoundMapUS";

@implementation WMFatFractal

+ (WMFatFractal *)sharedInstance
{
    static WMFatFractal *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMFatFractal alloc] initWithBaseUrl:baseUrl];
        SharedInstance.localStorage = [[FFLocalStorageSQLite alloc] initWithDatabaseKey:@"WoundMapFFStorage"];
        // Then just make sure and let the SDK know you want to use this class instead of FFUser
        [SharedInstance registerClass:[WMParticipant class] forClazz:@"FFUser"];
    });
    return SharedInstance;
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
    return [NSManagedObject MR_findFirstInContext:managedObjectContext];
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
        WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPersistentStore *store = appDelegate.coreDataHelper.store;
        id obj = [self findExistingObjectWithClass:clazz ffUrl:objMetaData.ffUrl managedObjectContext:managedObjectContext persistentStore:store];
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

@interface WCAppDelegate ()

@property (nonatomic, strong, readwrite) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong, readwrite) WMFatFractal *ff;
@property (nonatomic, strong, readwrite) WMNavigationCoordinator *navigationCoordinator;

@end

@implementation WCAppDelegate

#define debug 1

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // initialize Core Data
    [self.coreDataHelper setupCoreData];
    // initialize UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil]];
    navigationController.delegate = self;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
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

@end
