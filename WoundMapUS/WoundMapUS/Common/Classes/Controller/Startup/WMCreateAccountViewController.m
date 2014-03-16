//
//  WMCreateAccountViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCreateAccountViewController.h"
#import "WMSimpleTableViewController.h"
#import "WMPersonEditorViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "WMParticipant.h"
#import "WMParticipantType.h"
#import "WMPerson.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

#define kMinimumUserNameLength 3

typedef NS_ENUM(NSInteger, WMCreateAccountState) {
    CreateAccountInitial,           // username, password, password confirm
    CreateAccountAccountCreated,    // account created, value | Contact Details, Role, Organization
};

@interface WMCreateAccountViewController () <UITextFieldDelegate, SimpleTableViewControllerDelegate, PersonEditorViewControllerDelegate>

@property (nonatomic) WMCreateAccountState state;
@property (strong, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMParticipantType *selectedParticipantType;
@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;
@property (strong, nonatomic) NSString *passwordConfirmTextInput;
@property (strong, nonatomic) IBOutlet UIView *signInButtonContainerView;

@property (readonly, nonatomic) WMSimpleTableViewController *simpleTableViewController;
@property (readonly, nonatomic) WMPersonEditorViewController *personEditorViewController;

@end

@implementation WMCreateAccountViewController

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
    self.title = @"Create Account";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMSimpleTableViewController *)simpleTableViewController
{
    WMSimpleTableViewController *simpleTableViewController = [[WMSimpleTableViewController alloc] initWithNibName:@"WMSimpleTableViewController" bundle:nil];
    simpleTableViewController.delegate = self;
    simpleTableViewController.allowMultipleSelection = NO;
    return simpleTableViewController;
}

- (WMPersonEditorViewController *)personEditorViewController
{
    WMPersonEditorViewController *personEditorViewController = [[WMPersonEditorViewController alloc] initWithNibName:@"WMPersonEditorViewController" bundle:nil];
    personEditorViewController.delegate = self;
    return personEditorViewController;
}

- (WMParticipant *)participant
{
    if (nil == _participant) {
        NSParameterAssert([self checkForValidUserName]);
        NSParameterAssert([self checkForMatchingPasswords]);
        _participant = [WMParticipant MR_createInContext:self.managedObjectContext];
    }
    return _participant;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            cellReuseIdentifier = (self.state == CreateAccountInitial ? @"TextCell":@"ValueCell") ;
            break;
        }
        case 1: {
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)checkForValidUserName
{
    if ([self.userNameTextInput length] < kMinimumUserNameLength) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                            message:@"Your username must be a least three characters."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    return YES;
}

- (BOOL)checkForMatchingPasswords
{
    if (![self.passwordTextInput isEqualToString:self.passwordConfirmTextInput]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mismatch Passwords"
                                                            message:@"Password and Confirm Password do not match."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    return YES;
}

- (BOOL)dataInputIsComplete
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([self.participant.email length] == 0) {
        [messages addObject:@"Please enter an email address in Contact Details"];
    }
    if ([self.participant.name length] == 0) {
        [messages addObject:@"Please complete your name in Contact Details"];
    }
    if ([messages count]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:[messages componentsJoinedByString:@"\r"]
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

- (IBAction)createAccountAction:(id)sender
{
    [self.view endEditing:YES];
    [self performSelector:@selector(delayedCreateAccountAction) withObject:nil afterDelay:0.0];
}

- (IBAction)delayedCreateAccountAction
{
    if (![self checkForMatchingPasswords]) {
        return;
    }
    if (![self checkForValidUserName]) {
        return;
    }
    // else
    [self showProgressViewWithMessage:@"Creating account..."];
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm registerParticipant:self.participant password:self.passwordTextInput completionHandler:^(NSError *error) {
        WM_ASSERT_MAIN_THREAD;
        [weakSelf hideProgressView];
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to create account"
                                                                message:[NSString stringWithFormat:@"Unable to create an account: %@", error.localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            weakSelf.state = CreateAccountAccountCreated;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (IBAction)cancelAction:(id)sender
{
    if (_participant) {
        [_participant MR_deleteEntity];
    }
    [self.delegate createAccountViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    // make sure all necessary data has been entered
    if ([self dataInputIsComplete]) {
        __weak __typeof(&*self)weakSelf = self;
        [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            // participant has logged in as new user - now push data to backend
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            [ffm createParticipant:weakSelf.participant ff:ff completionHandler:^(NSError *error) {
                if (error) {
                    [ffm clearOperationCache];
                } else {
                    [ffm submitOperationsToQueue];
                    [weakSelf.delegate createAccountViewController:self didCreateParticipant:self.participant];
                }
            }];
        }];
    }
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _participant = nil;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *indexPathPassword = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathPasswordConfirm = [NSIndexPath indexPathForRow:2 inSection:0];
    if ([indexPath isEqual:indexPathPassword]) {
        self.passwordConfirmTextInput = nil;
        WMTextFieldTableViewCell *cell = (WMTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathPasswordConfirm];
        cell.textField.text = nil;
    }
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // userName
                    self.userNameTextInput = textField.text;
                    break;
                }
                case 1: {
                    // password
                    self.passwordTextInput = textField.text;
                    break;
                }
                case 2: {
                    // password
                    self.passwordConfirmTextInput = textField.text;
                    [self checkForMatchingPasswords];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - SimpleTableViewControllerDelegate

- (NSString *)navigationTitle
{
    return @"Sign In";
}

- (NSArray *)valuesForDisplay
{
    return [[WMParticipantType sortedParticipantTypes:self.managedObjectContext] valueForKeyPath:@"title"];
}

- (NSArray *)selectedValuesForDisplay
{
    if (nil == _selectedParticipantType) {
        return [NSArray array];
    }
    // else
    return [NSArray arrayWithObject:_selectedParticipantType.title];
}

- (void)simpleTableViewController:(WMSimpleTableViewController *)viewController didSelectValues:(NSArray *)selectedValues
{
    NSString *title = [selectedValues lastObject];
    if ([title length] > 0) {
        _selectedParticipantType = [WMParticipantType participantTypeForTitle:title
                                                                       create:NO
                                                         managedObjectContext:self.managedObjectContext];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - PersonEditorViewControllerDelegate

- (void)personEditorViewController:(WMPersonEditorViewController *)viewController didEditPerson:(WMPerson *)person
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController
{
    [self.managedObjectContext MR_deleteObjects:@[self.participant.person]];
    self.participant.person = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section > 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.state == CreateAccountInitial) {
        return _signInButtonContainerView;
    }
    // else
    return nil;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    // else
    switch (indexPath.row) {
        case 0: {
            // contact details
            WMPersonEditorViewController *personEditorViewController = self.personEditorViewController;
            personEditorViewController.person = self.participant.person;
            [self.navigationController pushViewController:personEditorViewController animated:YES];
            break;
        }
        case 1: {
            // role
            WMSimpleTableViewController *simpleTableViewController = self.simpleTableViewController;
            [self.navigationController pushViewController:simpleTableViewController animated:YES];
            simpleTableViewController.title = @"Select Role";
            break;
        }
        case 2: {
            // organization
            
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.state == CreateAccountInitial ? 1:2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = (self.state == CreateAccountInitial ? 3:1);
            break;
        }
        case 1: {
            count = 3;
            break;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        myCell.textField.delegate = self;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    if (self.state == CreateAccountInitial) {
                        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                        [myCell updateWithLabelText:@"User name" valueText:self.participant.userName valuePrompt:@"Unique username"];
                    } else {
                        cell.textLabel.text = @"User Name";
                        cell.detailTextLabel.text = self.userNameTextInput;
                    }
                    break;
                }
                case 1: {
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    myCell.textField.secureTextEntry = YES;
                    [myCell updateWithLabelText:@"Password" valueText:self.passwordTextInput valuePrompt:@"Enter a password"];
                    break;
                }
                case 2: {
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    myCell.textField.secureTextEntry = YES;
                    [myCell updateWithLabelText:@"Password Confirm" valueText:self.passwordConfirmTextInput valuePrompt:@"Confirm password"];
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"Contact Details";
                    cell.detailTextLabel.text = @"...";
                    break;
                }
                case 1: {
                    cell.textLabel.text = @"Clinical Role";
                    cell.detailTextLabel.text = @"...";
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Organization";
                    cell.detailTextLabel.text = @"...";
                    break;
                }
            }
            break;
        }
    }

}

@end
