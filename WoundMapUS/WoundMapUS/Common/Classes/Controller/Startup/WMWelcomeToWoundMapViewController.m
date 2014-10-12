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
#import "WMPersonEditorViewController.h"
#import "WMOrganizationEditorViewController.h"
#import "WMManageTeamViewController.h"
#import "WMIAPJoinTeamViewController.h"
#import "WMCreateTeamViewController.h"
#import "WMCreateConsultingGroupViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPatientTableViewController.h"
#import "WMInstructionsViewController.h"
#import "WMHomeBaseViewController_iPhone.h"
#import "WMHomeBaseViewController_iPad.h"
#import "WMValue1TableViewCell.h"
#import "WMButtonCell.h"
#import "MBProgressHUD.h"
#import "WMInterventionStatusJoin.h"
#import "WMTelecomType.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMOrganization.h"
#import "WMTelecom.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "WMConsultingGroup.h"
#import "WMNavigationTrack.h"
#import "WMPatient.h"
#import "IAPProduct.h"
#import "WMPaymentTransaction.h"
#import "WMUnhandledSilentUpdateNotification.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "KeychainItemWrapper.h"
#import "IAPManager.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"

#define kUpdateSilentNotificationsAlertViewTag 1000

typedef NS_ENUM(NSInteger, WMWelcomeState) {
    WMWelcomeStateInitial,              // Sign In, Create Account
    WMWelcomeStateSignedInNoTeam,       // Sign Out | Join Team, Create Team, No Team (signed in user has not joined/created a team)
    WMWelcomeStateInvitationAccepted,   // Sign Out | Team (value) | Clinical Setting | Patient
    WMWelcomeStateTeamSelected,         // Sign Out | Team (value) | Clinical Setting | Patient
    WMWelcomeStateDeferTeam,            // Sign Out | Join Team, Create Team, No Team | Clinical Setting | Patient
};

@interface WMWelcomeToWoundMapViewController () <SignInViewControllerDelegate, CreateAccountDelegate, PersonEditorViewControllerDelegate, OrganizationEditorViewControllerDelegate, WMIAPJoinTeamViewControllerDelegate, CreateTeamViewControllerDelegate, IAPCreateConsultantViewControllerDelegate, ChooseTrackDelegate, PatientDetailViewControllerDelegate, PatientTableViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *descHTMLContainerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) WMWelcomeState welcomeState;
@property (readonly, nonatomic) BOOL connectedTeamIsConsultingGroup;
@property (readonly, nonatomic) WMSignInViewController *signInViewController;
@property (readonly, nonatomic) WMCreateAccountViewController *createAccountViewController;
@property (readonly, nonatomic) WMIAPJoinTeamViewController *iapJoinTeamViewController;
@property (readonly, nonatomic) WMCreateTeamViewController *createTeamViewController;
@property (readonly, nonatomic) WMCreateConsultingGroupViewController *createConsultingGroupViewController;
@property (readonly, nonatomic) WMManageTeamViewController *manageTeamViewController;
@property (readonly, nonatomic) WMPersonEditorViewController *personEditorViewController;
@property (readonly, nonatomic) WMOrganizationEditorViewController *organizationEditorViewController;

@property (readonly, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMTeamInvitation *teamInvitation;

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
    self.tableView.tableFooterView = _footerView;
    _enterWoundMapButton.enabled = self.setupConfigurationComplete;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    if (!userDefaultsManager.splashViewInstructionViewed) {
        [self presentSplashViewInstructionsView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentSplashViewInstructionsView
{
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"SplashReadInstructions" withExtension:@"html"];
    NSError *error = nil;
    NSString *_htmlString = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    [_webView loadHTMLString:_htmlString baseURL:nil];
    _descHTMLContainerView.frame = self.view.bounds;
    [self.view addSubview:_descHTMLContainerView];
}

#pragma mark - Core

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

- (WMTeamInvitation *)teamInvitation
{
    if (nil == _teamInvitation) {
        _teamInvitation = [WMTeamInvitation MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMTeamInvitationAttributes.inviteeUserName, self.participant.userName]];
    }
    return _teamInvitation;
}

- (WMPerson *)person
{
    return self.participant.person;
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
            switch (_welcomeState) {
                case WMWelcomeStateInitial: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case WMWelcomeStateSignedInNoTeam: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case WMWelcomeStateInvitationAccepted: {
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
        case 2: {
            cellReuseIdentifier = @"ValueCell";
            break;
        }
        case 3: {
            cellReuseIdentifier = @"ValueCell";
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
    return YES;
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
    iapJoinTeamViewController.teamInvitation = self.teamInvitation;
    iapJoinTeamViewController.delegate = self;
    return iapJoinTeamViewController;
}

- (WMCreateTeamViewController *)createTeamViewController
{
    WMCreateTeamViewController *createTeamViewController = [[WMCreateTeamViewController alloc] initWithNibName:@"WMCreateTeamViewController" bundle:nil];
    createTeamViewController.delegate = self;
    return createTeamViewController;
}

- (WMCreateConsultingGroupViewController *)createConsultingGroupViewController
{
    WMCreateConsultingGroupViewController *createConsultingGroupViewController = [[WMCreateConsultingGroupViewController alloc] initWithNibName:@"WMCreateConsultingGroupViewController" bundle:nil];
    createConsultingGroupViewController.delegate = self;
    return createConsultingGroupViewController;
}

- (WMManageTeamViewController *)manageTeamViewController
{
    return [[WMManageTeamViewController alloc] initWithNibName:@"WMManageTeamViewController" bundle:nil];
}

- (WMPersonEditorViewController *)personEditorViewController
{
    WMPersonEditorViewController *personEditorViewController = [[WMPersonEditorViewController alloc] initWithNibName:@"WMPersonEditorViewController" bundle:nil];
    personEditorViewController.delegate = self;
    return personEditorViewController;
}

- (WMOrganizationEditorViewController *)organizationEditorViewController
{
    WMOrganizationEditorViewController *organizationEditorViewController = [[WMOrganizationEditorViewController alloc] initWithNibName:@"WMOrganizationEditorViewController" bundle:nil];
    organizationEditorViewController.delegate = self;
    organizationEditorViewController.organization = self.participant.organization;
    return organizationEditorViewController;
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
    if (self.teamInvitation) {
        if (self.teamInvitation.isAccepted) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invitation Accepted"
                                                                message:@"You have already accepted the invitation. The team leader has been notified and must complete the transaction."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            // present controller to enter pin code, and thus accept the team invitation
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.iapJoinTeamViewController];
            [self presentViewController:navigationController
                               animated:YES
                             completion:^{
                                 // nothing
                             }];
        }
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
    [self.navigationController pushViewController:self.createTeamViewController animated:YES];
}

- (void)presentTeamManagementController
{
    [self.navigationController pushViewController:self.manageTeamViewController animated:YES];
}

- (void)presentChooseNavigationTrack
{
    // make sure the nodes have been loaded
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        [weakSelf.navigationController pushViewController:weakSelf.chooseTrackViewController animated:YES];
    };
    NSInteger count = [WMNavigationTrack MR_countOfEntitiesWithPredicate:self.navigationTrackPredicate inContext:managedObjectContext];
    if (count == 0) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
            block();
        };
        [MBProgressHUD showHUDAddedTo:self.view animated:NO].labelText = @"Acquiring account data";
        [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=2", [WMNavigationNode entityName]] onComplete:onComplete];
    } else {
        block();
    }
}

- (void)presentCreateConsultingGroupViewController
{
    [self.navigationController pushViewController:self.createConsultingGroupViewController animated:YES];
}

- (WMPatientDetailViewController *)patientDetailViewController
{
    WMPatientDetailViewController *patientDetailViewController = [[WMPatientDetailViewController alloc] initWithNibName:@"WMPatientDetailViewController" bundle:nil];
    patientDetailViewController.delegate = self;
    return patientDetailViewController;
}

- (void)presentAddPatientViewController
{
    // create new patient
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

#pragma mark - Notification handlers

- (void)handlePatientRefreshingFromCloud:(NSManagedObjectID *)patientObjectId
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.labelText = @"Updating Patient...";
    hud.detailsLabelText = @"This may take a minute.";
}

- (void)handlePatientRefreshedFromCloud:(NSManagedObjectID *)patientObjectId
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

- (void)handleTeamInvitationUpdated:(NSString *)teamInvitationGUID
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __block NSInteger counter = 1;
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (0 == counter || --counter == 0) {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.tableView reloadData];
        }
    };
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=2", [WMTeamInvitation entityName]] onComplete:onComplete];
}

- (void)handleTeamMemberAdded:(NSString *)teamGUID
{
    // do not alert when the team leader is added
    if (self.participant.isTeamLeader) {
        return;
    }
    // else update the participant
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    WMErrorCallback errorCallback = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        _welcomeState = WMWelcomeStateTeamSelected;
        [weakSelf.tableView reloadData];
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Acquiring Team";
    [ffm updateParticipant:self.participant completionHandler:errorCallback];
}

#pragma mark - Actions

- (IBAction)dismissSplashViewInstructions:(id)sender
{
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    userDefaultsManager.splashViewInstructionViewed = YES;
    [_descHTMLContainerView removeFromSuperview];
}

- (IBAction)deferTeamAction:(id)sender
{
    UISwitch *deferTeamSwitch = (UISwitch *)sender;
    _welcomeState = (deferTeamSwitch.isOn ? WMWelcomeStateDeferTeam:WMWelcomeStateSignedInNoTeam);
    _enterWoundMapButton.enabled = self.setupConfigurationComplete;
    [self.tableView reloadData];
}

- (UIViewController *)initialRootViewController
{
    UIViewController *viewController = nil;
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (isPad) {
        viewController = [[WMHomeBaseViewController_iPad alloc] initWithNibName:@"WMHomeBaseViewController_iPad" bundle:nil];
    } else {
        viewController = [[WMHomeBaseViewController_iPhone alloc] initWithNibName:@"WMHomeBaseViewController_iPhone" bundle:nil];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (self.isIPadIdiom) {
        return navigationController;
    }
    // else
    navigationController.delegate = self.appDelegate.navigationCoordinator;
    return navigationController;
}

- (IBAction)enterWoundMapAction:(id)sender
{
    // check if all information has been entered
    WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
    NSString *alertMessage = nil;
    if (_welcomeState == WMWelcomeStateSignedInNoTeam) {
        alertMessage = @"Please select 'Defer Team' or 'Create a Team'.";
    } else if (nil == navigationCoordinator.navigationTrack) {
        alertMessage = @"Please select a Clinical Setting.";
    } else if (_welcomeState != WMWelcomeStateInvitationAccepted) {
        if (_welcomeState != WMWelcomeStateDeferTeam && nil == self.participant.team) {
            alertMessage = @"Please select 'Defer Team' or 'Create a Team'.";
        }
    }
    if (nil == alertMessage) {
        WMPatient *patient = self.patient;
        if (nil == alertMessage && (nil == patient || ![self.appDelegate.navigationCoordinator canEditPatientOnDevice:patient])) {
            alertMessage = @"Please select or add a patient.";
        }
    }
    if (alertMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Action Required"
                                                            message:alertMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else
    UIViewController *viewController = self.initialRootViewController;
    [UIView transitionWithView:self.appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.appDelegate.window.rootViewController = viewController;
                    } completion:^(BOOL finished) {
                        
                    }];
}

- (IBAction)viewInstructionsAction:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.instructionsViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    // else
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Updating team data...";
    NSArray *notifications = [WMUnhandledSilentUpdateNotification silentUpdateNotificationsForUserName:self.participant.userName managedObjectContext:managedObjectContext];
    for (WMUnhandledSilentUpdateNotification *notification in notifications) {
        [self.appDelegate downloadFFDataForCollection:notification.notification fetchCompletionHandler:nil];
    }
    [managedObjectContext MR_deleteObjects:notifications];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"/%@", [WMTeamInvitation entityName]], [NSString stringWithFormat:@"/%@", [WMTeam entityName]]];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
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
                        [self.appDelegate signOut];
                        _welcomeState = WMWelcomeStateInitial;
                        _enterWoundMapButton.enabled = NO;
                        [tableView reloadData];
                    }
                    break;
                }
                case 1: {
                    if (_welcomeState == WMWelcomeStateInitial) {
                        // create account
                        [self.navigationController pushViewController:self.createAccountViewController animated:YES];
                    } else {
                        // contact details
                        WMPersonEditorViewController *personEditorViewController = self.personEditorViewController;
                        personEditorViewController.person = self.participant.person;
                        [self.navigationController pushViewController:personEditorViewController animated:YES];
                    }
                    break;
                }
                case 2: {
                    // organization
                    [self.navigationController pushViewController:self.organizationEditorViewController animated:YES];
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
                    if (_welcomeState == WMWelcomeStateInvitationAccepted || _welcomeState == WMWelcomeStateSignedInNoTeam || _welcomeState == WMWelcomeStateDeferTeam) {
                        [self presentJoinTeamViewController];
                    } else if (self.participant.isTeamLeader) {
                        [self presentTeamManagementController];
                    }
                    break;
                }
                case 1: {
                    if (self.participant.isTeamLeader) {
                        // is the team already a consultant group
                        if (self.connectedTeamIsConsultingGroup) {
                            // TODO manage consulting group
                            break;
                        }
                        // else IAP for creating a consulting group DEPLOYMENT
                        if (NO) {
                            BOOL proceed = [self presentIAPViewControllerForProductIdentifier:kCreateConsultingGroupProductIdentifier
                                                                                 successBlock:^(SKPaymentTransaction *transaction) {
                                                                                     // mark WMPaymentTransaction as applied
                                                                                     WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                                                                                                            originalTransaction:nil
                                                                                                                                                                                       username:weakSelf.participant.userName
                                                                                                                                                                                         create:NO
                                                                                                                                                                           managedObjectContext:managedObjectContext];
                                                                                     paymentTransaction.appliedFlagValue = YES;
                                                                                     [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                     FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                                                         if (error) {
                                                                                             [WMUtilities logError:error];
                                                                                         }
                                                                                         [weakSelf presentCreateConsultingGroupViewController];
                                                                                     };
                                                                                     [ff updateObj:paymentTransaction
                                                                                        onComplete:onComplete onOffline:onComplete];
                                                                                 } withObject:self.view];
                            if (proceed) {
                                [self presentCreateConsultingGroupViewController];
                            }
                        } else {
                            [self presentCreateConsultingGroupViewController];
                        }
                    } else {
                        // IAP for creating a team, and the team leader (the signed-in participant) will be the first team member
                        if (kPresentIAPController) {
                            BOOL proceed = [self presentIAPViewControllerForProductIdentifier:kTeamMemberProductIdentifier
                                                                                 successBlock:^(SKPaymentTransaction *transaction) {
                                                                                     // mark WMPaymentTransaction as applied
                                                                                     WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                                                                                                            originalTransaction:nil
                                                                                                                                                                                       username:weakSelf.participant.userName
                                                                                                                                                                                         create:NO
                                                                                                                                                                           managedObjectContext:managedObjectContext];
                                                                                     paymentTransaction.appliedFlagValue = YES;
                                                                                     [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                     FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                                                         if (error) {
                                                                                             [WMUtilities logError:error];
                                                                                         }
                                                                                         WMParticipant *participant = weakSelf.participant;
                                                                                         participant.dateTeamSubscriptionExpires = [WMUtilities dateByAddingMonths:kNumberFreeMonthsFirstSubscription toDate:participant.dateTeamSubscriptionExpires];
                                                                                         [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                         [ff updateObj:participant];
                                                                                         [weakSelf presentCreateTeamViewController];
                                                                                     };
                                                                                     [ff updateObj:paymentTransaction
                                                                                        onComplete:onComplete onOffline:onComplete];
                                                                                 } proceedAlways:YES withObject:self.view];
                            if (proceed) {
                                [self presentCreateTeamViewController];
                            }
                        } else {
                            [self presentCreateTeamViewController];
                        }
                    }
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
            NSInteger patientCount = 0;
            if (self.participant.team) {
                patientCount = [WMPatient patientCount:managedObjectContext];
            } else {
                patientCount = [WMPatient patientCount:managedObjectContext onDevice:[[IAPManager sharedInstance] getIAPDeviceGuid]];
            }
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
    switch (_welcomeState) {
        case WMWelcomeStateInitial: {
            count = 1;
            break;
        }
        case WMWelcomeStateSignedInNoTeam: {
            count = 2;
            break;
        }
        case WMWelcomeStateInvitationAccepted: {
            count = 4;
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
    switch (_welcomeState) {
        case WMWelcomeStateInitial: {
            count = 2;
            break;
        }
        case WMWelcomeStateSignedInNoTeam: {
            switch (section) {
                case 0: {
                    count = 3;
                    break;
                }
                case 1: {
                    count = 3;
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateInvitationAccepted:
        case WMWelcomeStateTeamSelected: {
            switch (section) {
                case 0: {
                    count = 3;
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
                    count = 3;
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
    switch (_welcomeState) {
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
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Sign Out";
                            value = self.participant.userName;
                            break;
                        }
                        case 1: {
                            title = @"Contact Details";
                            value = self.participant.lastNameFirstName;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 2: {
                            title = @"Organization";
                            value = self.participant.organization.name;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                    }
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Join Team";
                            if (self.teamInvitation) {
                                value = (self.teamInvitation.acceptedFlagValue ? @"accepted":@"invitation");// TODO show icon
                            }
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
        case WMWelcomeStateInvitationAccepted:
        case WMWelcomeStateTeamSelected: {
            switch (indexPath.section) {
                case 0: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Sign Out";
                            value = self.participant.userName;
                            break;
                        }
                        case 1: {
                            title = @"Contact Details";
                            value = self.participant.lastNameFirstName;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 2: {
                            title = @"Organization";
                            value = self.participant.organization.name;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                    }
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: {
                            if (_welcomeState == WMWelcomeStateInvitationAccepted) {
                                title = @"Invitation Accepted";
                                value = @"Pending Approval";
                                accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            } else {
                                title = @"Team";
                                value = self.participant.team.name;
                                accessoryType = UITableViewCellAccessoryNone;
                                if (self.participant.isTeamLeader) {
                                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }
                            }
                            break;
                        }
                        case 1: {
                            title = @"Consulting Group";
                            value = self.participant.team.consultingGroup.name;
                            accessoryType = UITableViewCellAccessoryNone;
                            if (self.participant.isTeamLeader) {
                                accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                    WMPatient *patient = self.patient;
                    if ([self.appDelegate.navigationCoordinator canEditPatientOnDevice:patient]) {
                        value = self.patient.lastNameFirstName;
                    }
                    accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
        case WMWelcomeStateDeferTeam: {
            switch (indexPath.section) {
                case 0: {
                    switch (indexPath.row) {
                        case 0: {
                            title = @"Sign Out";
                            value = self.participant.userName;
                            break;
                        }
                        case 1: {
                            title = @"Contact Details";
                            value = self.participant.lastNameFirstName;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                        case 2: {
                            title = @"Organization";
                            value = self.participant.organization.name;
                            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            break;
                        }
                    }
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
                    WMPatient *patient = self.patient;
                    if ([self.appDelegate.navigationCoordinator canEditPatientOnDevice:patient]) {
                        value = self.patient.lastNameFirstName;
                    }
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
    WMTeam *team = participant.team;
    WMTeamInvitation *teamInvitation = self.teamInvitation;
    [self.navigationController popViewControllerAnimated:YES];
    [[IAPManager sharedInstance] processPendingTransactions];
    // if participant has changed, we need to purge the local cache
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    NSString *lastUserName = userDefaultsManager.lastUserName;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        if (team) {
            weakSelf.welcomeState = WMWelcomeStateTeamSelected;
        } else if (teamInvitation.isAccepted) {
            weakSelf.welcomeState = WMWelcomeStateInvitationAccepted;
        } else {
            weakSelf.welcomeState = WMWelcomeStateSignedInNoTeam;
        }
        [weakSelf.tableView reloadData];
        userDefaultsManager.lastUserName = participant.userName;
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        _enterWoundMapButton.enabled = weakSelf.setupConfigurationComplete;
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        // synchronize any data that was not handled by silent remote notification
        NSArray *notifications = [WMUnhandledSilentUpdateNotification silentUpdateNotificationsForUserName:participant.userName managedObjectContext:managedObjectContext];
        if ([notifications count]) {
            // let user synchronize now or later
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Team Updates Available"
                                                                message:@"Team members have updated patient data. Do you want to synchronize with the team now?"
                                                               delegate:self
                                                      cancelButtonTitle:@"No Now"
                                                      otherButtonTitles:@"Update Now", nil];
            alertView.tag = kUpdateSilentNotificationsAlertViewTag;
            [alertView show];
        }
    };
    if ([lastUserName isEqualToString:participant.userName]) {
        // attempt to acquire last patient and wound
        NSParameterAssert(participant.guid);
        WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
        NSString *patientFFUrl = [userDefaultsManager lastPatientFFURLForUserGUID:participant.guid];
        if (patientFFUrl) {
            NSString *uri = [patientFFUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
            [ff getObjFromUri:uri onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                }
                if (object) {
                    NSParameterAssert([object isKindOfClass:[WMPatient class]]);
                    WMPatient *patient = (WMPatient *)object;
                    // wait for notification that patient has updated
                    navigationCoordinator.patient = patient;
                    NSString *woundFFUrl = [userDefaultsManager lastWoundFFURLOnDeviceForPatientFFURL:patientFFUrl];
                    if (woundFFUrl) {
                        NSString *uri = [woundFFUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
                        [ff getObjFromUri:uri onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                if (response.statusCode == 404) {
                                    // it was deleted
                                    [userDefaultsManager setLastWoundFFURLOnDevice:nil forPatientFFURL:patientFFUrl];
                                    navigationCoordinator.wound = nil;
                                    WMWound *wound = [WMWound MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMWoundAttributes.ffUrl, woundFFUrl] inContext:managedObjectContext];
                                    if (wound) {
                                        [managedObjectContext MR_deleteObjects:@[wound]];
                                    }
                                }
                                [WMUtilities logError:error];
                            }
                            if (object) {
                                NSParameterAssert([object isKindOfClass:[WMWound class]]);
                                WMWound *wound = (WMWound *)object;
                                navigationCoordinator.wound = wound;
                            }
                            block();
                        }];
                    } else {
                        block();
                    }
                } else {
                    block();
                }
            }];
        } else {
            block();
        }
    } else {
        block();
    }
}

- (void)signInViewControllerDidCancel:(WMSignInViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CreateAccountDelegate

- (void)createAccountViewController:(WMCreateAccountViewController *)viewController didCreateParticipant:(WMParticipant *)participant
{
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    [self.navigationController popViewControllerAnimated:YES];
    self.appDelegate.participant = participant;
    userDefaultsManager.lastUserName = participant.userName;
    _welcomeState = (nil == self.participant.team ? WMWelcomeStateSignedInNoTeam:WMWelcomeStateTeamSelected);
    [self.tableView reloadData];
}

- (void)createAccountViewControllerDidCancel:(WMCreateAccountViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - PersonEditorViewControllerDelegate

- (void)personEditorViewController:(WMPersonEditorViewController *)viewController didEditPerson:(WMPerson *)person
{
    [self.navigationController popViewControllerAnimated:YES];
    WMParticipant *participant = self.participant;
    // update email
    WMTelecom *telecom = person.defaultEmailTelecom;
    if (telecom && !self.participant.email) {
        participant.email = telecom.value;
    }
    // update name
    if (![person.nameFamily isEqualToString:participant.lastName]) {
        participant.lastName = person.nameFamily;
    }
    if (![person.nameGiven isEqualToString:participant.firstName]) {
        participant.firstName = person.nameGiven;
    }
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    // update backend
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ffm updatePerson:person ff:ff completionHandler:^(NSError *error) {
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
    }];
}

- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - OrganizationEditorViewControllerDelegate

- (void)organizationEditorViewController:(WMOrganizationEditorViewController *)viewController didEditOrganization:(WMOrganization *)organization
{
    WMParticipant *participant = self.participant;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    NSParameterAssert([organization managedObjectContext] == managedObjectContext);
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
    };
    [self.navigationController popViewControllerAnimated:YES];
    if (nil == participant.organization) {
        participant.organization = organization;
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ff updateObj:participant onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            block();
        }];
    } else {
        block();
    }
}

- (void)organizationEditorViewControllerDidCancel:(WMOrganizationEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WMIAPJoinTeamViewControllerDelegate

- (void)iapJoinTeamViewControllerDidPurchase:(WMIAPJoinTeamViewController *)viewController
{
    _welcomeState = WMWelcomeStateInvitationAccepted;
    __weak __typeof(&*self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        // update table view
        [weakSelf.tableView reloadData];
    }];
}

- (void)iapJoinTeamViewControllerDidDecline:(WMIAPJoinTeamViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - CreateTeamViewControllerDelegate

- (void)createTeamViewController:(WMCreateTeamViewController *)viewController didCreateTeam:(WMTeam *)team
{
    [self.navigationController popViewControllerAnimated:NO];
    self.welcomeState = WMWelcomeStateTeamSelected;
    [self.tableView reloadData];
    // check if team leader wants to add current patients to team
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if ([WMPatient patientCount:managedObjectContext]) {
        WMParticipant *participant = self.participant;
        WMTeam *team = participant.team;
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        __block NSInteger counter = 0;
        __weak __typeof(&*self)weakSelf = self;
        NSArray *patients = [WMPatient MR_findAllInContext:managedObjectContext];
        counter = [patients count];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Adding patients to Team";
        [ffm movePatientsForParticipant:participant toTeam:team completionHandler:^(NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            }
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        }];
    }
}

- (void)createTeamViewControllerDidCancel:(WMCreateTeamViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - CreateConsultantViewControllerDelegate

- (void)createConsultantViewControllerDidFinish:(WMCreateConsultingGroupViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)createConsultantViewControllerDidCancel:(WMCreateConsultingGroupViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ChooseTrackDelegate

- (WMNavigationTrack *)selectedTrack
{
    return self.patient.stage.track;
}

- (NSPredicate *)navigationTrackPredicate
{
    return [NSPredicate predicateWithFormat:@"team == %@", self.participant.team];
}

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    self.appDelegate.navigationCoordinator.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    WMPatient *patient = viewController.patient;
    if (self.isIPadIdiom) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    self.appDelegate.navigationCoordinator.patient = patient;
    _enterWoundMapButton.enabled = self.setupConfigurationComplete;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
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
