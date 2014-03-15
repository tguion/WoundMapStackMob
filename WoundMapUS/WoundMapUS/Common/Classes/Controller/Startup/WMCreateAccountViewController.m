//
//  WMCreateAccountViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCreateAccountViewController.h"
#import "WMParticipant.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"

typedef NS_ENUM(NSInteger, WMCreateAccountState) {
    CreateAccountInitial,           // username, password, password confirm
    WMWelcomeStateSignedInNoTeam,   // Sign Out | Join Team, Create Team, No Team (signed in user has not joined/created a team)
    WMWelcomeStateTeamSelected,     // Sign Out | Team (value) | Clinical Setting | Patient
    WMWelcomeStateDeferTeam,        // Sign Out | Join Team, Create Team, No Team | Clinical Setting | Patient
};

@interface WMCreateAccountViewController () <UITextFieldDelegate>

@property (nonatomic) WMCreateAccountState state;
@property (strong, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *passwordConfirm;

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
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMParticipant *)participant
{
    if (nil == _participant) {
        _participant = [WMParticipant MR_createInContext:self.managedObjectContext];
    }
    return _participant;
}

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
    }
    return cellReuseIdentifier;
}

- (void)checkForMatchingPasswords
{
    if (![self.password isEqualToString:self.passwordConfirm]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mismatch Passwords"
                                                            message:@"Password and Confirm Password do not match."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    if (_participant) {
        [_participant MR_deleteEntity];
    }
    [self.delegate createAccountViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate createAccountViewController:self didCreateParticipant:self.participant];
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
        self.passwordConfirm = nil;
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
                    self.participant.userName = textField.text;
                    break;
                }
                case 1: {
                    // password
                    self.password = textField.text;
                    break;
                }
                case 2: {
                    // password
                    self.passwordConfirm = textField.text;
                    [self checkForMatchingPasswords];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section > 0);
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
        case 0: {
            count = 3;
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
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    [myCell updateWithLabelText:@"User name" valueText:self.participant.userName valuePrompt:@"unique username"];
                    break;
                }
                case 1: {
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    [myCell updateWithLabelText:@"Password" valueText:self.password valuePrompt:@"enter a password"];
                    break;
                }
                case 2: {
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    [myCell updateWithLabelText:@"Password Confirm" valueText:self.passwordConfirm valuePrompt:@"confirm password"];
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
