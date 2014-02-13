//
//  WMWelcomeToWoundMapViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController.h"
#import "WMUserSignInViewController.h"
#import "User.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"

@interface WMWelcomeToWoundMapViewController () <UserSignInDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

@property (weak, nonatomic) IBOutlet UIView *teamContainerView;
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

- (WMUserSignInViewController *)userSignInViewController
{
    WMUserSignInViewController *userSignInViewController = [[WMUserSignInViewController alloc] initWithNibName:@"WMUserSignInViewController" bundle:nil];
    userSignInViewController.delegate = self;
    return userSignInViewController;
}

#pragma mark - Actions

- (IBAction)signInAction:(id)sender
{
    
}

- (IBAction)joinTeamAction:(id)sender
{
    WMUserSignInViewController *userSignInViewController = self.userSignInViewController;
    userSignInViewController.createNewUserFlag = NO;
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    User *user = [User userForUsername:userDefaultsManager.lastTeamName managedObjectContext:self.managedObjectContext persistentStore:self.store];
    userSignInViewController.selectedUser = user;
    [self.navigationController pushViewController:userSignInViewController animated:YES];
}

- (IBAction)createTeamAction:(id)sender
{
    
}

- (IBAction)consultantAction:(id)sender
{
    
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
