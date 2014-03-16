//
//  WMSignInViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSignInViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMParticipant.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMSignInViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;
@property (strong, nonatomic) IBOutlet UIView *signInButtonContainerView;

@end

@implementation WMSignInViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

#pragma mark - Core

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate signInViewControllerDidCancel:self];
}

- (IBAction)signInAction:(id)sender
{
    [self.view endEditing:YES];
    [self performSelector:@selector(delayedSignInAction) withObject:nil afterDelay:0.0];
}

- (void)delayedSignInAction
{
    NSString *message = nil;
    if ([self.userNameTextInput length] == 0) {
        message = @"Please enter a valid username";
    } else if ([self.passwordTextInput length] == 0) {
        message = @"Please enter a valid password";
    }
    if ([message length] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Inputs"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else
    [self showProgressViewWithMessage:@"Signing in..."];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [ff loginWithUserName:self.userNameTextInput andPassword:self.passwordTextInput onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        [weakSelf hideProgressView];
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Sign in"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            WMParticipant *participant = (WMParticipant *)object;
            NSAssert(nil != participant, @"loginWithUserName:password success but returned object is nil");
            NSAssert([participant isKindOfClass:[WMParticipant class]], @"Expected WMParticipant but received %@", object);
            [self.delegate signInViewController:self didSignInParticipant:participant];
        }
    }];
}

#pragma mark - UITextFieldDelegate

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
            }
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _signInButtonContainerView;
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

// Customize the appearance of table view cells.
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
    switch (indexPath.row) {
        case 0: {
            textField.delegate = self;
            textField.placeholder = @"Enter user name";
            break;
        }
        case 1: {
            textField.delegate = self;
            textField.secureTextEntry = YES;
            break;
        }
    }
}

@end
