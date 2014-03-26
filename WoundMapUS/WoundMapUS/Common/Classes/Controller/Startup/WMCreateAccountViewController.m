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
#import "WMTelecom.h"
#import "MBProgressHUD.h"
#import "KeychainItemWrapper.h"
#import "WMFatFractalManager.h"
#import "WMSeedDatabaseManager.h"   // DEBUG
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

#define kMinimumUserNameLength 3

typedef NS_ENUM(NSInteger, WMCreateAccountState) {
    CreateAccountInitial,           // username, password, password confirm
    CreateAccountAccountCreated,    // account created, value | Contact Details, Role, Organization
};

@interface WMCreateAccountViewController () <UITextFieldDelegate, SimpleTableViewControllerDelegate, PersonEditorViewControllerDelegate>

@property (nonatomic) WMCreateAccountState state;
@property (strong, nonatomic) FFUser *ffUser;
@property (strong, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMPerson *person;
@property (strong, nonatomic) WMParticipantType *selectedParticipantType;
@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;
@property (strong, nonatomic) NSString *passwordConfirmTextInput;
@property (strong, nonatomic) NSString *firstNameTextInput;
@property (strong, nonatomic) NSString *lastNameTextInput;
@property (strong, nonatomic) NSString *emailTextInput;
@property (strong, nonatomic) IBOutlet UIView *signInButtonContainerView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@property (readonly, nonatomic) BOOL hasSufficientCreateAccountInput;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
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
        _participant = [WMParticipant MR_createInContext:self.managedObjectContext];
        _participant.userName = _userNameTextInput;
    }
    return _participant;
}

- (WMPerson *)person
{
    if (nil == _person) {
        _person = [WMPerson MR_createInContext:self.managedObjectContext];
    }
    return _person;
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
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 2: {
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

// TODO validate userName, password, email
- (BOOL)hasSufficientCreateAccountInput
{
    return ([_userNameTextInput length] > 3 && [_passwordTextInput length] > 3 && [_passwordTextInput isEqualToString:_passwordConfirmTextInput] && [_firstNameTextInput length] > 0 && [_lastNameTextInput length] > 0 && [_emailTextInput length] > 3);
}

- (void)updateSignInButton
{
    _signInButton.enabled = self.hasSufficientCreateAccountInput;
}

// TODO impose validation on userName and password
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
    if (![_passwordTextInput isEqualToString:_passwordConfirmTextInput]) {
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

- (BOOL)checkForValidEmail
{
    if (![WMUtilities NSStringIsValidEmail:_emailTextInput]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid email"
                                                            message:@"Your email does not appear to be valid."
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
    if ([_emailTextInput length] == 0 || ![WMUtilities NSStringIsValidEmail:_emailTextInput]) {
        [messages addObject:@"Please enter a valid email address"];
    }
    if ([_firstNameTextInput length] == 0) {
        [messages addObject:@"Please complete your first name"];
    }
    if ([_lastNameTextInput length] == 0) {
        [messages addObject:@"Please complete your last name"];
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

-(void)saveUserCredentialsInKeychain
{
    KeychainItemWrapper *keychainItem = [WCAppDelegate keychainItem];
    [keychainItem setObject:_userNameTextInput forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:_passwordTextInput forKey:(__bridge id)(kSecValueData)];
    NSLog(@"Successfully saved user %@ to keychain after signup in SignupViewController.", [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]);
    
}

- (void)updateNavigationState
{
    self.navigationItem.rightBarButtonItem.enabled = self.hasSufficientCreateAccountInput;
}

#pragma mark - Actions

- (IBAction)createAccountAction:(id)sender
{
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(delayedCreateAccountAction) withObject:nil afterDelay:0.0];
}

- (IBAction)delayedCreateAccountAction
{
    if (![self checkForMatchingPasswords]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    if (![self checkForValidUserName]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    if (![self checkForValidEmail]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    self.participant.userName = _userNameTextInput;
    self.participant.email = _emailTextInput;
    // else first save to object permenant objectID
    [[self.participant managedObjectContext] MR_saveOnlySelfAndWait];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    _ffUser = [[FFUser alloc] initWithFF:ff];
    _ffUser.userName = _userNameTextInput;
    _ffUser.email = _emailTextInput;
    _ffUser.firstName = _firstNameTextInput;
    _ffUser.lastName = _lastNameTextInput;
    __weak __typeof(&*self)weakSelf = self;
    [ff registerUser:_ffUser password:_passwordTextInput onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        // NOTE: this returns on main thread
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        FFUser *ffUser = (FFUser *)object;
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to create account"
                                                                message:[NSString stringWithFormat:@"Unable to create an account: %@", error.localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            weakSelf.state = CreateAccountAccountCreated;
            [weakSelf.tableView reloadData];
            [weakSelf saveUserCredentialsInKeychain];
            // update participant
            weakSelf.participant.guid = ffUser.guid;
            // DEPLOYMENT - this should not be needed in production - seeding should be done on the back end anyway
            MBProgressHUD *progressView = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            progressView.labelText = @"Seeding databases";
            WMSeedDatabaseManager *seedDatabaseManager = [WMSeedDatabaseManager sharedInstance];
            [seedDatabaseManager seedDatabaseWithCompletionHandler:^(NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                }
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }];

        }
    }];
}

- (IBAction)cancelAction:(id)sender
{
    if (_participant) {
        [[_participant managedObjectContext] rollback];
    }
    [self.delegate createAccountViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    // make sure all necessary data has been entered
    if ([self dataInputIsComplete]) {
        NSParameterAssert(_person);
        self.participant.person = _person;
        __weak __typeof(&*self)weakSelf = self;
        [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            // participant has logged in as new user - now push data to backend
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            [ffm updateParticipant:weakSelf.participant ff:ff completionHandler:^(NSError *error) {
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
    switch (textField.tag) {
        case 1000: {
            // user name
            
            break;
        }
        case 1001: {
            // password
            self.passwordConfirmTextInput = nil;
            NSIndexPath *indexPathPasswordConfirm = [NSIndexPath indexPathForRow:2 inSection:0];
            WMTextFieldTableViewCell *cell = (WMTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathPasswordConfirm];
            cell.textField.text = nil;
            break;
        }
        case 1002: {
            // password confirm
            
            break;
        }
    }
}

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
                weakSelf.passwordTextInput = textField.text;
                break;
            }
            case 1002: {
                weakSelf.passwordConfirmTextInput = textField.text;
                break;
            }
            case 2000: {
                // first name
                weakSelf.firstNameTextInput = textField.text;
                break;
            }
            case 2001: {
                // last name
                weakSelf.lastNameTextInput = textField.text;
                break;
            }
            case 2002: {
                // email
                weakSelf.emailTextInput = textField.text;
                break;
            }
        }
        [weakSelf updateSignInButton];
    } afterDelay:0.1];
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000: {
            // userName
            _userNameTextInput = textField.text;
            break;
        }
        case 1001: {
            // password
            _passwordTextInput = textField.text;
            break;
        }
        case 1002: {
            // password
            _passwordConfirmTextInput = textField.text;
            [self checkForMatchingPasswords];
            break;
        }
        case 2000: {
            // first name
            _firstNameTextInput = textField.text;
            break;
        }
        case 2001: {
            // last name
            _lastNameTextInput = textField.text;
            break;
        }
        case 2002: {
            // email
            _emailTextInput = textField.text;
            break;
        }
    }
    [self updateNavigationState];
}

#pragma mark - SimpleTableViewControllerDelegate

- (NSString *)navigationTitle
{
    return @"Select Role";
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
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    // update email
    WMTelecom *telecom = person.defaultEmailTelecom;
    if (telecom && !self.participant.email) {
        self.participant.email = telecom.value;
    }
}

- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section > 1);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.state == CreateAccountInitial && section == 1) {
        return _signInButtonContainerView;
    }
    // else
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return  44.0;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 || indexPath.section == 1) {
        return;
    }
    // else
    switch (indexPath.row) {
        case 0: {
            // contact details
            WMPersonEditorViewController *personEditorViewController = self.personEditorViewController;
            personEditorViewController.person = self.person;
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
    return (self.state == CreateAccountInitial ? 2:3);
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
        case 2: {
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
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (self.state == CreateAccountInitial) {
                WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                UITextField *textField = nil;
                textField = myCell.textField;
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.autocorrectionType = UITextAutocorrectionTypeNo;
                textField.spellCheckingType = UITextSpellCheckingTypeNo;
                textField.returnKeyType = UIReturnKeyDefault;
                textField.delegate = self;
            }
            switch (indexPath.row) {
                case 0: {
                    // user name
                    if (self.state == CreateAccountInitial) {
                        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                        myCell.textField.tag = 1000;
                        [myCell updateWithLabelText:@"User name" valueText:_userNameTextInput valuePrompt:@"Unique username"];
                    } else {
                        cell.textLabel.text = @"User Name";
                        cell.detailTextLabel.text = _userNameTextInput;
                    }
                    break;
                }
                case 1: {
                    // password
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    myCell.textField.tag = 1001;
                    myCell.textField.secureTextEntry = YES;
                    [myCell updateWithLabelText:@"Password" valueText:_passwordTextInput valuePrompt:@"Enter password"];
                    break;
                }
                case 2: {
                    // password confirm
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    myCell.textField.tag = 1002;
                    myCell.textField.secureTextEntry = YES;
                    [myCell updateWithLabelText:@"Password Confirm" valueText:_passwordConfirmTextInput valuePrompt:@""];
                    break;
                }
            }
            break;
        }
        case 1: {
            cell.accessoryType = UITableViewCellAccessoryNone;
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = nil;
            textField = myCell.textField;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.delegate = self;
            switch (indexPath.row) {
                case 0: {
                    // first name
                    myCell.textField.tag = 2000;
                    myCell.textField.secureTextEntry = NO;
                    myCell.textField.autocorrectionType = UITextAutocapitalizationTypeWords;
                    [myCell updateWithLabelText:@"First Name" valueText:_firstNameTextInput valuePrompt:@""];
                    break;
                }
                case 1: {
                    // last name
                    myCell.textField.tag = 2001;
                    myCell.textField.autocorrectionType = UITextAutocapitalizationTypeWords;
                    myCell.textField.secureTextEntry = NO;
                    [myCell updateWithLabelText:@"Last Name" valueText:_passwordTextInput valuePrompt:@""];
                    break;
                }
                case 2: {
                    // email
                    myCell.textField.tag = 2002;
                    myCell.textField.secureTextEntry = NO;
                    [myCell updateWithLabelText:@"Email" valueText:_passwordConfirmTextInput valuePrompt:@"you@host.com"];
                    break;
                }
            }
            break;
        }
        case 2: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
