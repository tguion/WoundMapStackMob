//
//  WMIAPJoinTeamViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPJoinTeamViewController.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMTeamInvitation.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

@interface WMIAPJoinTeamViewController () <UITextFieldDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;

@property (readonly, nonatomic) WMParticipant *participant;
@property (readonly, nonatomic) WMTeamInvitation *teamInvitation;

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) NSString *pincodeTextInput;

- (IBAction)declineAction:(id)sender;
- (IBAction)acceptAction:(id)sender;

@end

@implementation WMIAPJoinTeamViewController

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
    self.title = @"Team Invitation";
    self.messageLabel.text = self.teamInvitation.invitationMessage;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStylePlain target:self action:@selector(declineAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(acceptAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

- (WMTeam *)team
{
    return self.teamInvitation.team;
}

- (WMTeamInvitation *)teamInvitation
{
    return self.participant.teamInvitation;
}

#pragma mark - Actions

- (IBAction)acceptAction:(id)sender
{
    [self.view endEditing:YES];
    [self performSelector:@selector(delayedAcceptAction:) withObject:nil afterDelay:0.0];
}

- (IBAction)delayedAcceptAction:(id)sender
{
    // check pincode
    if ([_pincodeTextInput integerValue] != self.teamInvitation.passcodeValue) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Pincode"
                                                            message:@"The pincode that you entered does not match the invitation pincode"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else update invitation to accepted and update back end
    WMTeamInvitation *teamInvitation = self.teamInvitation;
    NSManagedObjectContext *managedObjectContext = [teamInvitation managedObjectContext];
    teamInvitation.acceptedFlagValue = YES;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [ff updateObj:teamInvitation
       onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
           if (error) {
               [WMUtilities logError:error];
           }
           // RPN push notification to participant.guid, teamInvitation.inviteeUserName
           [managedObjectContext MR_saveToPersistentStoreAndWait];
           [weakSelf.delegate iapJoinTeamViewControllerDidPurchase:weakSelf];
       } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
           if (error) {
               [WMUtilities logError:error];
           }
           [weakSelf.delegate iapJoinTeamViewControllerDidPurchase:weakSelf];
       }];
}

- (IBAction)declineAction:(id)sender
{
    [self.delegate iapJoinTeamViewControllerDidDecline:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak __typeof(&*self)weakSelf = self;
    [self performBlock:^{
        switch (textField.tag) {
            case 1000: {
                weakSelf.pincodeTextInput = textField.text;
                break;
            }
        }
    } afterDelay:0.1];
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000: {
            // userName
            self.pincodeTextInput = textField.text;
            break;
        }
    }
}

@end
