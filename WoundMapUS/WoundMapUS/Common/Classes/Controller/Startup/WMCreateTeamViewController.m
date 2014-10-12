//
//  WMCreateTeamViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/1/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCreateTeamViewController.h"
#import "WMCreateTeamInvitationViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMParticipant.h"
#import "WMTeamInvitation.h"
#import "WMTeam.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

typedef NS_ENUM(NSUInteger, WMCreateTeamActionSheetTag) {
    kRevokeInvitationActionSheetTag,
    kRemoveParticipantActionSheetTag,
};

@interface WMCreateTeamViewController () <UITextFieldDelegate, UIActionSheetDelegate, CreateTeamInvitationViewControllerDelegate>

@property (nonatomic) BOOL teamCreatedFlag;

@property (readonly, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) NSArray *teamInvitations;
@property (strong, nonatomic) NSArray *teamMembers;

@property (strong, nonatomic) NSString *teamNameTextInput;

@property (strong, nonatomic) WMTeamInvitation *teamInvitationToDelete;
@property (strong, nonatomic) WMParticipant *teamMemberToDelete;

@property (readonly, nonatomic) WMCreateTeamInvitationViewController *createTeamInvitationViewController;

- (IBAction)createInvitationAction:(id)sender;

@end

@implementation WMCreateTeamViewController

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
    self.title = @"Create Team";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createTeamAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    // allow editing
    [self.tableView setEditing:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            cellReuseIdentifier = @"TextCell";
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
    return cellReuseIdentifier;
}

- (BOOL)hasSufficientInput
{
    return ([_teamNameTextInput length] > 3);
}

- (void)updateNavigation
{
    if (self.hasSufficientInput) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

- (WMTeam *)team
{
    if (nil == _team) {
        _team = [WMTeam MR_createInContext:self.managedObjectContext];
    }
    return _team;
}

- (NSArray *)teamInvitations
{
    if (nil == _teamInvitations) {
        _teamInvitations = [WMTeamInvitation MR_findAllSortedBy:WMTeamInvitationAttributes.createdAt
                                                      ascending:YES
                                                  withPredicate:[NSPredicate predicateWithFormat:@"team == %@", self.team]
                                                      inContext:self.managedObjectContext];
        // make sure we have not lost team reference
        if (_team) {
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            NSError *localError = nil;
            for (WMTeamInvitation *teamInvitation in _teamInvitations) {
                if (nil == teamInvitation.team) {
                    teamInvitation.team = _team;
                    [ff updateObj:teamInvitation error:&localError];
                    if (localError) {
                        [WMUtilities logError:localError];
                    }
                }
            }
        }
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

- (void)createTeam:(WMErrorCallback)completionHandler
{
    if (self.team.ffUrl) {
        completionHandler(nil);
        return;
    }
    // else
    _teamCreatedFlag = YES;
    self.team.name = _teamNameTextInput;
    WMParticipant *participant = self.participant;
    participant.isTeamLeader = YES;
    participant.team = _team;
    participant.dateAddedToTeam = [NSDate date];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Building Team...";
    __weak __typeof(&*self)weakSelf = self;
    // hold onto stage/track for each patient
    NSArray *patients = [WMPatient MR_findAllInContext:managedObjectContext];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (WMPatient *patient in patients) {
        map[patient.ffUrl] = [NSString stringWithFormat:@"%@|%@", patient.stage.track.title, patient.stage.title];
    }
    self.appDelegate.patient2StageMap = map;
    // delete local tracks only if there are not patients that need to be moved to team
    if ([patients count] == 0) {
        NSArray *navigationTracks = [WMNavigationTrack MR_findAllInContext:managedObjectContext];
        [managedObjectContext MR_deleteObjects:navigationTracks];
    }
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    [ffm createTeamWithParticipant:participant user:(FFUser *)ff.loggedInUser ff:ff completionHandler:^(NSError *error) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        }
        completionHandler(error);
    }];
}

#pragma mark - Navigation

- (void)navigateToCreateInvitationViewController
{
    [self.navigationController pushViewController:self.createTeamInvitationViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.managedObjectContext rollback];
    [self.delegate createTeamViewControllerDidCancel:self];
}

- (IBAction)createTeamAction:(id)sender
{
    [self.view endEditing:YES];
    if ([_teamNameTextInput length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Input"
                                                            message:@"Please enter the name of your team first."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [self createTeam:^(NSError *error) {
        [weakSelf.delegate createTeamViewController:weakSelf didCreateTeam:weakSelf.team];
    }];
}

- (IBAction)createInvitationAction:(id)sender
{
    [self.view endEditing:YES];
    if ([_teamNameTextInput length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Input"
                                                            message:@"Please enter the name of your team first."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [self createTeam:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf navigateToCreateInvitationViewController];
    }];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _team = nil;
    _teamInvitations = nil;
    _teamMembers = nil;
}

- (void)handleTeamInvitationUpdated:(NSString *)teamInvitationGUID
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak __typeof(&*self)weakSelf = self;
    [self performBlock:^{
        switch (textField.tag) {
            case 1000: {
                weakSelf.teamNameTextInput = textField.text;
                break;
            }
        }
        [weakSelf updateNavigation];
    } afterDelay:0.1];
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000: {
            // userName
            self.teamNameTextInput = textField.text;
            break;
        }
    }
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return self.hasSufficientInput;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    switch (actionSheet.tag) {
        case kRevokeInvitationActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_teamInvitations indexOfObject:_teamInvitationToDelete] inSection:1];
                if (_teamInvitationToDelete.ffUrl) {
                    [ff deleteObj:_teamInvitationToDelete];
                }
                [self.managedObjectContext deleteObject:_teamInvitationToDelete];
                _teamInvitations = nil;
                _teamInvitationToDelete = nil;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        [myCell.textField becomeFirstResponder];
        return nil;
    }
    // else
    return indexPath;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if ([_teamNameTextInput length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Input"
                                                          message:@"Please enter the name of your team first."
                                                         delegate:nil
                                                cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil];
        [alertView show];
        return;
    }
    switch (indexPath.section) {
        case 0: {
            // team name - nothing
            break;
        }
        case 1: {
            // invitations
            if ([self indexPathIsAddInvitation:indexPath]) {
                // create a new invitation
                [self createInvitationAction:nil];
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
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // team name
            cell.accessoryType = UITableViewCellAccessoryNone;
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = myCell.textField;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextAutocorrectionTypeYes;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.delegate = self;
            textField.tag = 1000;
            [myCell updateWithLabelText:@"Team Name" valueText:self.team.name valuePrompt:@"Enter Team Name"];
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
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Invited %@", [NSDateFormatter localizedStringFromDate:teamInvitation.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
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
                [self createInvitationAction:nil];
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
