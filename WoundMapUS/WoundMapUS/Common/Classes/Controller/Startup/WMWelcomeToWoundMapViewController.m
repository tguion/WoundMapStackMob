//
//  WMWelcomeToWoundMapViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController.h"
#import "WMSignInViewController.h"
#import "WMUserSignInViewController.h"
#import "User.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, UserSignInDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;
@property (nonatomic) SMFetchPolicy fetchPolicy;
@property (nonatomic) SMSavePolicy savePolicy;

@property (weak, nonatomic) IBOutlet UIView *teamContainerView;
@property (readonly, nonatomic) WMSignInViewController *signInViewController;
@property (readonly, nonatomic) WMUserSignInViewController *userSignInViewController;

- (IBAction)signInAction:(id)sender;
- (IBAction)joinTeamAction:(id)sender;
- (IBAction)createTeamAction:(id)sender;
- (IBAction)consultantAction:(id)sender;

@end

@implementation WMWelcomeToWoundMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    _teamContainerView.hidden = (nil == self.appDelegate.participant);
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    self.savePolicy = SMSavePolicyNetworkThenCache;
    if (nil != self.appDelegate.user) {
        [self.coreDataHelper.stackMobStore syncWithServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.appDelegate.coreDataHelper.stackMobStore contextForCurrentThread];
}

- (NSPersistentStore *)store
{
    NSArray *persistentStores = [self.appDelegate.coreDataHelper.stackMobStore.persistentStoreCoordinator persistentStores];
    NSPersistentStore *store = [persistentStores firstObject];
    NSAssert1([store isKindOfClass:[SMIncrementalStore class]], @"Unexpected class, expected SMIncrementalStore, found %@", store);
    return store;
}

- (void)setFetchPolicy:(SMFetchPolicy)fetchPolicy
{
    if (_fetchPolicy == fetchPolicy) {
        return;
    }
    // else
    _fetchPolicy = fetchPolicy;
    self.coreDataHelper.stackMobStore.fetchPolicy = fetchPolicy;
}

- (void)setSavePolicy:(SMSavePolicy)savePolicy
{
    if (_savePolicy == savePolicy) {
        return;
    }
    // else
    _savePolicy = savePolicy;
    self.coreDataHelper.stackMobStore.savePolicy = savePolicy;
}

- (WMSignInViewController *)signInViewController
{
    WMSignInViewController *signInViewController = [[WMSignInViewController alloc] initWithNibName:@"WMSignInViewController" bundle:nil];
    signInViewController.delegate = self;
    return signInViewController;
}

- (WMUserSignInViewController *)userSignInViewController
{
    WMUserSignInViewController *userSignInViewController = [[WMUserSignInViewController alloc] initWithNibName:@"WMUserSignInViewController" bundle:nil];
    userSignInViewController.delegate = self;
    return userSignInViewController;
}

#pragma mark - Actions

- (IBAction)signInAction:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.signInViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (IBAction)joinTeamAction:(id)sender
{
    WMUserSignInViewController *userSignInViewController = self.userSignInViewController;
    userSignInViewController.createNewUserFlag = NO;
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    User *user = [User userForUsername:userDefaultsManager.lastTeamName managedObjectContext:self.managedObjectContext persistentStore:self.store];
    userSignInViewController.selectedUser = user;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userSignInViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (IBAction)createTeamAction:(id)sender
{
    
}

- (IBAction)consultantAction:(id)sender
{
    
}

#pragma mark - SignInViewControllerDelegate

- (void)signInViewControllerWillAppear:(WMSignInViewController *)viewController
{
    
}

- (void)signInViewControllerWillDisappear:(WMSignInViewController *)viewController
{
    
}

- (void)signInViewController:(WMSignInViewController *)viewController didSignInParticipant:(WMParticipant *)participant
{
    self.appDelegate.participant = participant;
    [viewController clearAllReferences];
    BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isIPadIdiom) {

    } else {
        __weak __typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"TODO: fixme %@", weakSelf);
        }];
    }
}

#pragma mark - UserSignInDelegate

- (void)userSignInViewController:(WMUserSignInViewController *)viewController didSignInUser:(User *)user
{
    self.appDelegate.user = user;
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)userSignInViewControllerDidCancel:(WMUserSignInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}



@end
