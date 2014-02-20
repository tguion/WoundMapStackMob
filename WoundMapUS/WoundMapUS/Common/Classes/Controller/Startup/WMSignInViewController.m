//
//  WMSignInViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSignInViewController.h"
#import "WMSimpleTableViewController.h"
#import "WMPersonEditorViewController.h"
#import "WMParticipant.h"
#import "WMParticipantType.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "UIView+Custom.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

typedef enum {
    SignInViewControllerEnterName           = 0,
    SignInViewControllerCreateNewAccount    = 1,
    SignInViewControllerEnterEmail          = 2,
    SignInViewControllerEnterRole           = 3,
    SignInViewControllerEnterContactDetail  = 4,
    SignInViewControllerCreateAccount       = 5,
} SignInViewControllerState;

typedef enum {
    SignInViewControllerActionCreateAccount         = 1000,
    SignInViewControllerActionResetCreateAccount    = 1001,
} SignInViewControllerActionTag;

@interface WMSignInViewController () <SimpleTableViewControllerDelegate, PersonEditorViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) SignInViewControllerState state;
@property (strong, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMParticipant *possibleParticipant;
@property (strong, nonatomic) WMParticipantType *selectedParticipantType;
@property (strong, nonatomic) WMPerson *person;
@property (strong, nonatomic) NSString *userNameForNewAccout;

@property (readonly, nonatomic) BOOL userNameMatchesUser;
@property (readonly, nonatomic) BOOL hasNameInput;
@property (readonly, nonatomic) NSString *nameInput;
@property (readonly, nonatomic) BOOL isEmailInputValid;

@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *assigneeTypeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactCell;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (nonatomic) CGFloat tableFooterViewHeight;

@property (readonly, nonatomic) WMSimpleTableViewController *simpleTableViewController;
@property (readonly, nonatomic) WMPersonEditorViewController *personEditorViewController;

- (IBAction)signInAction:(id)sender;
- (IBAction)createAccountAction:(id)sender;

@end

@interface WMSignInViewController (PrivateMethods)

- (void)updateUserFromInput;
- (void)updateState;
- (void)updateUI;

@end

@implementation WMSignInViewController (PrivateMethods)

- (void)updateUserFromInput
{
    if (self.state > SignInViewControllerCreateNewAccount && [[self.view findFirstResponder] isEqual:self.nameTextField]) {
        // in process of creating new account, but user is editing proposed user name
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Cancel creating account for %@", self.userNameForNewAccout]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Continue"
                                                   destructiveButtonTitle:@"Restart"
                                                        otherButtonTitles:nil];
        actionSheet.tag = SignInViewControllerActionResetCreateAccount;
        [actionSheet showInView:self.view];
    }
    if (self.hasNameInput) {
        id firstResponder = [self.view findFirstResponder];
        if ([firstResponder isEqual:self.nameTextField]) {
            NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
            NSLog(@"Searching for name matching %@ in %ld participants", self.nameInput, (long)[WMParticipant participantCount:managedObjectContext persistentStore:self.store]);
            NSFetchRequest *request = [WMParticipant bestMatchingParticipantFetchRequestForUserName:self.nameInput managedObjectContext:managedObjectContext];
            SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
            NSError *error = nil;
            NSArray *participants = [managedObjectContext executeFetchRequestAndWait:request
                                                              returnManagedObjectIDs:NO
                                                                             options:options
                                                                               error:&error];
            [WMUtilities logError:error];
            // if not found, go to network to find
            if (0 == [participants count]) {
                request = [WMParticipant matchingParticipantFetchRequestForUserName:self.nameInput managedObjectContext:managedObjectContext];
                options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyNetworkOnly];
                participants = [managedObjectContext executeFetchRequestAndWait:request
                                                         returnManagedObjectIDs:NO
                                                                        options:options
                                                                          error:&error];
            }
            self.possibleParticipant = [participants firstObject];
        }
    } else {
        self.possibleParticipant = nil;
    }
    [self updateState];
    [self updateUI];
}

- (void)updateState
{
}

- (void)updateUI
{
    switch (self.state) {
        case SignInViewControllerEnterName: {
            self.title = @"Sign In";
            if (self.hasNameInput) {
                if (nil == self.possibleParticipant) {
                    [self.signInButton setTitle:@"Create Account" forState:UIControlStateNormal];
                    CGRect aFrame = self.tableFooterView.frame;
                    aFrame.size.height = self.tableFooterViewHeight;
                    self.tableFooterView.frame = aFrame;
                } else {
                    [self.signInButton setTitle:[NSString stringWithFormat:@"Sign in as %@", self.possibleParticipant.name] forState:UIControlStateNormal];
                    CGRect aFrame = self.tableFooterView.frame;
                    aFrame.size.height = 2.0 * self.tableFooterViewHeight;
                    self.tableFooterView.frame = aFrame;
                }
                [self.tableView beginUpdates];
                self.tableView.tableFooterView = self.tableFooterView;
                [self.tableView endUpdates];
            }
            break;
        }
        case SignInViewControllerCreateNewAccount: {
            CGRect aFrame = self.tableFooterView.frame;
            aFrame.size.height = self.tableFooterViewHeight;
            self.tableFooterView.frame = aFrame;
            [self.signInButton setTitle:@"Create Account" forState:UIControlStateNormal];
            break;
        }
        case SignInViewControllerEnterEmail: {
            self.title = @"Enter Email";
            [self.signInButton setTitle:@"Create Account" forState:UIControlStateNormal];
            self.signInButton.enabled = NO;
            // add row when email is valid
            if (self.isEmailInputValid) {
                self.state = SignInViewControllerEnterRole;
                self.title = @"Select Role";
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
            } else {
                [self.emailTextField becomeFirstResponder];
            }
            break;
        }
        case SignInViewControllerEnterRole: {
            self.title = @"Select Role";
            break;
        }
        case SignInViewControllerEnterContactDetail: {
            self.title = @"Contact Details";
            break;
        }
        case SignInViewControllerCreateAccount: {
            self.title = @"Create Account";
            self.signInButton.enabled = YES;
            break;
        }
    }
}

@end

@implementation WMSignInViewController

@synthesize participant=_participant;

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
    self.title = @"Sign In";
    _tableFooterViewHeight = CGRectGetHeight(self.tableFooterView.frame);
    if (self.isIPadIdiom) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
    if (self.state == SignInViewControllerEnterName) {
        [self.nameTextField becomeFirstResponder];
    }
    [self.navigationItem setHidesBackButton:YES];
    [self.delegate signInViewControllerWillAppear:self];
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    self.savePolicy = SMSavePolicyNetworkThenCache;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isIPadIdiom) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    [self.delegate signInViewControllerWillDisappear:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

- (void)setPatient:(WMPatient *)patient
{
    // do nothing
}

// TODO fixme
//- (void)setWound:(WMWound *)wound
//{
//    // do nothing
//}

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
    if (nil == _participant && self.hasNameInput) {
        _participant = [WMParticipant participantForName:self.nameInput
                                                  create:NO
                                    managedObjectContext:self.managedObjectContext
                                         persistentStore:nil];
    }
    return  _participant;
}

- (void)setParticipant:(WMParticipant *)participant
{
    if (_participant == participant) {
        return;
    }
    // else
    [self willChangeValueForKey:@"participant"];
    _participant = participant;
    [self didChangeValueForKey:@"participant"];
    if (nil != participant.participantType) {
        _selectedParticipantType = participant.participantType;
    }
}

- (WMParticipant *)possibleParticipant
{
    if (self.state != SignInViewControllerCreateNewAccount && nil == _possibleParticipant && self.hasNameInput) {
        _possibleParticipant = [WMParticipant bestMatchingParticipantForUserName:self.nameInput managedObjectContext:self.managedObjectContext];
    }
    return _possibleParticipant;
}

- (BOOL)userNameMatchesUser
{
    return [self.participant.name hasPrefix:self.nameInput];
}

- (NSString *)nameInput
{
    return self.nameTextField.text;
}

- (BOOL)hasNameInput
{
    return [self.nameInput length] > 0;
}

- (BOOL)isEmailInputValid
{
    return [WMUtilities NSStringIsValidEmail:self.emailTextField.text];
}

- (void)reset
{
    self.state = SignInViewControllerEnterName;
    self.nameTextField.text = nil;
    self.emailTextField.text = nil;
    self.tableView.tableFooterView = nil;
    CGRect aFrame = self.tableFooterView.frame;
    aFrame.size.height = self.tableFooterViewHeight;
    self.tableFooterView.frame = aFrame;
    self.signInButton.enabled = YES;
    [self.signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    self.participant = nil;
    self.possibleParticipant = nil;
    self.selectedParticipantType = nil;
    self.userNameForNewAccout = nil;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)signInAction:(id)sender
{
    switch (self.state) {
        case SignInViewControllerCreateNewAccount: {
            if (!self.hasNameInput) {
                return;
            }
            // else user wants to create a new account with the nameInput
            if (nil != [WMParticipant participantForName:self.nameInput
                                                  create:NO
                                    managedObjectContext:self.managedObjectContext
                                         persistentStore:nil]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Participant Account Exists"
                                                                    message:@"A participant with that name already exists."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else {
                // ok to create a new account - show alert sheet
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to create a new account with account name %@?", self.nameInput]
                                                                         delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                           destructiveButtonTitle:@"Create Account"
                                                                otherButtonTitles:nil];
                actionSheet.tag = SignInViewControllerActionCreateAccount;
                [actionSheet showInView:self.view];
            }
            break;
        }
        case SignInViewControllerEnterName: {
            if (nil == self.possibleParticipant) {
                // show alert sheet
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to create a new account with account name %@?", self.nameInput]
                                                                         delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                           destructiveButtonTitle:@"Create Account"
                                                                otherButtonTitles:nil];
                actionSheet.tag = SignInViewControllerActionCreateAccount;
                [actionSheet showInView:self.view];
            } else {
                [self.delegate signInViewController:self didSignInParticipant:self.possibleParticipant];
            }
            break;
        }
        case SignInViewControllerEnterEmail:
        case SignInViewControllerEnterRole: {
            if (!self.hasNameInput) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Participant Name"
                                                                    message:@"Your participant name is not valid. Please update your participant name"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else if (!self.isEmailInputValid) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                                    message:@"Your email is not valid. Please update your email address"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else if (nil == _selectedParticipantType) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Role"
                                                                    message:@"Please select a role"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else {
                // check for contact details
                if (nil == _person) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Contact Details"
                                                                        message:@"Please tap Contact Details"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                // else
            }
            break;
        }
        case SignInViewControllerCreateAccount:
        case SignInViewControllerEnterContactDetail: {
            NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
            WMParticipant *participant = [WMParticipant participantForName:self.nameInput
                                                                    create:YES
                                                      managedObjectContext:managedObjectContext
                                                           persistentStore:nil];
            self.participant = participant;
            participant.email = self.emailTextField.text;
            // save participant before creating relationships
            NSError *error = nil;
            [managedObjectContext saveAndWait:&error];
            [WMUtilities logError:error];
            participant.participantType = _selectedParticipantType;
            [managedObjectContext saveAndWait:&error];
            [WMUtilities logError:error];
            participant.person = _person;
            [managedObjectContext saveAndWait:&error];
            [WMUtilities logError:error];
            [self.delegate signInViewController:self didSignInParticipant:participant];
            break;
        }
    }
}

- (IBAction)createAccountAction:(id)sender
{
    self.state = SignInViewControllerCreateNewAccount;
    [self updateUI];
    [self signInAction:sender];
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
                                                         managedObjectContext:self.managedObjectContext
                                                              persistentStore:nil];
    }
    self.state = SignInViewControllerEnterContactDetail;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - PersonEditorViewControllerDelegate

- (void)personEditorViewController:(WMPersonEditorViewController *)viewController didEditPerson:(WMPerson *)person
{
    self.person = person;
    [self.navigationController popViewControllerAnimated:YES];
    self.state = SignInViewControllerCreateAccount;
    [self.tableView reloadData];
}

- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UIActionSheetDelegate

// after animation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case SignInViewControllerActionCreateAccount: {
            _userNameForNewAccout = self.nameInput;
            if (buttonIndex == actionSheet.cancelButtonIndex) {
                [self reset];
                [self.nameTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                return;
            }
            // else we are creating a new account
            self.state = SignInViewControllerEnterEmail;
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self updateUI];
            break;
        }
        case SignInViewControllerActionResetCreateAccount: {
            if (buttonIndex == actionSheet.cancelButtonIndex) {
                // oops, user wants to continue
                self.nameTextField.text = _userNameForNewAccout;
                [self.emailTextField becomeFirstResponder];
            } else {
                // reset
                [self reset];
                [self updateUI];
                [self.nameTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
            }
            break;
        }
    }
}

#pragma mark - UITextFieldDelegate

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateUserFromInput) withObject:nil afterDelay:0.25];
    return YES;
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if (indexPath.row == 2) {
        WMSimpleTableViewController *simpleTableViewController = self.simpleTableViewController;
        [self.navigationController pushViewController:simpleTableViewController animated:YES];
        simpleTableViewController.title = @"Select Role";
    } else if (indexPath.row == 3) {
        WMPersonEditorViewController *personEditorViewController = self.personEditorViewController;
        WMPerson *person = self.participant.person;
        if (nil == person) {
            person = _person;
        }
        personEditorViewController.person = person;
        [self.navigationController pushViewController:personEditorViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (self.state) {
        case SignInViewControllerCreateNewAccount:
        case SignInViewControllerEnterName: {
            count = 1;
            break;
        }
        case SignInViewControllerEnterEmail: {
            count = 2;
            break;
        }
        case SignInViewControllerEnterRole: {
            count = 3;
            break;
        }
        case SignInViewControllerCreateAccount:
        case SignInViewControllerEnterContactDetail: {
            count = 4;
            break;
        }
    }
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        switch (indexPath.row) {
            case 0: {
                cell = self.nameCell;
                break;
            }
            case 1: {
                cell = self.emailCell;
                break;
            }
            case 2: {
                cell = self.assigneeTypeCell;
                break;
            }
            case 3: {
                cell = self.contactCell;
                break;
            }
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            // nothing
            break;
        }
        case 1: {
            // nothing
            break;
        }
        case 2: {
            cell.detailTextLabel.text = self.selectedParticipantType.title;
            break;
        }
        case 3: {
            cell.detailTextLabel.text = self.person.lastNameFirstName;
            break;
        }
    }
}

@end
