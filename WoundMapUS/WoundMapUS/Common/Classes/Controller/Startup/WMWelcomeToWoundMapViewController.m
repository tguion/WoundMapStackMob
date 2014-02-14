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
#import "WMParticipant.h"
#import "WMNavigationTrack.h"
#import "WMPatient.h"
#import "WMUserDefaultsManager.h"
#import "WMPatientManager.h"
#import "WCAppDelegate.h"

typedef NS_ENUM(NSInteger, WMWelcomeState) {
    WMWelcomeStateInitial,
    WMWelcomeStateTeamSelected,
    WMWelcomeStateDeferTeam,
    WMWelcomeStateParticipantSelected
};

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, UserSignInDelegate>

@property (nonatomic) WMWelcomeState welcomeState;
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    self.savePolicy = SMSavePolicyNetworkThenCache;
    if (nil != self.appDelegate.stackMobUsername) {
        [self.coreDataHelper.stackMobStore syncWithServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

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

- (IBAction)deferTeamAction:(id)sender
{
    UISwitch *deferTeamSwitch = (UISwitch *)sender;
    self.welcomeState = (deferTeamSwitch.isOn ? WMWelcomeStateDeferTeam:WMWelcomeStateInitial);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // join team
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
                    break;
                }
                case 1: {
                    // defer or team joined
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // create account/sign in
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.signInViewController];
                    [self presentViewController:navigationController
                                       animated:YES
                                     completion:^{
                                         // nothing
                                     }];
                    break;
                }
                case 1: {
                    // choose navigation track
                    [self presentChooseNavigationTrack];
                    break;
                }
                case 2: {
                    // add/change patient
                    NSInteger patientCount = self.patientManager.patientCount;
                    if (0 == patientCount) {
                        // check iCloud
                        if (self.appDelegate.userSelectedToUseICloud && !self.appDelegate.iCloudInitializationDidFinish) {
                            // show progress view and wait for notification
                            [self showProgressViewWithMessage:@"Waiting for iCloud"];
                        } else {
                            [self presentAddPatientViewController];
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_welcomeState > WMWelcomeStateDeferTeam ? 2:1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0: {
            title = @"Team Configuration";
            break;
        }
        case 1: {
            title = @"Participant Configuration";
            break;
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = 2;
            break;
        }
        case 1: {
            if (_welcomeState < WMWelcomeStateParticipantSelected) {
                count = 1;
            } else if (nil == self.userDefaultsManager.defaultNavigationTrackTitle) {
                count = 2;
            } else {
                count = 3;
            }
            break;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    NSString *value = nil;
    UIImage *image = nil;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    UIView *accessoryView = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    title = @"Join or Create Team";
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    if (_welcomeState == WMWelcomeStateInitial) {
                        title = @"Defer Join Team";
                        UISwitch *deferTeamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        [deferTeamSwitch addTarget:self action:@selector(deferTeamAction:) forControlEvents:UIControlEventValueChanged];
                        accessoryView = deferTeamSwitch;
                    } else {
                        title = @"Team";
                        value = self.appDelegate.stackMobUsername;
                    }
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    title = (nil == self.appDelegate.participant ? @"Create Account/Sign In":@"Change Account");
                    if (nil == self.appDelegate.participant) {
                        title = @"Create Account/Sign In";
                        image = [UIImage imageNamed:@"ui_circle"];
                    } else {
                        title = @"Change Account";
                        value = self.appDelegate.participant.name;
                        image = [UIImage imageNamed:@"ui_checkmark"];
                    }
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:self.managedObjectContext persistentStore:self.store];
                    title = @"Clinical Setting";
                    if (nil == navigationTrack) {
                        image = [UIImage imageNamed:@"ui_circle"];
                    } else {
                        value = navigationTrack.displayTitle;
                        image = [UIImage imageNamed:@"ui_checkmark"];
                    }
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 2: {
                    if (self.coreDataHelper.stackMobStore.syncInProgress) {
                        title = @"Waiting for Patient Records";
                        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        accessoryView = activityIndicatorView;
                        [activityIndicatorView startAnimating];
                        cell.accessoryView = activityIndicatorView;
                    } else {
                        WMPatientManager *patientManager = [WMPatientManager sharedInstance];
                        NSInteger patientCount = patientManager.patientCount;
                        if (0 == patientCount) {
                            title = @"Add Patient";
                            image = [UIImage imageNamed:@"ui_circle"];
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        } else {
                            if (patientCount == 1) {
                                title = @"Patient Added";
                                accessoryType = UITableViewCellAccessoryNone;
                            } else {
                                title = @"Current Patient";
                                accessoryType = UITableViewCellAccessoryNone;
                            }
                            WMPatient *patient = patientManager.lastModifiedActivePatient;
                            value = patient.lastNameFirstName;
                            image = [UIImage imageNamed:@"ui_checkmark"];
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = value;
    cell.imageView.image = image;
    cell.accessoryType = accessoryType;
    cell.accessoryView = accessoryView;
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
    participant.dateLastSignin = [NSDate date];
    self.appDelegate.participant = participant;
    [self.coreDataHelper backgroundSaveContext];
    [viewController clearAllReferences];
    BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isIPadIdiom) {

    } else {
        __weak __typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"TODO: fixme %@", weakSelf);
        }];
    }
    self.welcomeState = WMWelcomeStateParticipantSelected;
}

#pragma mark - UserSignInDelegate

- (void)userSignInViewController:(WMUserSignInViewController *)viewController didSignInUsername:(NSString *)username
{
    self.appDelegate.stackMobUsername = username;
    [self dismissViewControllerAnimated:YES completion:^{
        WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
        userDefaultsManager.lastTeamName = username;
    }];
    self.welcomeState = WMWelcomeStateTeamSelected;
    [self.tableView reloadData];
}

- (void)userSignInViewControllerDidCancel:(WMUserSignInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}



@end
