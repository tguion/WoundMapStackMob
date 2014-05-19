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
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "IAPManager.h"
#import "WMUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

typedef NS_ENUM(NSUInteger, WMCreateTeamActionSheetTag) {
    kRevokeInvitationActionSheetTag,
    kConfirmInvitationActionSheetTag,
    kRemoveParticipantActionSheetTag,
    kSignOutActionSheetTag
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/%@/invitations", [WMTeam entityName], [self.team.ffUrl lastPathComponent]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        _acquiringTeamInvitations = NO;
        _teamInvitations = object;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.tableView reloadData];
    }];
    _acquiringTeamMembers = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/%@/participants", [WMTeam entityName], [self.team.ffUrl lastPathComponent]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
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
    return indexPath.section == 1 && indexPath.row == [self.team.invitations count];
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
                                                         successBlock:^{
                                                             WMParticipant *participant = _teamMemberToUpdateSubscription;
                                                             participant.dateTeamSubscriptionExpires = [WMUtilities dateByAddingMonthToDate:participant.dateTeamSubscriptionExpires];
                                                             WMTeam *team = participant.team;
                                                             NSManagedObjectContext *managedObjectContext = [team managedObjectContext];
                                                             // update from back end
                                                             WMFatFractal *ff = [WMFatFractal sharedInstance];
                                                             [ff getObjFromUri:team.ffUrl onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                                 team.iapTeamMemberSuccessCountValue = (team.iapTeamMemberSuccessCountValue + 1);
                                                                 [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                 [ff updateObj:team error:&error];
                                                                 if (error) {
                                                                     [WMUtilities logError:error];
                                                                 }
                                                             }];
                                                             [weakSelf.tableView reloadData];
                                                         } withObject:view];
}

- (void)initiateConfirmInvitation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Invitation: By tapping Confirm, the invitee will have access to team patient information."
                                                             delegate:self
                                                    cancelButtonTitle:@"Revoke Invitation"
                                               destructiveButtonTitle:@"Confirm"
                                                    otherButtonTitles:nil];
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

#pragma mark - CreateTeamInvitationViewControllerDelegate

- (void)createTeamInvitationViewController:(WMCreateTeamInvitationViewController *)viewController didCreateInvitation:(WMTeamInvitation *)teamInvitation
{
    [self.navigationController popViewControllerAnimated:YES];
    // add to back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    __weak __typeof(&*self)weakSelf = self;
    [ffm createTeamInvitation:teamInvitation ff:ff completionHandler:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        _teamInvitations = nil;
        [weakSelf.tableView reloadData];
    }];
}

- (void)createTeamInvitationViewControllerDidCancel:(WMCreateTeamInvitationViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSManagedObjectContext *managedObjetContext = self.managedObjectContext;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t revokeBlock = ^{
        [ffm revokeTeamInvitation:_teamInvitationToDeleteOrConfirm ff:ff completionHandler:^(NSError *error) {
            // update local
            [weakSelf.managedObjectContext deleteObject:_teamInvitationToDeleteOrConfirm];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
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
                [ffm addParticipantToTeamFromTeamInvitation:_teamInvitationToDeleteOrConfirm ff:ff completionHandler:^(NSError *error) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    [managedObjetContext MR_saveToPersistentStoreAndWait];
                    // update regardless of error
                    _teamInvitations = nil;
                    _teamMembers = nil;
                    [weakSelf.tableView reloadData];
                }];
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                // revoke
                revokeBlock();
            }
            break;
        }
        case kRemoveParticipantActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [ffm removeParticipant:_teamMemberToDelete fromTeam:_teamMemberToDelete.team ff:ff completionHandler:^(NSError *error) {
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
                [self.appDelegate signOut];
                __weak __typeof(self) weakSelf = self;
                [UIView transitionWithView:self.appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{
                                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:weakSelf.welcomeToWoundMapViewController];
                                    navigationController.delegate = weakSelf.appDelegate;
                                    self.appDelegate.window.rootViewController = navigationController;
                                } completion:^(BOOL finished) {
                                    // nothing
                                }];
            }
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
            // participants - remove from team
            WMParticipant *participant = [self.teamMembers objectAtIndex:indexPath.row];
            if (!participant.isTeamLeader) {
                shouldHighlight = YES;
            }
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
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_acquiringTeamInvitations || _acquiringTeamMembers) {
        return 0;
    }
    // else
    NSInteger count = 2;
    if ([self.teamMembers count]) {
        ++count;
    }
    return count;
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
            count = [self.team.invitations count] + 1;
            break;
        }
        case 2: {
            count = [self.teamMembers count];
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
