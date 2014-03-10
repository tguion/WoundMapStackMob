//
//  WMWelcomeToWoundMapViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController.h"
#import "WMSignInViewController.h"
#import "WMIAPJoinTeamViewController.h"
#import "WMIAPCreateTeamViewController.h"
#import "WMIAPCreateConsultantViewController.h"
#import "WMUserSignInViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPatientTableViewController.h"
#import "WMInstructionsViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMButtonCell.h"
#import "WMParticipant.h"
#import "WMNavigationTrack.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMUserDefaultsManager.h"
#import "WMPatientManager.h"
#import "WMSeedDatabaseManager.h"
#import "WMNavigationCoordinator.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import <FFEF/FatFractal.h>

typedef NS_ENUM(NSInteger, WMWelcomeState) {
    WMWelcomeStateInitial,
    WMWelcomeStateTeamSelected,
    WMWelcomeStateDeferTeam,
};

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, UserSignInDelegate, WMIAPJoinTeamViewControllerDelegate, IAPCreateTeamViewControllerDelegate, IAPCreateConsultantViewControllerDelegate, ChooseTrackDelegate, PatientDetailViewControllerDelegate, PatientTableViewControllerDelegate>

@property (nonatomic) WMWelcomeState welcomeState;
@property (readonly, nonatomic) BOOL connectedTeamIsConsultingGroup;
@property (readonly, nonatomic) WMSignInViewController *signInViewController;
@property (readonly, nonatomic) WMUserSignInViewController *userSignInViewController;
@property (readonly, nonatomic) WMIAPJoinTeamViewController *iapJoinTeamViewController;
@property (readonly, nonatomic) WMIAPCreateTeamViewController *iapCreateTeamViewController;

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
    id<FFUserProtocol> user = [     loggedInUser
    if([self.coreDataHelper.stackMobClient isLoggedIn]) {
        __weak __typeof(self) weakSelf = self;
        [self.coreDataHelper.stackMobClient getLoggedInUserOnSuccess:^(NSDictionary *result) {
            weakSelf.appDelegate.stackMobUsername = [result objectForKey:@"username"];
            _welcomeState = WMWelcomeStateTeamSelected;
            [weakSelf.tableView reloadData];
        } onFailure:^(NSError *error) {
            self.appDelegate.stackMobUsername = nil;
            [weakSelf.tableView reloadData];
        }];
    } else {
        self.appDelegate.stackMobUsername = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (BOOL)connectedTeamIsConsultingGroup
{
    if (nil == self.appDelegate.stackMobUsername) {
        return NO;
    }
    // else
    User *user = [User userForUsername:self.appDelegate.stackMobUsername managedObjectContext:self.managedObjectContext persistentStore:self.store];
    return nil != user.consultingGroup;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"Cell";
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // Join Team or Conntected
                    cellReuseIdentifier = (_welcomeState == WMWelcomeStateTeamSelected ? @"ValueCell":@"Cell");
                    break;
                }
                case 1: {
                    // Create Team or Disconnect
                    cellReuseIdentifier = (_welcomeState == WMWelcomeStateTeamSelected ? @"ButtonCell":@"Cell");
                    break;
                }
                case 2: {
                    // Defer or Consultant
                    if (_welcomeState == WMWelcomeStateInitial || _welcomeState == WMWelcomeStateDeferTeam) {
                        cellReuseIdentifier = @"DeferCell";
                    } else {
                        cellReuseIdentifier = @"ValueCell";
                    }
                    break;
                }
            }
            break;
        }
        case 1: {
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
    if (nil == self.appDelegate.participant) {
        return NO;
    }
    // else
    if (nil == self.userDefaultsManager.defaultNavigationTrackId) {
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

- (WMUserSignInViewController *)userSignInViewController
{
    WMUserSignInViewController *userSignInViewController = [[WMUserSignInViewController alloc] initWithNibName:@"WMUserSignInViewController" bundle:nil];
    userSignInViewController.delegate = self;
    return userSignInViewController;
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
    self.welcomeState = (deferTeamSwitch.isOn ? WMWelcomeStateDeferTeam:WMWelcomeStateInitial);
    if (deferTeamSwitch.isOn) {
        self.tableView.tableFooterView = _footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
    [self.tableView reloadData];
}

- (IBAction)disconnectFromTeamAction:(id)sender
{
    [self showProgressViewWithMessage:@"Disconnecting from Team"];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper.stackMobClient logoutOnSuccess:^(NSDictionary *result) {
        DLog(@"result: %@", result);
        _welcomeState = WMWelcomeStateInitial;
        weakSelf.appDelegate.stackMobUsername = nil;
        [weakSelf.tableView reloadData];
        [weakSelf hideProgressView];
    } onFailure:^(NSError *error) {
        [weakSelf hideProgressView];
    }];
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

// network synch with server has finished - subclasses may need to override
- (void)handleStackMobNetworkSynchFinished:(NSNotification *)notification
{
    // install footer to allow access to WoundMap
    self.tableView.tableFooterView = _footerView;
    [super handleStackMobNetworkSynchFinished:notification];
    self.enterWoundMapButton.enabled = self.setupConfigurationComplete;
    // seed StackMob
    WMSeedDatabaseManager *seedDatabaseManager = [WMSeedDatabaseManager sharedInstance];
    __weak __typeof(self) weakSelf = self;
    [seedDatabaseManager seedTeamDatabaseWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideProgressView];
        });
    }];
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
                    // join team or connected
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        // nothing - should not be able to select
                        break;
                    }
                    // else navigate to join team
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapJoinTeamViewController];
                    [self presentViewController:navigationController
                                       animated:YES
                                     completion:^{
                                         // nothing
                                     }];

                    break;
                }
                case 1: {
                    // create team or disconnect
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        // disconnect - should not select this cell
                        break;
                    }
                    // else navigate to create team
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapCreateTeamViewController];
                    [self presentViewController:navigationController
                                       animated:YES
                                     completion:^{
                                         // nothing
                                     }];
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
                    // else user selected to defer - should not be able to select cell
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // create account/sign in
                    [self.navigationController pushViewController:self.signInViewController animated:YES];
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
                    if (4 == patientCount) {
                        [self presentAddPatientViewController];
                    } else {
                        [self presentChoosePatientViewController];
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
    return (_welcomeState >= WMWelcomeStateTeamSelected ? 2:1);
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
            count = 3;
            break;
        }
        case 1: {
            if (nil == self.appDelegate.participant) {
                count = 1;
            } else if (nil == self.userDefaultsManager.defaultNavigationTrackId) {
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
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // join team or connected
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        title = @"Connected:";
                        image = [UIImage imageNamed:@"ui_checkmark"];
                        value = self.appDelegate.stackMobUsername;
                    } else {
                        title = @"Join a Team";
                        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    break;
                }
                case 1: {
                    // create or disconnect
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        WMButtonCell *myCell = (WMButtonCell *)cell;
                        NSAssert1([myCell isKindOfClass:[WMButtonCell class]], @"Expected WMButtonCell, but have %@", cell);
                        if (0 == [myCell.button.allTargets count]) {
                            [myCell.button setTitle:[NSString stringWithFormat:@"Disconnect from Team %@", self.appDelegate.stackMobUsername] forState:UIControlStateNormal];
                            [myCell.button addTarget:self action:@selector(disconnectFromTeamAction:) forControlEvents:UIControlEventTouchUpInside];
                        }
                    } else {
                        title = @"Create a Team";
                        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    break;
                }
                case 2: {
                    // defer OR become consultant or team is a consultant
                    if (_welcomeState == WMWelcomeStateTeamSelected) {
                        if (self.connectedTeamIsConsultingGroup) {
                            title = @"Team is Register Consultant";
                        } else {
                            title = @"Register as a Consultant";
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        }
                    } else {
                        // defer
                        if (_welcomeState == WMWelcomeStateInitial) {
                            title = @"Defer Joining Team";
                            if (nil == cell.accessoryView && ![cell.accessoryView isKindOfClass:[UISwitch class]]) {
                                UISwitch *deferTeamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                                [deferTeamSwitch addTarget:self action:@selector(deferTeamAction:) forControlEvents:UIControlEventValueChanged];
                                accessoryView = deferTeamSwitch;
                            } else {
                                accessoryView = cell.accessoryView;
                            }
                        } else if (_welcomeState == WMWelcomeStateDeferTeam) {
                            title = @"Deferring Joining Team";
                            accessoryView = cell.accessoryView;
                        }
                    }
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
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
                        WMPatient *patient = self.appDelegate.navigationCoordinator.patient;
                        WMPatientManager *patientManager = self.patientManager;
                        NSInteger patientCount = patientManager.patientCount;
                        if (nil == patient) {
                            if (0 == patientCount) {
                                title = @"Add Patient";
                                image = [UIImage imageNamed:@"ui_circle"];
                                accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            } else {
                                if (patientCount == 1) {
                                    title = @"Patient Added";
                                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                } else {
                                    title = @"Current Patient";
                                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }
                                patient = patientManager.lastModifiedActivePatient;
                                value = patient.lastNameFirstName;
                                image = [UIImage imageNamed:@"ui_checkmark"];
                                self.appDelegate.navigationCoordinator.patient = patient;
                                self.enterWoundMapButton.enabled = self.setupConfigurationComplete;
                            }
                        } else {
                            title = @"Patient";
                            accessoryType = (patientCount == 1 ? UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator);
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
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
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
    [self showProgressViewWithMessage:@"Updating Participant account"];
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        [weakSelf hideProgressView];
        weakSelf.enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UserSignInDelegate

- (void)userSignInViewController:(WMUserSignInViewController *)viewController didSignInUsername:(NSString *)username
{
    [self showProgressViewWithMessage:@"Updating Team Account"];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        weakSelf.appDelegate.stackMobUsername = username;
        [weakSelf.navigationController popViewControllerAnimated:YES];
        weakSelf.welcomeState = WMWelcomeStateTeamSelected;
        // now that we have a team, synch with server and wait for call back
        [weakSelf.coreDataHelper.stackMobStore syncWithServer];
    }];
}

- (void)userSignInViewControllerDidCancel:(WMUserSignInViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WMIAPJoinTeamViewControllerDelegate

- (void)iapJoinTeamViewControllerDidPurchase:(WMIAPJoinTeamViewController *)viewController
{
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        WMUserSignInViewController *userSignInViewController = weakSelf.userSignInViewController;
        userSignInViewController.createNewUserFlag = NO;
        WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
        User *user = [User userForUsername:userDefaultsManager.lastTeamName managedObjectContext:weakSelf.managedObjectContext persistentStore:weakSelf.store];
        userSignInViewController.selectedUser = user;
        [weakSelf.navigationController pushViewController:userSignInViewController animated:YES];
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
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        WMUserSignInViewController *userSignInViewController = weakSelf.userSignInViewController;
        userSignInViewController.createNewUserFlag = YES;
        [weakSelf.navigationController pushViewController:userSignInViewController animated:YES];
    }];
}

- (void)iapCreateTeamViewControllerDidDecline:(WMIAPCreateTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
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
    WMUserDefaultsManager *userDefaultsManger = self.userDefaultsManager;
    userDefaultsManger.defaultNavigationTrackId = navigationTrack.wmnavigationtrack_id;
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
    CoreDataHelper *coreDataHelper = self.coreDataHelper;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    // make sure the track/stage is set
    if (nil == patient.stage) {
        // set stage to initial for default clinical setting
        WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:managedObjectContext persistentStore:store];
        WMNavigationStage *navigationStage = navigationTrack.initialStage;
        patient.stage = navigationStage;
    }
    [self showProgressViewWithMessage:@"Saving patient record"];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        // make sure the user (sm_owner) has access via the consultants relationship
        User *user = nil;
        if([coreDataHelper.stackMobClient isLoggedIn]) {
            user = [User userForUsername:weakSelf.appDelegate.stackMobUsername
                    managedObjectContext:managedObjectContext persistentStore:store];
            WMParticipant *participant = weakSelf.appDelegate.participant;
            WMPatientConsultant *patientConsultant = [WMPatientConsultant patientConsultantForPatient:patient
                                                                                           consultant:user
                                                                                          participant:participant
                                                                                               create:YES
                                                                                 managedObjectContext:managedObjectContext
                                                                                      persistentStore:store];
            patientConsultant.acquiredFlagValue = NO;
        }
        [weakSelf.tableView reloadData];
        weakSelf.enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
        // save again
        [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
            [WMUtilities logError:error];
            [weakSelf hideProgressView];
        }];
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
