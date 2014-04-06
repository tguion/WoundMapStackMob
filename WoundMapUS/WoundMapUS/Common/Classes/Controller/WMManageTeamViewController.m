//
//  WMManageTeamViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/6/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMManageTeamViewController.h"
#import "WMCreateTeamInvitationViewController.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

typedef NS_ENUM(NSUInteger, WMCreateTeamActionSheetTag) {
    kRevokeInvitationActionSheetTag,
    kRemoveParticipantActionSheetTag,
};

@interface WMManageTeamViewController () <CreateTeamInvitationViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMParticipant *participant;
@property (readonly, nonatomic) WMTeam *team;
@property (strong, nonatomic) NSArray *teamInvitations;
@property (strong, nonatomic) NSArray *teamMembers;

@property (readonly, nonatomic) WMCreateTeamInvitationViewController *createTeamInvitationViewController;

@property (strong, nonatomic) WMTeamInvitation *teamInvitationToDelete;
@property (strong, nonatomic) WMParticipant *teamMemberToDelete;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    [self.tableView setEditing:YES];
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

- (void)initiateRemoveTeamMember
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Remove %@ from Team", _teamMemberToDelete.name]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Revoke"
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

#pragma mark - Navigation

- (void)navigateToCreateInvitationViewController
{
    [self.navigationController pushViewController:self.createTeamInvitationViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        WM_ASSERT_MAIN_THREAD;
        [weakSelf.delegate manageTeamViewControllerDidFinish:weakSelf];
    }];
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
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.tableView reloadData];
        });
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
    switch (actionSheet.tag) {
        case kRevokeInvitationActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_teamInvitations indexOfObject:_teamInvitationToDelete] inSection:1];
                [self.managedObjectContext deleteObject:_teamInvitationToDelete];
                _teamInvitations = nil;
                _teamInvitationToDelete = nil;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
                // update back end
                
            }
            break;
        }
        case kRemoveParticipantActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_teamMembers indexOfObject:_teamMemberToDelete] inSection:2];
                [self.managedObjectContext deleteObject:_teamMemberToDelete];
                _teamMembers = nil;
                _teamMemberToDelete = nil;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
                // update back end
                
            }
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

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
            tableViewCellEditingStyle = UITableViewCellEditingStyleDelete;
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
    [self.view endEditing:YES];
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
                // revoke invitation
                _teamInvitationToDelete = [self.teamInvitations objectAtIndex:indexPath.row];
                [self initiateRevokeInvitation];
            }
            break;
        }
        case 2: {
            // participants - remove from team
            _teamMemberToDelete = [self.teamMembers objectAtIndex:indexPath.row];
            [self initiateRemoveTeamMember];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 2;
    if ([self.teamMembers count]) {
        ++count;
    }
    return count;
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
                cell.textLabel.text = teamInvitation.invitee.name;
                NSString *message = nil;
                if (teamInvitation.isAccepted) {
                    message = @"Accepted - tap to confirm";
                } else {
                    message = [NSDateFormatter localizedStringFromDate:teamInvitation.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
                }
                cell.detailTextLabel.text = message;
            }
            break;
        }
        case 2: {
            // team members
            WMParticipant *teamMember = [self.teamMembers objectAtIndex:indexPath.row];
            cell.textLabel.text = teamMember.name;
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
                [self initiateRevokeInvitation];
            }
            break;
        }
        case 2: {
            // remove participant - use UIActionSheet
            [self initiateRemoveTeamMember];
            break;
        }
    }
}

@end
