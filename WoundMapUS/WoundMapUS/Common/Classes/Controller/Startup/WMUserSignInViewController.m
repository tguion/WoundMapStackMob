//
//  WMUserSignInViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMUserSignInViewController.h"
#import "User.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"
#import "StackMob.h"

@interface WMUserSignInViewController () <UITextFieldDelegate>
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIView *activityIndicatorBackground;

- (IBAction)create:(id)sender;
- (IBAction)authenticate:(id)sender;

@end

@implementation WMUserSignInViewController
#define debug 1

#pragma mark - Accessors

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.appDelegate.coreDataHelper.stackMobStore contextForCurrentThread];
}

#pragma mark - ACCOUNT

- (IBAction)cancelAction:(id)sender
{
    [self.delegate userSignInViewControllerDidCancel:self];
}

- (IBAction)create:(id)sender
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSManagedObjectContext *stackMobContext = self.managedObjectContext;
    [self showWait:YES];
    if ([self textFieldIsBlank]) {
        return;
    }
    // ENSURE NETWORK IS REACHABLE
    CoreDataHelper *coreDataHelper = self.coreDataHelper;
    if (!coreDataHelper.stackMobClient.networkMonitor.currentNetworkStatus == SMNetworkStatusReachable) {
        [self showAlertWithTitle:@"Failed to Create Clinical Team"
                         message:@"The Internet connection appears to be offline."];
        [self updateStatus];
        return;
    }
    // ENSURE USER DOESN'T EXIST
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"username==%@", self.usernameTextField.text]];
    [stackMobContext executeFetchRequest:fetchRequest
                               onSuccess:^(NSArray *results) {
                                   if ([results count] == 1) {
                                       // USER ALREADY EXISTS
                                       [self showAlertWithTitle:@"Please choose another Clinical Team Name"
                                                        message:[NSString stringWithFormat:@"Someone has already created a team with the name '%@'", _usernameTextField.text]];
                                   } else {
                                       // CREATE USER
                                       self.statusLabel.text = [NSString stringWithFormat:@"Creating Clinical Team '%@'...", _usernameTextField.text];
                                       User *newUser = [User instanceUsername:_usernameTextField.text
                                                                     password:_passwordTextField.text
                                                         managedObjectContext:self.managedObjectContext
                                                              persistentStore:nil];
                                       [stackMobContext saveOnSuccess:^{
                                           // USER CREATED SUCCESSFULLY
                                           [self updateStatus];
                                           [self showWait:NO];
                                           [self authenticate:self];
                                       } onFailure:^(NSError *error) {
                                           // USER CREATION FAILED
                                           [stackMobContext deleteObject:newUser];
                                           [newUser removePassword];
                                           [self updateStatus];
                                           [self showWait:NO];
                                           [self showAlertWithTitle:@"Failed to Create Clinical Team"
                                                            message:[NSString stringWithFormat:@"%@",error]];
                                       }];
                                   }
                               } onFailure:^(NSError *error) {
                                   // UNSURE IF USER EXISTS
                                   [self showAlertWithTitle:@"Failed to Check if Clinical Team Exists"
                                                    message:[NSString stringWithFormat:@"%@",error]];
                               }];
}

- (IBAction)authenticate:(id)sender
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([self textFieldIsBlank]) {
        return;
    }
    CoreDataHelper *coreDataHelper = self.coreDataHelper;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    self.statusLabel.text = [NSString stringWithFormat:@"Connecting to Clinical Team '%@'...", _usernameTextField.text];
    [self showWait:YES];
    // ensure new objects are saved prior to an account switch
    [managedObjectContext saveOnSuccess:^{
        [coreDataHelper.stackMobClient loginWithUsername:_usernameTextField.text
                                                password:_passwordTextField.text
                                                 options:[SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyTryNetworkElseCache]
                                               onSuccess:^(NSDictionary *results) {
                                                   NSString *username = [results valueForKey:@"username"];
                                                   [self showAlertWithTitle:@"Success!"
                                                                    message:[NSString stringWithFormat:@"You're now connected to Clinical Team '%@'", username]];
                                                   [self updateStatus];
                                                   [self showWait:NO];
                                                   [self.delegate userSignInViewController:self didSignInUsername:username];
                                               } onFailure:^(NSError *error) {
                                                   if (error.code == 401) {
                                                       [self showAlertWithTitle:@"Failed to Enter Clinical Team"
                                                                        message:@"Access Denied"];
                                                   } else {
                                                       [self showAlertWithTitle:@"Failed to Enter Clinical Team"
                                                                        message:[NSString stringWithFormat:@"%@",
                                                                                 error.localizedDescription]];
                                                   }
                                                   [self updateStatus];
                                                   [self showWait:NO];
                                               }];
    } onFailure:^(NSError *error) {
        NSLog(@"Failed to save context prior to account switch");
    }];
}

#pragma mark - VIEW

- (void)updateStatus
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *coreDataHelper = self.coreDataHelper;
    if([coreDataHelper.stackMobClient isLoggedIn]) {
        [coreDataHelper.stackMobClient getLoggedInUserOnSuccess:^(NSDictionary *result) {
            self.statusLabel.text = [NSString stringWithFormat:@"You're using '%@'", [result objectForKey:@"username"]];
        } onFailure:^(NSError *error) {
            self.statusLabel.text = @"Create or Enter a Clinical Team";
        }];
    } else {
        self.statusLabel.text = @"Create or Enter a Clinical Team";
    }
}

- (void)viewDidLoad
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    self.title = (_createNewUserFlag ? @"Create Team":@"Join Team");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [_usernameTextField setDelegate:self];
    [_passwordTextField setDelegate:self];
    [self hideKeyboardWhenBackgroundIsTapped];
    if (_createNewUserFlag) {
        [_signInButton setTitle:@"Create Team" forState:UIControlStateNormal];
        [_signInButton addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_signInButton setTitle:@"Join Team" forState:UIControlStateNormal];
        [_signInButton addTarget:self action:@selector(authenticate:) forControlEvents:UIControlEventTouchUpInside];
    }
    _signInButton.enabled = NO;
    _usernameTextField.text = _selectedUser.username;
    [self updateStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *string = nil;
    if (_createNewUserFlag) {
        string = @"Create Team name and password.";
    } else {
        if (nil == _selectedUser) {
            string = @"Enter Team name and password.";
        } else {
            string = [NSString stringWithFormat:@"Enter credentials for Team '%@'...", _usernameTextField.text];
        }
    }
    self.statusLabel.text = string;
}

#pragma mark - Core

- (void)updateSignInButtonEnabled
{
    _signInButton.enabled = ([_usernameTextField.text length] > 0 && [_passwordTextField.text length] > 0);
}

#pragma mark - WAITING

- (void)showWait:(BOOL)visible
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_activityIndicatorBackground) {
        _activityIndicatorBackground =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    [_activityIndicatorBackground
     setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [_activityIndicatorBackground setBackgroundColor:[UIColor blackColor]];
    [_activityIndicatorBackground setAlpha:0.5];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicatorView.center = CGPointMake(_activityIndicatorBackground.frame.size.width/2, _activityIndicatorBackground.frame.size.height/2);
    if (visible) {
        [self.view addSubview:_activityIndicatorBackground];
        [_activityIndicatorBackground addSubview:_activityIndicatorView];
        [_activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        [_activityIndicatorBackground removeFromSuperview];
    }
}

#pragma mark - ALERTING

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
    [self showWait:NO];
}

#pragma mark - VALIDATION

- (BOOL)textFieldIsBlank
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_usernameTextField.text isEqualToString:@""] ||
        [_passwordTextField.text isEqualToString:@""]) {
        [self showAlertWithTitle:@"Please Enter a Clinical Team Name and Password"
                         message:@"If you don't have a Clinical Team you can create one by filling in a Clinical Team Name and a Password, then clicking Create"];
        return YES;
    }
    return NO;
}

#pragma mark - DELEGATE: UITextFieldDelegate

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateSignInButtonEnabled) withObject:nil afterDelay:0.0];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - INTERACTION

- (void)hideKeyboardWhenBackgroundIsTapped
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)hideKeyboard
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.view endEditing:TRUE];
}

@end
