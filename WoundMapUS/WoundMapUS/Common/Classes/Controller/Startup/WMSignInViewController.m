//
//  WMSignInViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSignInViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUserDefaultsManager.h"
#import "WMSeedDatabaseManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

@interface WMSignInViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;
@property (strong, nonatomic) IBOutlet UIView *signInButtonContainerView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@property (readonly, nonatomic) BOOL hasSufficientInput;

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
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    _userNameTextInput = userDefaultsManager.lastUserName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

#pragma mark - Core

- (BOOL)hasSufficientInput
{
    return ([_userNameTextInput length] > 3 && [_passwordTextInput length] > 3);
}

- (void)updateSignInButton
{
    _signInButton.enabled = self.hasSufficientInput;
}

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
    if ([self.userNameTextInput length] < 3) {
        message = @"Please enter a valid username";
    } else if ([self.passwordTextInput length] < 3) {
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [ff loginWithUserName:self.userNameTextInput andPassword:self.passwordTextInput onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Sign in"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            FFUser *user = (FFUser *)object;
            NSAssert(nil != user, @"loginWithUserName:password success but returned object is nil");
            NSParameterAssert([user.userName length] > 0);
            NSAssert([user isKindOfClass:[FFUser class]], @"Expected FFUser but received %@", object);
            // DEPLOYMENT - this should not be needed in production - seeding should be done on the back end anyway
            if (YES) {
                // fetch participant
                NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                __block WMParticipant *participant = [WMParticipant participantForUserName:user.userName
                                                                                    create:NO
                                                                      managedObjectContext:managedObjectContext];
                WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
                dispatch_block_t block = ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    participant = [participant MR_inContext:weakSelf.managedObjectContext];
                    [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                };
                if (nil == participant) {
                    // must be on back end
                    [ffm acquireParticipantForUser:user completionHandler:^(NSError *error, WMParticipant *object) {
                        if (error) {
                            [WMUtilities logError:error];
                        } else {
                            participant = object;
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                block();
                            });
                        }
                    }];
                } else {
                    [ffm updateParticipant:participant completionHandler:^(NSError *error) {
                        if (error) {
                            [WMUtilities logError:error];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                block();
                            });
                        }
                    }];
                }
            } else {
                WMSeedDatabaseManager *seedDatabaseManager = [WMSeedDatabaseManager sharedInstance];
                [seedDatabaseManager seedDatabaseWithCompletionHandler:^(NSError *error) {
                    if (error) {
                        [WMUtilities logError:error];
                    } else {
                        // fetch participant
                        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        __block WMParticipant *participant = [WMParticipant participantForUserName:user.userName
                                                                                            create:NO
                                                                              managedObjectContext:managedObjectContext];
                        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
                        dispatch_block_t block = ^{
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            participant = [participant MR_inContext:weakSelf.managedObjectContext];
                            [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                        };
                        if (nil == participant) {
                            // must be on back end
                            [ffm acquireParticipantForUser:user completionHandler:^(NSError *error, WMParticipant *object) {
                                if (error) {
                                    [WMUtilities logError:error];
                                } else {
                                    participant = object;
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        block();
                                    });
                                }
                            }];
                        } else {
                            [ffm updateParticipant:participant completionHandler:^(NSError *error) {
                                if (error) {
                                    [WMUtilities logError:error];
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        block();
                                    });
                                }
                            }];
                        }
                    }
                }];
            }
        }
    }];
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
                weakSelf.passwordTextInput = textField.text;
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
            self.userNameTextInput = textField.text;
            break;
        }
        case 1001: {
            // password
            self.passwordTextInput = textField.text;
            break;
        }
    }
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return self.hasSufficientInput;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _signInButtonContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44.0;
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
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.delegate = self;
    switch (indexPath.row) {
        case 0: {
            textField.tag = 1000;
            [myCell updateWithLabelText:@"User Name" valueText:_userNameTextInput valuePrompt:@"Enter user name"];
            break;
        }
        case 1: {
            textField.tag = 1001;
            textField.delegate = self;
            textField.secureTextEntry = YES;
            [myCell updateWithLabelText:@"Password" valueText:_passwordTextInput valuePrompt:@"Enter password"];
            break;
        }
    }
}

@end
