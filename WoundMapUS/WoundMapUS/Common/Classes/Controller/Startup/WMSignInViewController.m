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
#import "WMTeam.h"
#import "WMTeamPolicy.h"
#import "WMTeamInvitation.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUserDefaultsManager.h"
#import "WMSeedDatabaseManager.h"
#import "WMPhotoManager.h"
#import "IAPManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

#define kSubscriptionExpiredAlertViewTag 1000

@interface WMSignInViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *userNameTextInput;
@property (strong, nonatomic) NSString *passwordTextInput;
@property (strong, nonatomic) IBOutlet UIView *signInButtonContainerView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@property (nonatomic) BOOL makePasswordFieldFirstResponder;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign In"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(signInAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    if (userDefaultsManager.showUserNameOnSignIn) {
        _userNameTextInput = userDefaultsManager.lastUserName;
        if ([_userNameTextInput length]) {
            _makePasswordFieldFirstResponder = YES;
        }
//        _passwordTextInput = @"WoundMap00"; // DEBUG
    }
    WMSeedDatabaseManager *seedDatabaseManager = [WMSeedDatabaseManager sharedInstance];
    [seedDatabaseManager seedLocalData:self.managedObjectContext];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    hud.labelText = @"Updating Your Account";
    hud.detailsLabelText = @"This may take a minute.";
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __weak __typeof(&*self)weakSelf = self;
    [ff loginWithUserName:self.userNameTextInput andPassword:self.passwordTextInput onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Sign in"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
            [alertView show];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        } else {
            FFUser *user = (FFUser *)object;
            [weakSelf.appDelegate saveUserCredentialsInKeychain:_userNameTextInput password:_passwordTextInput];
            // register for remote notifications
            [weakSelf.appDelegate registerDeviceToken];
            // remove cache
            __block WMParticipant *participant = nil;
//            WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
//            NSString *lastUserName = userDefaultsManager.lastUserName;
//            if (lastUserName && ![lastUserName isEqualToString:user.userName]) {
//                // participant on this device has changed
//                weakSelf.appDelegate.participant = nil;
//                [WMParticipant MR_truncateAllInContext:managedObjectContext];
//                [managedObjectContext MR_saveToPersistentStoreAndWait];
//            }
            // fetch participant
            participant = [WMParticipant participantForUserName:user.userName
                                                         create:NO
                                           managedObjectContext:managedObjectContext];
            dispatch_block_t block = ^{
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                // update participant
                NSError *localError = nil;
                [ff updateObj:participant error:&localError];
                if (localError) {
                    [WMUtilities logError:localError];
                }
                // handle team invitation confirmation
                WMTeam *team = participant.team;
                if (team) {
                    // check if subscription has expired
                    if ([participant.dateTeamSubscriptionExpires compare:[NSDate date]] == NSOrderedAscending) {
                        // times up
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscription Expired"
                                                                            message:@"Your team leader must extend your subscription to continue to use WoundMap"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Dismiss"
                                                                  otherButtonTitles:nil];
                        alertView.tag = kSubscriptionExpiredAlertViewTag;
                        [alertView show];
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                        if (participant.isTeamLeader) {
                            [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                        }
                    } else {
                        // delete photos
                        if (participant.isTeamLeader) {
                            WMTeamPolicy *teamPolicy = team.teamPolicy;
                            if (teamPolicy.deletePhotoBlobsValue) {
                                [ffm deleteExpiredPhotos:teamPolicy];
                            }
                            // FIXME: have seen some participant's team relationship drop
                            for (WMParticipant *member in team.participants) {
                                if (nil == member.team) {
                                    // check if we haven't fetched
                                    NSString *q = [member.ffUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
                                    q = [q stringByAppendingString:@"/team"];
                                    [ff getObjFromUri:q error:&localError];
                                    if (localError) {
                                        [WMUtilities logError:error];
                                    }
                                    if (nil == member.team) {
                                        member.team = team;
                                        [ff updateObj:member error:&localError];
                                    }
                                }
                            }
                        }
                        [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                    }
                } else {
                    __block WMTeamInvitation *teamInvitation = participant.teamInvitation;
                    if (nil == teamInvitation) {
                        // look for team invitation
                        [ff getArrayFromUri:[NSString stringWithFormat:@"/%@/(inviteeUserName eq '%@')", [WMTeamInvitation entityName], user.userName] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                            if ([object count]) {
                                // invitation is for this participant
                                object = [object firstObject];
                                NSParameterAssert([object isKindOfClass:[WMTeamInvitation class]]);
                                teamInvitation = object;
                                participant.teamInvitation = teamInvitation;
                                [managedObjectContext MR_saveToPersistentStoreAndWait];
                                teamInvitation.invitee = participant;
                                [managedObjectContext MR_saveToPersistentStoreAndWait];
                                NSError *error = nil;
                                [ff updateObj:teamInvitation error:&error];
                                NSAssert(nil == error, @"Unable to update teamInvitation: %@, error: %@", teamInvitation, error);
                                [ff updateObj:participant error:&error];
                                NSAssert(nil == error, @"Unable to update participant: %@, error: %@", participant, error);
                            }
                            [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                        }];
                    } else {
                        [weakSelf.delegate signInViewController:weakSelf didSignInParticipant:participant];
                    }
                }
                // upload any woundPhoto blobs that were not uploaded
                WMPhotoManager *photoManager = [WMPhotoManager sharedInstance];
                if (!photoManager.photoUploadInProgress) {
                    [photoManager uploadWoundPhotoBlobsFromObjectIds];
                }
            };
            if (nil == participant) {
                // must be on back end
                [ffm acquireParticipantForUser:user completionHandler:^(NSError *error, WMParticipant *object) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    participant = object;
                    participant.dateLastSignin = [NSDate date];
                    participant.user = user;
                    block();
                }];
            } else {
                [ffm updateParticipant:participant completionHandler:^(NSError *error) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    participant.dateLastSignin = [NSDate date];
                    participant.user = user;
                    block();
                }];
            }
        }
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSubscriptionExpiredAlertViewTag) {
        [self.appDelegate signOut];
    }
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
    BOOL shouldReturn = self.hasSufficientInput;
    if (shouldReturn) {
        [self signInAction:nil];
    }
    return shouldReturn;
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
            if (_makePasswordFieldFirstResponder) {
                [textField becomeFirstResponder];
                _makePasswordFieldFirstResponder = NO;
            }
            break;
        }
    }
}

@end
