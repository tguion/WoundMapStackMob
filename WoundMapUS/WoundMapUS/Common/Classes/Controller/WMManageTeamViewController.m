//
//  WMManageTeamViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/6/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMManageTeamViewController.h"
#import "WMCreateTeamInvitationViewController.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "WMPaymentTransaction.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "IAPManager.h"
#import "WMPhotoManager.h"
#import "WMUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

#define REVOKE_INVITION_BUTTON_INDEX 1

typedef NS_ENUM(NSUInteger, WMCreateTeamActionSheetTag) {
    kRevokeInvitationActionSheetTag,
    kConfirmInvitationActionSheetTag,
    kRemoveParticipantActionSheetTag,
    kSignOutActionSheetTag,
    kPurchasePatientCreditsActionSheetTag
};

@interface WMManageTeamViewController () <CreateTeamInvitationViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMParticipant *participant;
@property (readonly, nonatomic) WMTeam *team;
@property (strong, nonatomic) NSArray *teamInvitations;
@property (strong, nonatomic) NSArray *teamMembers;
@property (nonatomic) BOOL acquiringTeamInvitations;
@property (nonatomic) BOOL acquiringTeamMembers;

@property (readonly, nonatomic) WMCreateTeamInvitationViewController *createTeamInvitationViewController;

@property (strong, nonatomic) WMTeamInvitation *teamInvitationToDeleteOrConfirm;
@property (strong, nonatomic) WMParticipant *teamMemberToDelete;
@property (strong, nonatomic) WMParticipant *teamMemberToUpdateSubscription;

@end

@implementation WMManageTeamViewController

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
    self.title = @"Manage Team";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOutAction:)];
    // update from back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    _acquiringTeamInvitations = YES;
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/%@/invitations", [WMTeam entityName], [self.team.ffUrl lastPathComponent]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if ([object isKindOfClass:[NSArray class]]) {
            // make sure we didn't loose the team reference
            NSArray *teamInvitations = (NSArray *)object;
            for (WMTeamInvitation *teamInvitation in teamInvitations) {
                teamInvitation.team = self.team;
                [ff updateObj:teamInvitation];
            }
        }
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        _acquiringTeamInvitations = NO;
        _teamInvitations = object;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.tableView reloadData];
    }];
    _acquiringTeamMembers = YES;
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/%@/participants", [WMTeam entityName], [self.team.ffUrl lastPathComponent]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        _acquiringTeamMembers = NO;
        _teamMembers = object;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.tableView reloadData];
    }];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    [self.tableView setEditing:YES];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check if team members are close to needed re-up
    NSDate *now = [NSDate date];
    NSMutableArray *namesExpiring = [NSMutableArray array];
    for (WMParticipant *participant in self.teamMembers) {
        NSDate *fiveDaysAgo = [WMUtilities dateByAddingDays:-5 toDate:participant.dateTeamSubscriptionExpires];
        if ([now compare:fiveDaysAgo] == NSOrderedDescending) {
            [namesExpiring addObject:participant.firstName];
        }
    }
    if ([namesExpiring count]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Members Expiring"
                                                            message:[NSString stringWithFormat:@"The following team member's membership may needed to be extended: %@", [namesExpiring componentsJoinedByString:@","]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    // check patient count
    WMTeam *team = self.team;
    int purchasedPatientCount = team.purchasedPatientCountValue;
    if (purchasedPatientCount < 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Low Patient Encounter Credits"
                                                            message:@"Your team's Patient Encounter Credits is getting low. Consider purchasing more credits by tapping on 'Patient Encounter Credits'."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
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

- (WMTeam *)team
{
    return self.participant.team;
}

- (NSArray *)teamInvitations
{
    if (nil == _teamInvitations) {
        _teamInvitations = [WMTeamInvitation MR_findAllSortedBy:WMTeamInvitationAttributes.createdAt
                                                      ascending:YES
                                                  withPredicate:[NSPredicate predicateWithFormat:@"team == %@", self.team]
                                                      inContext:self.managedObjectContext];
    }
    return _teamInvitations;
}

- (NSArray *)teamMembers
{
    if (nil == _teamMembers) {
        _teamMembers = [WMParticipant MR_findAllSortedBy:WMParticipantAttributes.name
                                               ascending:YES
                                           withPredicate:[NSPredicate predicateWithFormat:@"team == %@", self.team]
                                               inContext:self.managedObjectContext];
    }
    return _teamMembers;
}

- (BOOL)indexPathIsAddInvitation:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 && indexPath.row == [self.teamInvitations count];
}

- (void)initiateRevokeInvitation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Revoke Invitation"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Revoke"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kRevokeInvitationActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)initiateUpdateSubscriptionTeamMember:(UIView *)view
{
    __weak __typeof(&*self)weakSelf = self;
    [self presentIAPViewControllerForProductIdentifier:kTeamMemberProductIdentifier
                                                         successBlock:^(SKPaymentTransaction *transaction) {
                                                             WMParticipant *participant = _teamMemberToUpdateSubscription;
                                                             participant.dateTeamSubscriptionExpires = [WMUtilities dateByAddingMonthToDate:participant.dateTeamSubscriptionExpires];
                                                             WMTeam *team = participant.team;
                                                             NSManagedObjectContext *managedObjectContext = [team managedObjectContext];
                                                             // mark WMPaymentTransaction as applied
                                                             WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                                                                                    originalTransaction:nil
                                                                                                                                                               username:participant.userName
                                                                                                                                                                 create:NO
                                                                                                                                                   managedObjectContext:managedObjectContext];
                                                             paymentTransaction.appliedFlagValue = YES;
                                                             [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                             // update from back end
                                                             WMFatFractal *ff = [WMFatFractal sharedInstance];
                                                             NSString *uri = [team.ffUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
                                                             [ff getObjFromUri:uri onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                                 team.iapTeamMemberSuccessCountValue = (team.iapTeamMemberSuccessCountValue + 1);
                                                                 [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                 [ff updateObj:team error:&error];
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                                 [ff updateObj:participant error:&error];
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                                 [ff updateObj:paymentTransaction error:&error];
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                             }];
                                                             [weakSelf.tableView reloadData];
                                                         } proceedAlways:YES withObject:view];
}

- (void)initiateConfirmInvitation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Invitation: By tapping Confirm, the invitee will have access to team patient information."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Confirm"
                                                    otherButtonTitles:@"Revoke Invitation", nil];
    actionSheet.tag = kConfirmInvitationActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)initiateRemoveTeamMember
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Remove %@ from Team", _teamMemberToDelete.name]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Remove"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kRemoveParticipantActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)initiatePurchasePatientCredits
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You have selected the option to purchase addition patient credits."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Continue"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kPurchasePatientCreditsActionSheetTag;
    [actionSheet showInView:self.view];
}

- (WMCreateTeamInvitationViewController *)createTeamInvitationViewController
{
    WMCreateTeamInvitationViewController *createTeamInvitationViewController = [[WMCreateTeamInvitationViewController alloc] initWithNibName:@"WMCreateTeamInvitationViewController" bundle:nil];
    createTeamInvitationViewController.delegate = self;
    return createTeamInvitationViewController;
}

- (WMWelcomeToWoundMapViewController *)welcomeToWoundMapViewController
{
    return [[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil];
}

#pragma mark - Navigation

- (void)navigateToCreateInvitationViewController
{
    [self.navigationController pushViewController:self.createTeamInvitationViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)signOutAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Sign Out %@", self.appDelegate.participant.userName]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Sign Out"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kSignOutActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _teamInvitations = nil;
    _teamMembers = nil;
}

- (void)handleTeamInvitationUpdated:(NSString *)teamInvitationGUID
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf.tableView reloadData];
    };
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=2&depthGb=2", [WMTeam entityName]] onComplete:onComplete];
}

#pragma mark - CreateTeamInvitationViewControllerDelegate

- (void)createTeamInvitationViewController:(WMCreateTeamInvitationViewController *)viewController didCreateInvitation:(WMTeamInvitation *)teamInvitation
{
    _teamInvitations = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

- (void)createTeamInvitationViewControllerDidCancel:(WMCreateTeamInvitationViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t revokeBlock = ^{
        [ffm revokeTeamInvitation:_teamInvitationToDeleteOrConfirm ff:ff completionHandler:^(NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            }
            // update local
            [managedObjectContext MR_deleteObjects:@[_teamInvitationToDeleteOrConfirm]];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            _teamInvitationToDeleteOrConfirm = nil;
            _teamInvitations = nil;
            [weakSelf.tableView reloadData];
        }];
    };
    switch (actionSheet.tag) {
        case kRevokeInvitationActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                // revoke
                revokeBlock();
            }
            break;
        }
        case kConfirmInvitationActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                // add to team
                dispatch_block_t block = ^{
                    [ffm addParticipantToTeamFromTeamInvitation:_teamInvitationToDeleteOrConfirm team:weakSelf.team ff:ff completionHandler:^(NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        }
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                        // update regardless of error
                        _teamInvitations = nil;
                        _teamMembers = nil;
                        [weakSelf.tableView reloadData];
                    }];
                };
                if (kPresentIAPController) {
                    [self presentIAPViewControllerForProductIdentifier:kTeamMemberProductIdentifier
                                                          successBlock:^(SKPaymentTransaction *transaction) {
                                                              // mark WMPaymentTransaction as applied
                                                              WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                                                                                     originalTransaction:nil
                                                                                                                                                                username:self.participant.userName
                                                                                                                                                                  create:NO
                                                                                                                                                    managedObjectContext:managedObjectContext];
                                                              paymentTransaction.appliedFlagValue = YES;
                                                              [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                              FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                                  if (error) {
                                                                      [WMUtilities logError:error];
                                                                  }
                                                                  block();
                                                              };
                                                              [ff updateObj:paymentTransaction
                                                                 onComplete:onComplete onOffline:onComplete];
                                                          } proceedAlways:YES
                                                            withObject:self.view];
                } else {
                    block();
                }
            } else if (buttonIndex == REVOKE_INVITION_BUTTON_INDEX) {
                // revoke
                revokeBlock();
            }
            break;
        }
        case kRemoveParticipantActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [MBProgressHUD showHUDAddedToViewController:self animated:YES];
                [ffm removeParticipant:_teamMemberToDelete fromTeam:self.team ff:ff completionHandler:^(NSError *error) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    _teamMembers = nil;
                    _teamMemberToDelete = nil;
                    [weakSelf.tableView reloadData];
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
                }];
            }
            break;
        }
        case kSignOutActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                dispatch_block_t block = ^{
                    [weakSelf.appDelegate signOut];
                    UINavigationController *navigationController = weakSelf.appDelegate.initialViewController;
                    [UIView transitionWithView:weakSelf.appDelegate.window
                                      duration:0.5
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    animations:^{
                                        weakSelf.appDelegate.window.rootViewController = navigationController;
                                    } completion:^(BOOL finished) {
                                        // nothing
                                    }];
                };
                // wait for photos to complete upload
                WMPhotoManager *photoManager = [WMPhotoManager sharedInstance];
                if (!photoManager.hasCompletedPhotoUploads) {
                    UIView *view = self.view;
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
                    hud.labelText = @"Photo uploading";
                    hud.detailsLabelText = @"Please wait...";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        while (!photoManager.hasCompletedPhotoUploads) {
                            // wait until the blobs have uploaded
                            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideAllHUDsForView:view animated:NO];
                            block();
                        });
                    });
                } else {
                    block();
                }
            }
            break;
        }
        case kPurchasePatientCreditsActionSheetTag: {
            NSString *productIdentifier = @"patient credit aggregator";
            __weak __typeof(&*self)weakSelf = self;
            [self presentIAPViewControllerForProductIdentifier:productIdentifier
                                                  successBlock:^(SKPaymentTransaction *transaction) {
                                                      // mark WMPaymentTransaction as applied
                                                      WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                                                                             originalTransaction:nil
                                                                                                                                                        username:self.participant.userName
                                                                                                                                                          create:NO
                                                                                                                                            managedObjectContext:managedObjectContext];
                                                      paymentTransaction.appliedFlagValue = YES;
                                                      [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                      FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                          if (error) {
                                                              [WMUtilities logError:error];
                                                          }
                                                          [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
                                                      };
                                                      [ff updateObj:paymentTransaction
                                                         onComplete:onComplete onOffline:onComplete];
                                                  } proceedAlways:YES
                                                    withObject:self.view];
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlight = NO;
    switch (indexPath.section) {
        case 0: {
            // team name - nothing
            shouldHighlight = NO;
            break;
        }
        case 1: {
            // invitations
            shouldHighlight = YES;
            break;
        }
        case 2: {
            // participants - update subscription
            shouldHighlight = YES;
            break;
        }
        case 3: {
            // patient credits
            shouldHighlight = YES;
            break;
        }
    }
    return shouldHighlight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle tableViewCellEditingStyle = UITableViewCellEditingStyleNone;
    switch (indexPath.section) {
        case 1: {
            if ([self indexPathIsAddInvitation:indexPath]) {
                tableViewCellEditingStyle = UITableViewCellEditingStyleInsert;
            } else {
                tableViewCellEditingStyle = UITableViewCellEditingStyleDelete;
            }
            break;
        }
        case 2: {
            WMParticipant *teamMember = [self.teamMembers objectAtIndex:indexPath.row];
            if (teamMember.isTeamLeader) {
                tableViewCellEditingStyle = UITableViewCellEditingStyleNone;
            } else {
                tableViewCellEditingStyle = UITableViewCellEditingStyleDelete;
            }
            break;
        }
    }
    return tableViewCellEditingStyle;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            // team name - nothing
            break;
        }
        case 1: {
            // invitations
            if ([self indexPathIsAddInvitation:indexPath]) {
                // create a new invitation
                [self navigateToCreateInvitationViewController];
            } else {
                _teamInvitationToDeleteOrConfirm = [self.teamInvitations objectAtIndex:indexPath.row];
                if (nil == _teamInvitationToDeleteOrConfirm.team) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unknown Error"
                                                                        message:@"An unknown error occurred. Please try again after signing out and signing back in again."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                // else
                if (_teamInvitationToDeleteOrConfirm.isAccepted) {
                    [self initiateConfirmInvitation];
                } else {
                    [self initiateRevokeInvitation];
                }
            }
            break;
        }
        case 2: {
            // participants - update
            _teamMemberToUpdateSubscription = [self.teamMembers objectAtIndex:indexPath.row];
            [self initiateUpdateSubscriptionTeamMember:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case 3: {
            // patient credits
            [self initiatePurchasePatientCredits];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_acquiringTeamInvitations || _acquiringTeamMembers) {
        return 0;
    }
    // else
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            // nothing
            break;
        case 1:
            // invitations
            title = @"Team Invitations";
            break;
        case 2:
            // participants
            title = @"Team Members";
            break;
        case 3:
            // patient credits
            title = @"Patient Credits";
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = 1;
            break;
        }
        case 1: {
            count = [self.teamInvitations count] + 1;
            break;
        }
        case 2: {
            count = [self.teamMembers count];
            break;
        }
        case 3: {
            count = 1;
            break;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ValueCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // team name
            cell.textLabel.text = @"Team Name";
            cell.detailTextLabel.text = self.team.name;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1: {
            // invitations
            if ([self indexPathIsAddInvitation:indexPath]) {
                cell.textLabel.text = @"Invite a Participant";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                WMTeamInvitation *teamInvitation = [self.teamInvitations objectAtIndex:indexPath.row];
                NSString *inviteeName = teamInvitation.invitee.name;
                if (nil == inviteeName) {
                    inviteeName = teamInvitation.inviteeUserName;
                }
                cell.textLabel.text = inviteeName;
                NSString *message = nil;
                if (teamInvitation.isAccepted) {
                    message = @"Accepted, tap to confirm";
                } else {
                    message = [NSString stringWithFormat:@"invited %@", [NSDateFormatter localizedStringFromDate:teamInvitation.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
                }
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
                cell.detailTextLabel.text = message;
            }
            break;
        }
        case 2: {
            // team members
            WMParticipant *teamMember = [self.teamMembers objectAtIndex:indexPath.row];
            cell.textLabel.text = teamMember.name;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Expires %@", [NSDateFormatter localizedStringFromDate:teamMember.dateTeamSubscriptionExpires dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
            NSDate *fiveDaysAgo = [WMUtilities dateByAddingDays:-5 toDate:teamMember.dateTeamSubscriptionExpires];
            if ([[NSDate date] compare:fiveDaysAgo] == NSOrderedDescending) {
                NSString *imageName = @"alert_yellow_iPhone";
                if ([teamMember.dateTeamSubscriptionExpires compare:[NSDate date]] == NSOrderedDescending) {
                    imageName = @"alert_red_iPhone";
                }
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            } else {
                cell.accessoryView = nil;
            }
            break;
        }
        case 3: {
            // patient credits
            WMTeam *team = self.team;
            cell.textLabel.text = @"Patient Encounter Credits";
            cell.detailTextLabel.text = [team.purchasedPatientCount stringValue];
            int purchasedPatientCount = team.purchasedPatientCountValue;
            if (purchasedPatientCount < 3) {
                // warn
                UIImage *image = [UIImage imageNamed:@"alert_yellow_iPhone"];
                cell.accessoryView = [[UIImageView alloc] initWithImage:image];
            }
            break;
        }
    }
    
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1: {
            // invitations
            if ([self indexPathIsAddInvitation:indexPath]) {
                [self navigateToCreateInvitationViewController];
            } else {
                // delete invitation - use UIActionSheet
                _teamInvitationToDeleteOrConfirm = [_teamInvitations objectAtIndex:indexPath.row];
                [self initiateRevokeInvitation];
            }
            break;
        }
        case 2: {
            // remove participant - use UIActionSheet
            _teamMemberToDelete = [_teamMembers objectAtIndex:indexPath.row];
            [self initiateRemoveTeamMember];
            break;
        }
    }
}

@end
