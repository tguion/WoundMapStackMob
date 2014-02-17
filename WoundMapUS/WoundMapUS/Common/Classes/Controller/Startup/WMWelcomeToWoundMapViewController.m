//
//  WMWelcomeToWoundMapViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController.h"
#import "WMSignInViewController.h"
#import "WMIAPCreateTeamViewController.h"
#import "WMUserSignInViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPatientTableViewController.h"
#import "WMValue1TableViewCell.h"
#import "User.h"
#import "WMParticipant.h"
#import "WMNavigationTrack.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMUserDefaultsManager.h"
#import "WMPatientManager.h"
#import "WMSeedDatabaseManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

typedef NS_ENUM(NSInteger, WMWelcomeState) {
    WMWelcomeStateInitial,
    WMWelcomeStateTeamSelected,
    WMWelcomeStateDeferTeam,
    WMWelcomeStateParticipantSelected
};

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, UserSignInDelegate, IAPCreateTeamViewControllerDelegate, ChooseTrackDelegate, PatientDetailViewControllerDelegate, PatientTableViewControllerDelegate>

@property (nonatomic) WMWelcomeState welcomeState;
@property (readonly, nonatomic) WMSignInViewController *signInViewController;
@property (readonly, nonatomic) WMUserSignInViewController *userSignInViewController;
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
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    self.savePolicy = SMSavePolicyNetworkThenCache;
    self.enterWoundMapButton.enabled = self.setupConfigurationComplete;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"Cell";
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cellReuseIdentifier = @"Cell";
                    break;
                }
                case 1: {
                    cellReuseIdentifier = @"Cell";
                    break;
                }
                case 2: {
                    if (_welcomeState == WMWelcomeStateInitial) {
                        cellReuseIdentifier = @"Cell";
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
    if (nil == self.userDefaultsManager.defaultNavigationTrackTitle) {
        return NO;
    }
    // else
    return (nil != self.appDelegate.patient);
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

- (WMIAPCreateTeamViewController *)iapCreateTeamViewController
{
    WMIAPCreateTeamViewController *iapCreateTeamViewController = [[WMIAPCreateTeamViewController alloc] initWithNibName:@"WMIAPCreateTeamViewController" bundle:nil];
    iapCreateTeamViewController.delegate = self;
    return iapCreateTeamViewController;
}

- (WMChooseTrackViewController *)chooseTrackViewController
{
    WMChooseTrackViewController *chooseTrackViewController = [[WMChooseTrackViewController alloc] initWithNibName:@"WMChooseTrackViewController" bundle:nil];
    chooseTrackViewController.delegate = self;
    return chooseTrackViewController;
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
    patientDetailViewController.hideAddWoundFlag = YES;
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
- (IBAction)enterWoundMapAction:(id)sender
{
    NSLog(@"Hurray");
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
                    // join team
                    WMUserSignInViewController *userSignInViewController = self.userSignInViewController;
                    userSignInViewController.createNewUserFlag = NO;
                    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
                    User *user = [User userForUsername:userDefaultsManager.lastTeamName managedObjectContext:self.managedObjectContext persistentStore:self.store];
                    userSignInViewController.selectedUser = user;
                    [self.navigationController pushViewController:userSignInViewController animated:YES];
                    break;
                }
                case 1: {
                    // create team
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapCreateTeamViewController];
                    [self presentViewController:navigationController
                                       animated:YES
                                     completion:^{
                                         // nothing
                                     }];
                    break;
                }
                case 2: {
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
                    if (0 == patientCount) {
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
                    title = @"Join a Team";
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    title = @"Create a Team";
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 2: {
                    if (_welcomeState == WMWelcomeStateInitial) {
                        title = @"Defer Joining Team";
                        UISwitch *deferTeamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        [deferTeamSwitch addTarget:self action:@selector(deferTeamAction:) forControlEvents:UIControlEventValueChanged];
                        accessoryView = deferTeamSwitch;
                    } else {
                        title = @"Connected:";
                        image = [UIImage imageNamed:@"ui_checkmark"];
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
                        WMPatient *patient = self.appDelegate.patient;
                        if (nil == patient) {
                            WMPatientManager *patientManager = self.patientManager;
                            NSInteger patientCount = patientManager.patientCount;
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
                                self.appDelegate.patient = patient;
                                self.enterWoundMapButton.enabled = self.setupConfigurationComplete;
                            }
                        } else {
                            title = @"Patient";
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
    [self showProgressViewWithMessage:@"Updating Participant account"];
    __weak __typeof(self) weakSelf = self;
    __weak __typeof(viewController) weakViewController = viewController;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        [weakSelf hideProgressView];
        weakSelf.enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [weakViewController clearAllReferences];
        weakSelf.welcomeState = WMWelcomeStateParticipantSelected;
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

#pragma mark - IAPCreateTeamViewControllerDelegate

- (void)iapCreateTeamViewControllerDidPurchase:(WMIAPCreateTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        WMUserSignInViewController *userSignInViewController = self.userSignInViewController;
        userSignInViewController.createNewUserFlag = YES;
        [self.navigationController pushViewController:userSignInViewController animated:YES];
    }];
}

- (void)iapCreateTeamViewControllerDidDecline:(WMIAPCreateTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - ChooseTrackDelegate

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    WMUserDefaultsManager *userDefaultsManger = self.userDefaultsManager;
    userDefaultsManger.defaultNavigationTrackTitle = navigationTrack.title;
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
    self.appDelegate.patient = patient;
    if (self.isIPadIdiom) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    // save patient first, then associated stage
    [self showProgressViewWithMessage:@"Saving patient record"];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        NSManagedObjectContext *managedObjectContext = weakSelf.managedObjectContext;
        NSPersistentStore *store = weakSelf.store;
        // make sure the track/stage is set
        if (nil == patient.stage) {
            // set stage to initial for default clinical setting
            WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:managedObjectContext persistentStore:store];
            WMNavigationStage *navigationStage = navigationTrack.initialStage;
            patient.stage = navigationStage;
        }
        // save again
        [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
            [WMUtilities logError:error];
            // make sure the user (sm_owner) has access via the consultants relationship
            User *user = [User userForUsername:self.appDelegate.stackMobUsername
                          managedObjectContext:managedObjectContext persistentStore:store];
            WMParticipant *participant = self.appDelegate.participant;
            WMPatientConsultant *patientConsultant = [WMPatientConsultant patientConsultantForPatient:patient
                                                                                           consultant:user
                                                                                          participant:participant
                                                                                               create:YES
                                                                                 managedObjectContext:managedObjectContext
                                                                                      persistentStore:store];
            patientConsultant.acquiredFlagValue = NO;
            // save again
            [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
                [WMUtilities logError:error];
                [weakSelf hideProgressView];
                [weakSelf.tableView reloadData];
                weakSelf.enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
            }];
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
        self.appDelegate.patient = patient;
    }
    [self.navigationController popViewControllerAnimated:YES];
//    [viewController clearAllReferences];
    [self.tableView reloadData];
}

- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

@end
