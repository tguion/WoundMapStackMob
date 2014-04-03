//
//  WMWelcomeToWoundMapViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController.h"
#import "WMSignInViewController.h"
#import "WMCreateAccountViewController.h"
#import "WMCreateTeamInvitationViewController.h"
#import "WMIAPJoinTeamViewController.h"
#import "WMIAPCreateTeamViewController.h"
#import "WMCreateTeamViewController.h"
#import "WMIAPCreateConsultantViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPatientTableViewController.h"
#import "WMInstructionsViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMButtonCell.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMConsultingGroup.h"
#import "WMNavigationTrack.h"
#import "WMPatient.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "KeychainItemWrapper.h"
#import "WMUtilities.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

typedef NS_ENUM(NSInteger, WMWelcomeState) {
    WMWelcomeStateInitial,          // Sign In, Create Account
    WMWelcomeStateSignedInNoTeam,   // Sign Out | Join Team, Create Team, No Team (signed in user has not joined/created a team)
    WMWelcomeStateTeamSelected,     // Sign Out | Team (value) | Clinical Setting | Patient
    WMWelcomeStateDeferTeam,        // Sign Out | Join Team, Create Team, No Team | Clinical Setting | Patient
};

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, CreateAccountDelegate, WMIAPJoinTeamViewControllerDelegate, IAPCreateTeamViewControllerDelegate, CreateTeamViewControllerDelegate, CreateTeamInvitationViewControllerDelegate, IAPCreateConsultantViewControllerDelegate, ChooseTrackDelegate, PatientDetailViewControllerDelegate, PatientTableViewControllerDelegate>

@property (nonatomic) WMWelcomeState welcomeState;
@property (readonly, nonatomic) BOOL connectedTeamIsConsultingGroup;
@property (readonly, nonatomic) WMSignInViewController *signInViewController;
@property (readonly, nonatomic) WMCreateAccountViewController *createAccountViewController;
@property (readonly, nonatomic) WMIAPJoinTeamViewController *iapJoinTeamViewController;
@property (readonly, nonatomic) WMIAPCreateTeamViewController *iapCreateTeamViewController;
@property (readonly, nonatomic) WMCreateTeamViewController *createTeamViewController;
@property (readonly, nonatomic) WMCreateTeamInvitationViewController *createTeamInvitationViewController;

@property (readonly, nonatomic) WMParticipant *participant;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *enterWoundMapButton;

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath;

- (IBAction)enterWoundMapAction:(id)sender;

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
    self.title = @"Welcome to WoundMap";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DeferCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    [self.tableView registerClass:[WMButtonCell class] forCellReuseIdentifier:@"ButtonCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.enterWoundMapButton.enabled = self.setupConfigurationComplete;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

- (BOOL)connectedTeamIsConsultingGroup
{
    return nil != self.participant.team.consultingGroup;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"Cell";
    switch (indexPath.section) {
        case 0: {
            // section 0
            switch (self.welcomeState) {
                case WMWelcomeStateInitial: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case WMWelcomeStateSignedInNoTeam: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case WMWelcomeStateTeamSelected: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case WMWelcomeStateDeferTeam: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
            }
            break;
        }
        case 1: {
            // section 1
            switch (indexPath.row) {
                case 0: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case 1: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case 2: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
            }
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)setupConfigurationComplete
{
    if (nil == self.participant) {
        return NO;
    }
    // else
    if (nil == self.userDefaultsManager.defaultNavigationTrackFFURL) {
        return NO;
    }
    // else
    return (nil != self.appDelegate.navigationCoordinator.patient);
}

- (WMSignInViewController *)signInViewController
{
    WMSignInViewController *signInViewController = [[WMSignInViewController alloc] initWithNibName:@"WMSignInViewController" bundle:nil];
    signInViewController.delegate = self;
    return signInViewController;
}

- (WMCreateAccountViewController *)createAccountViewController
{
    WMCreateAccountViewController *createAccountViewController = [[WMCreateAccountViewController alloc] initWithNibName:@"WMCreateAccountViewController" bundle:nil];
    createAccountViewController.delegate = self;
    return createAccountViewController;
}

- (WMIAPJoinTeamViewController *)iapJoinTeamViewController
{
    WMIAPJoinTeamViewController *iapJoinTeamViewController = [[WMIAPJoinTeamViewController alloc] initWithNibName:@"WMIAPJoinTeamViewController" bundle:nil];
    iapJoinTeamViewController.delegate = self;
    return iapJoinTeamViewController;
}

- (WMIAPCreateTeamViewController *)iapCreateTeamViewController
{
    WMIAPCreateTeamViewController *iapCreateTeamViewController = [[WMIAPCreateTeamViewController alloc] initWithNibName:@"WMIAPCreateTeamViewController" bundle:nil];
    iapCreateTeamViewController.delegate = self;
    return iapCreateTeamViewController;
}

- (WMCreateTeamViewController *)createTeamViewController
{
    WMCreateTeamViewController *createTeamViewController = [[WMCreateTeamViewController alloc] initWithNibName:@"WMCreateTeamViewController" bundle:nil];
    createTeamViewController.delegate = self;
    return createTeamViewController;
}

- (WMCreateTeamInvitationViewController *)createTeamInvitationViewController
{
    WMCreateTeamInvitationViewController *createTeamInvitationViewController = [[WMCreateTeamInvitationViewController alloc] initWithNibName:@"WMCreateTeamInvitationViewController" bundle:nil];
    createTeamInvitationViewController.delegate = self;
    return createTeamInvitationViewController;
}

- (WMIAPCreateConsultantViewController *)iapCreateConsultantViewController
{
    WMIAPCreateConsultantViewController *iapCreateConsultantViewController = [[WMIAPCreateConsultantViewController alloc] initWithNibName:@"WMIAPCreateConsultantViewController" bundle:nil];
    iapCreateConsultantViewController.delegate = self;
    return iapCreateConsultantViewController;
}

- (WMChooseTrackViewController *)chooseTrackViewController
{
    WMChooseTrackViewController *chooseTrackViewController = [[WMChooseTrackViewController alloc] initWithNibName:@"WMChooseTrackViewController" bundle:nil];
    chooseTrackViewController.delegate = self;
    return chooseTrackViewController;
}

- (WMInstructionsViewController *)instructionsViewController
{
    return [[WMInstructionsViewController alloc] initWithNibName:@"WMInstructionsViewController" bundle:nil];
}

- (void)presentJoinTeamViewController
{
    // must have an invitation
    if (self.participant.teamInvitation) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapJoinTeamViewController];
        [self presentViewController:navigationController
                           animated:YES
                         completion:^{
                             // nothing
                         }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Invitation"
                                                            message:@"A team leader must create an invitation to join a team. Please ask the team leader to create an invitation."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)presentCreateTeamViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapCreateTeamViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)presentTeamInvitationController
{
    [self.navigationController pushViewController:self.createTeamInvitationViewController animated:YES];
}

- (void)presentChooseNavigationTrack
{
    [self.navigationController pushViewController:self.chooseTrackViewController animated:YES];
}

- (WMPatientDetailViewController *)patientDetailViewController
{
    WMPatientDetailViewController *patientDetailViewController = [[WMPatientDetailViewController alloc] initWithNibName:@"WMPatientDetailViewController" bundle:nil];
    patientDetailViewController.delegate = self;
    return patientDetailViewController;
}

- (void)presentAddPatientViewController
{
    // create new patient and document and wait for document open callback
    [self showProgressViewWithMessage:@"Opening Patient Record"];
    WMPatientDetailViewController *patientDetailViewController = self.patientDetailViewController;
    patientDetailViewController.newPatientFlag = YES;
    if (self.isIPadIdiom) {
        [self.navigationController pushViewController:patientDetailViewController animated:YES];
    } else {
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:patientDetailViewController] animated:YES completion:^{
            // nothing
        }];
    }
}

- (void)presentChoosePatientViewController
{
    WMPatientTableViewController *patientTableViewController = [[WMPatientTableViewController alloc] initWithNibName:@"WMPatientTableViewController" bundle:nil];
    patientTableViewController.delegate = self;
    [self.navigationController pushViewController:patientTableViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)deferTeamAction:(id)sender
{
    UISwitch *deferTeamSwitch = (UISwitch *)sender;
    self.welcomeState = (deferTeamSwitch.isOn ? WMWelcomeStateDeferTeam:WMWelcomeStateSignedInNoTeam);
    if (deferTeamSwitch.isOn) {
        self.tableView.tableFooterView = _footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
    [self.tableView reloadData];
}

- (IBAction)enterWoundMapAction:(id)sender
{
    NSLog(@"Hurray");
}

- (IBAction)viewInstructionsAction:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.instructionsViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

#pragma mark - Notification handlers

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
            // participant
            switch (indexPath.row) {
                case 0: {
                    // sign in or sign out
                    if (_welcomeState == WMWelcomeStateInitial) {
                        // sign in - navigate to sign in vc
                        [self.navigationController pushViewController:self.signInViewController animated:YES];
                    } else {
                        // sign out
                        WMFatFractal *ff = [WMFatFractal sharedInstance];
                        [ff logout];
                        self.appDelegate.participant = nil;
                        self.welcomeState = WMWelcomeStateInitial;
                        [tableView reloadData];
                    }
                    break;
                }
                case 1: {
                    // create account
                    [self.navigationController pushViewController:self.createAccountViewController animated:YES];
                    break;
                }
                case 2: {
                    // defer or [become a consultant, consultant identifier]
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        // is the team already a consultant
                        if (self.connectedTeamIsConsultingGroup) {
                            break;
                        }
                        // else
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapCreateConsultantViewController];
                        [self presentViewController:navigationController
                                           animated:YES
                                         completion:^{
                                             // nothing
                                         }];
                    }
                    break;
                }
            }
            break;
        }
        case 1: {
            // team
            switch (indexPath.row) {
                case 0: {
                    // join team or team joined
                    if (self.welcomeState == WMWelcomeStateSignedInNoTeam || self.welcomeState == WMWelcomeStateDeferTeam) {
                        [self presentJoinTeamViewController];
                    }
                    // else should not select - cell indicates the team
                    break;
                }
                case 1: {
                    if (self.participant.isTeamLeader) {
                        // invite
                        [self presentTeamInvitationController];
                    } else {
                        // create team
                        [self presentCreateTeamViewController];
                    }
                    break;
                }
                case 2: {
                    // else user selected to defer - should not be able to select cell
                    break;
                }
            }
            break;
        }
        case 2: {
            // clinical setting
            [self presentChooseNavigationTrack];
            break;
        }
        case 3: {
            // patient
            NSInteger patientCount = [WMPatient patientCount:self.managedObjectContext];
            if (0 == patientCount) {
                [self presentAddPatientViewController];
            } else {
                [self presentChoosePatientViewController];
            }
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    switch (self.welcomeState) {
        case WMWelcomeStateInitial: {
            count = 1;
            break;
        }
        case WMWelcomeStateSignedInNoTeam: {
            count = 2;
            break;
        }
        case WMWelcomeStateTeamSelected: {
            count = 4;
            break;
        }
        case WMWelcomeStateDeferTeam: {
            count = 4;
            break;
        }
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0: {
            title = @"Participant Configuration";
            break;
        }
        case 1: {
            title = @"Team Configuration";
            break;
        }
        case 2: {
            title = @"Clinical Setting";
            break;
        }
        case 3: {
            title = @"Current Patient";
            break;
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (self.welcomeState) {
        case WMWelcomeStateInitial: {
            count = 2;
            break;
        }
        case WMWelcomeStateSignedInNoTeam: {
            switch (section) {
                case 0: {
                    count = 1;
                    break;
                }
                case 1: {
                    count = 3;
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateTeamSelected: {
            switch (section) {
                case 0: {
                    count = 1;
                    break;
                }
                case 1: {
                    count = (self.participant.isTeamLeader ? 2:1);
                    break;
                }
                case 2:
                case 3: {
                    count = 1;
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateDeferTeam: {
            switch (section) {
                case 0: {
                    count = 1;
                    break;
                }
                case 1: {
                    count = 3;
                    break;
                }
                case 2:
                case 3: {
                    count = 1;
                    break;
                }
            }
            break;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
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
    switch (self.welcomeState) {
        case WMWelcomeStateInitial: {
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0: {
                    title = @"Sign In";
                    break;
                }
                case 1: {
                    title = @"Create Account";
                    break;
                }
            };
            break;
        }
        case WMWelcomeStateSignedInNoTeam: {
            switch (indexPath.section) {
                case 0: {
                    title = @"Sign Out";
                    value = self.participant.userName;
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Join Team";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 1: {
                            title = @"Create Team";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 2: {
                            title = @"Defer Joining Team";
                            if (nil == cell.accessoryView || ![cell.accessoryView isKindOfClass:[UISwitch class]]) {
                                UISwitch *deferTeamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                                [deferTeamSwitch addTarget:self action:@selector(deferTeamAction:) forControlEvents:UIControlEventValueChanged];
                                accessoryView = deferTeamSwitch;
                            } else {
                                accessoryView = cell.accessoryView;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateTeamSelected: {
            switch (indexPath.section) {
                case 0: {
                    title = @"Sign Out";
                    value = self.participant.userName;
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Team";
                            value = self.participant.team.name;
                            accessoryType = UITableViewCellAccessoryNone;
                            break;
                        }
                        case 1: {
                            title = @"Invite a Participant";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                    }
                    break;
                }
                case 2: {
                    title = @"Clinical Setting";
                    WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:self.managedObjectContext];
                    value = navigationTrack.title;
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 3: {
                    title = @"Patient";
                    value = self.patient.lastNameFirstName;
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateDeferTeam: {
            switch (indexPath.section) {
                case 0: {
                    title = @"Sign Out";
                    value = self.participant.userName;
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Join Team";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 1: {
                            title = @"Create Team";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 2: {
                            title = @"Defer Joining Team";
                            if (nil == cell.accessoryView || ![cell.accessoryView isKindOfClass:[UISwitch class]]) {
                                UISwitch *deferTeamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                                [deferTeamSwitch addTarget:self action:@selector(deferTeamAction:) forControlEvents:UIControlEventValueChanged];
                                accessoryView = deferTeamSwitch;
                            } else {
                                accessoryView = cell.accessoryView;
                            }
                            break;
                        }
                    }
                    break;
                }
                case 2: {
                    title = @"Clinical Setting";
                    WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:self.managedObjectContext];
                    value = navigationTrack.title;
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 3: {
                    title = @"Patient";
                    value = self.patient.lastNameFirstName;
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
        }
    }

    cell.textLabel.text = title;
    cell.detailTextLabel.text = value;
    cell.imageView.image = image;
    cell.accessoryType = accessoryType;
    cell.accessoryView = accessoryView;
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
}

#pragma mark - SignInViewControllerDelegate

- (void)signInViewController:(WMSignInViewController *)viewController didSignInParticipant:(WMParticipant *)participant
{
    WM_ASSERT_MAIN_THREAD;
    participant.dateLastSignin = [NSDate date];
    self.appDelegate.participant = participant;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    // if participant has changed, we need to purge the local cache
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    NSString *lastUserName = userDefaultsManager.lastUserName;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        weakSelf.welcomeState = (nil == weakSelf.participant.team ? WMWelcomeStateSignedInNoTeam:WMWelcomeStateTeamSelected);
        [weakSelf.tableView reloadData];
        userDefaultsManager.lastUserName = participant.userName;
    };
    if (lastUserName && ![lastUserName isEqualToString:participant.userName]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [WMPatient MR_truncateAllInContext:managedObjectContext];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [NSManagedObjectContext MR_clearContextForCurrentThread];
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        });
    } else {
        block();
    }
}

- (void)signInViewControllerDidCancel:(WMSignInViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - CreateAccountDelegate

- (void)createAccountViewController:(WMCreateAccountViewController *)viewController didCreateParticipant:(WMParticipant *)participant
{
    participant.dateLastSignin = [NSDate date];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    self.appDelegate.participant = participant;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    userDefaultsManager.lastUserName = participant.userName;
    self.welcomeState = (nil == self.participant.team ? WMWelcomeStateSignedInNoTeam:WMWelcomeStateTeamSelected);
    [self.tableView reloadData];
}

- (void)createAccountViewControllerDidCancel:(WMCreateAccountViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - WMIAPJoinTeamViewControllerDelegate

- (void)iapJoinTeamViewControllerDidPurchase:(WMIAPJoinTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // TODO navigate to join team authentication
    }];
}

- (void)iapJoinTeamViewControllerDidDecline:(WMIAPJoinTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - IAPCreateTeamViewControllerDelegate

- (void)iapCreateTeamViewControllerDidPurchase:(WMIAPCreateTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController pushViewController:self.createTeamViewController animated:YES];
    }];
}

- (void)iapCreateTeamViewControllerDidDecline:(WMIAPCreateTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - CreateTeamViewControllerDelegate

- (void)createTeamViewController:(WMCreateTeamViewController *)viewController didCreateTeam:(WMTeam *)team
{
    self.participant.isTeamLeader = YES;
    self.participant.team = team;
    [self.navigationController popViewControllerAnimated:YES];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [ffm createTeamWithParticipant:self.participant user:(FFUser *)ff.loggedInUser ff:ff completionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (error) {
                [WMUtilities logError:error];
            } else {
                weakSelf.welcomeState = WMWelcomeStateTeamSelected;
                [weakSelf.tableView reloadData];
            }
        });
    }];
}

- (void)createTeamViewControllerDidCancel:(WMCreateTeamViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - CreateTeamInvitationViewControllerDelegate

- (void)createTeamInvitationViewController:(WMCreateTeamInvitationViewController *)viewController didCreateInvitation:(WMTeamInvitation *)teamInvitation
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    // add to back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [ffm createTeamInvitation:teamInvitation ff:ff completionHandler:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)createTeamInvitationViewControllerDidCancel:(WMCreateTeamInvitationViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - IAPCreateConsultantViewControllerDelegate

- (void)iapCreateConsultantViewControllerDidPurchase:(WMIAPCreateConsultantViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // TODO finish
    }];
}

- (void)iapCreateConsultantViewControllerDidDecline:(WMIAPCreateConsultantViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - ChooseTrackDelegate

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    self.appDelegate.navigationCoordinator.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    [self.tableView reloadData];
}

- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    __block WMPatient *patient = viewController.patient;
    // clear memory
    [viewController clearAllReferences];
    // update our reference to current patient
    self.appDelegate.navigationCoordinator.patient = patient;
    if (self.isIPadIdiom) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    // make sure the track/stage is set
    if (nil == patient.stage) {
        // set stage to initial for default clinical setting
        WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:managedObjectContext];
        WMNavigationStage *navigationStage = navigationTrack.initialStage;
        patient.stage = navigationStage;
    }
    [self showProgressViewWithMessage:@"Saving patient record"];
    __weak __typeof(self) weakSelf = self;
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf.tableView reloadData];
            weakSelf.enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
            // make sure participant belongs to consultantGroup REFERENCE /FFUserGroup, participantGroup REFERENCE /FFUserGroup
        }
    }];
}

- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController
{
    if (self.isIPadIdiom) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    // clear memory
    [viewController clearAllReferences];
    // confirm that we have a clean moc
    NSAssert1(![self.managedObjectContext hasChanges], @"self.managedObjectContext has changes", self.managedObjectContext);
}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient
{
    // update our reference to current patient
    if (nil != patient) {
        self.appDelegate.navigationCoordinator.patient = patient;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

@end
