//
//  WMFTPConfigurationViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFTPConfigurationViewController.h"
#import "MBProgressHUD.h"
#import "WMTextFieldTableViewCell.h"
#import "WMUserDefaultsManager.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"
#import <NMSSH/NMSSH.h>

#define kFTPSuccessAlertViewTag 1000

@interface WMFTPConfigurationViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *hostTextInput;
@property (strong, nonatomic) NSString *pathTextInput;
@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;

@end

@implementation WMFTPConfigurationViewController

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
    self.title = @"FTP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send File"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(sendFileAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    _hostTextInput = userDefaultsManager.lastFTPHost;
    _pathTextInput = userDefaultsManager.lastFTPPath;
    _userNameTextInput = userDefaultsManager.lastFTPUserName;
    _passwordTextInput = userDefaultsManager.lastFTPPassword;
    [self updateSendFileButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (BOOL)hasSufficientInput
{
    return ([_hostTextInput length] && [_pathTextInput length] && [_userNameTextInput length] && [_passwordTextInput length]);
}

- (void)updateSendFileButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.hasSufficientInput;
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate ftpConfigurationViewControllerDidFinish:self];
}

- (IBAction)sendFileAction:(id)sender
{
    [self.view endEditing:YES];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    if (_hostTextInput) {
        userDefaultsManager.lastFTPHost = _hostTextInput;
    }
    if (_pathTextInput) {
        userDefaultsManager.lastFTPPath = _pathTextInput;
    }
    if (_userNameTextInput) {
        userDefaultsManager.lastFTPUserName = _userNameTextInput;
    }
    if (_passwordTextInput) {
        userDefaultsManager.lastFTPPassword = _passwordTextInput;
    }
    NMSSHSession *session = [NMSSHSession connectToHost:_hostTextInput
                                           withUsername:_userNameTextInput];
    if (session.isConnected) {
        [session authenticateByPassword:_passwordTextInput];
        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed Authentication"
                                                                message:@"The host, path, username, and or password was not accepted by the FTP endpoint"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                            message:@"The host does not appear to accept a connection."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfFileSystemForPath:[self.url path] error:&error];
    long long fileSize = 0;
    if (nil == error) {
        fileSize = fileAttributes.fileSize;
        NSLog(@"File size: %lld bytes", fileSize);
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Uploading file...";
    BOOL success = [session.channel uploadFile:[self.url path]
                                            to:_pathTextInput
                                      progress:^BOOL(NSUInteger progress) {
                                          hud.labelText = [NSString stringWithFormat:@"%d bytes", progress];
                                          if (progress >= fileSize) {
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                                          }
                                          return YES;
                                      }];
    [session disconnect];

    if (success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Finished"
                                                            message:@"The patient file uploaded successfully."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        alertView.tag = kFTPSuccessAlertViewTag;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Failed"
                                                            message:@"The patient file failed to uploaded successfully."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.delegate ftpConfigurationViewControllerDidFinish:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak __typeof(&*self)weakSelf = self;
    [self performBlock:^{
        switch (textField.tag) {
            case 1000: {
                // host
                self.hostTextInput = textField.text;
                break;
            }
            case 1001: {
                // path
                self.pathTextInput = textField.text;
                break;
            }
            case 2000: {
                // userName
                self.userNameTextInput = textField.text;
                break;
            }
            case 2001: {
                // password
                self.passwordTextInput = textField.text;
                break;
            }
        }
        [weakSelf updateSendFileButton];
    } afterDelay:0.1];
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000: {
            // host
            self.hostTextInput = textField.text;
            break;
        }
        case 1001: {
            // path
            self.pathTextInput = textField.text;
            break;
        }
        case 2000: {
            // userName
            self.userNameTextInput = textField.text;
            break;
        }
        case 2001: {
            // password
            self.passwordTextInput = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 2;
            break;
        case 1:
            count = 2;
            break;
    }
    return count;
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
    switch (indexPath.section) {
        case 0: {
            // host/path
            switch (indexPath.row) {
                case 0: {
                    textField.tag = 1000;
                    [myCell updateWithLabelText:@"Host" valueText:_hostTextInput valuePrompt:@"Enter host"];
                    break;
                }
                case 1: {
                    textField.tag = 1001;
                    textField.delegate = self;
                    [myCell updateWithLabelText:@"Path" valueText:_pathTextInput valuePrompt:@"Enter path"];
                    break;
                }
            }
            break;
        }
        case 1: {
            // userName/password
            switch (indexPath.row) {
                case 0: {
                    textField.tag = 2000;
                    [myCell updateWithLabelText:@"User Name" valueText:_userNameTextInput valuePrompt:@"Enter user name"];
                    break;
                }
                case 1: {
                    textField.tag = 2001;
                    textField.delegate = self;
                    textField.secureTextEntry = YES;
                    [myCell updateWithLabelText:@"Password" valueText:_passwordTextInput valuePrompt:@"Enter password"];
                    break;
                }
            }
            break;
        }
    }
}

@end
