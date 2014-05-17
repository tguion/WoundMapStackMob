//
//  WMCreateTeamInvitationViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/2/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCreateTeamInvitationViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "IAPManager.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "NSObject+performBlockAfterDelay.h"

#define kMinimumUserNameLength 3
#define kMinimumPasscodeLength 3

@interface WMCreateTeamInvitationViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) IBOutlet UIView *instructionsSectionHeaderContainerView;
@property (strong, nonatomic) IBOutlet UIView *passcodeSectionFooterContainerView;

@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passcodeTextInput;

@property (readonly, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMParticipant *invitee;

@end

@implementation WMCreateTeamInvitationViewController

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
    self.title = @"Create Invitation";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        _removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
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

- (void)presentIAPNonConsumableViewController
{
    [self presentIAPNonConsumableViewController];
}

- (BOOL)validateInput
{
    if (![self checkForValidUserName]) {
        return NO;
    }
    // else
    if (![self checkForValidPasscode]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)checkForValidUserName
{
    if ([_userNameTextInput length] < kMinimumUserNameLength) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                            message:@"The participant invitee username must be a least three characters."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    if ([_userNameTextInput isEqualToString:self.participant.userName]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                            message:@"You can't invite yourself. You are the team leader."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    if ([[self.participant.team.invitations valueForKeyPath:@"invitee.userName"] containsObject:_userNameTextInput]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                            message:@"An invitation for this participant has already been created."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    return YES;
}

- (BOOL)checkForValidPasscode
{
    if ([_passcodeTextInput length] < kMinimumPasscodeLength) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid passcode"
                                                            message:@"The passcode must be at least 4 numbers."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    return YES;
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new person
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate createTeamInvitationViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    if (![self validateInput]) {
        return;
    }
    [self.view endEditing:YES];
    // see if we can confirm user name
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [ff getObjFromUri:[NSString stringWithFormat:@"/%@/(userName eq '%@')", [WMParticipant entityName], _userNameTextInput] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        if (nil == object) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                                message:[NSString stringWithFormat:@"Unable to resolve a participant with user name %@", _userNameTextInput]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            _invitee = object;
            // present IAP
            if (NO) {
                [self presentIAPViewControllerForProductIdentifier:kTeamMemberProductIdentifier
                                                      successBlock:^{
                                                          [weakSelf completeTeamInvitation];
                                                      } proceedAlways:NO
                                                        withObject:sender];
            } else {
                [weakSelf completeTeamInvitation];
            }
        }
    }];
}

- (void)completeTeamInvitation
{
    _teamInvitation = [WMTeamInvitation MR_createInContext:self.managedObjectContext];
    _teamInvitation.team = self.participant.team;
    _teamInvitation.invitee = _invitee;
    _teamInvitation.inviteeUserName = _userNameTextInput;
    _teamInvitation.passcode = @([_passcodeTextInput integerValue]);
    _teamInvitation.invitationMessage = [NSString stringWithFormat:@"%@ of team %@ has invited you to join the team. Enter the 4 digit pincode provided to you by %@ and tap 'Accept'. Or you may decline the invitation.", self.participant.name, self.participant.team.name, self.participant.name];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    // handle undo
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate createTeamInvitationViewController:self didCreateInvitation:_teamInvitation];
}

#pragma mark - BaseViewController

- (void)clearAllReferences
{
    [super clearAllReferences];
    _teamInvitation = nil;
    _invitee = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak __typeof(&*self)weakSelf = self;
    [self performBlock:^{
        switch (textField.tag) {
            case 1000: {
                weakSelf.userNameTextInput = textField.text;
                break;
            }
            case 1001: {
                // TODO check number
                weakSelf.passcodeTextInput = textField.text;
                break;
            }
        }
    } afterDelay:0.1];
    return YES;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _instructionsSectionHeaderContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _passcodeSectionFooterContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
    UITextField *textField = myCell.textField;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.delegate = self;
    switch (indexPath.row) {
        case 0: {
            textField.tag = 1000;
            [myCell updateWithLabelText:@"User name" valueText:_userNameTextInput valuePrompt:@"Invitee user name"];
            break;
        }
        case 1: {
            textField.tag = 1001;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            [myCell updateWithLabelText:@"Passcode" valueText:_userNameTextInput valuePrompt:@"Numeric passcode"];
            break;
        }
    }
}

@end
