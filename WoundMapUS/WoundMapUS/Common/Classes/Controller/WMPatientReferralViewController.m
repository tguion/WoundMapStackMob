//
//  WMPatientReferralViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/2/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientReferralViewController.h"
#import "WMPatientTableViewController.h"
#import "WMParticipantTableViewController.h"
#import "WMTextViewTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMPatientReferral.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMPatientReferralViewController () <PatientTableViewControllerDelegate, ParticipantTableViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (nonatomic) BOOL didCreateReferral;
@property (nonatomic) BOOL didAddPatientToReferral;
@property (nonatomic) BOOL didChangeReferree;

@property (strong, nonatomic) WMParticipant *referree;
@property (strong, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) NSString *messageTextViewText;
@property (strong, nonatomic) NSArray *messageHistory;

@property (strong, nonatomic) IBOutlet UIView *deletePatientReferralContainerView;

- (IBAction)cancelAction:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)deletePatientReferral:(id)sender;

@end

@implementation WMPatientReferralViewController

@synthesize patient=_patient;

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
    NSParameterAssert(self.patient);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Referral";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [self.tableView registerClass:[WMTextViewTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageHistoryCell"];
    // data
    if (_patientReferral) {
        // we want to support cancel, so make sure we have an undoManager
        if (nil == self.managedObjectContext.undoManager) {
            self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
            _removeUndoManagerWhenDone = YES;
        }
        [self.managedObjectContext.undoManager beginUndoGrouping];
        self.tableView.tableFooterView = _deletePatientReferralContainerView;
    } else {
        WMParticipant *participant = self.appDelegate.participant;
        _patientReferral = [WMPatientReferral MR_createInContext:self.managedObjectContext];
        _patientReferral.patient = self.appDelegate.navigationCoordinator.patient;
        _patientReferral.referrer = participant;
        _didCreateReferral = YES;
        // create on back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        WMPatient *patient = self.patient;
        __block NSInteger counter = 0;
        __weak __typeof(&*self)weakSelf = self;
        FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                --counter;
                if (counter == 0) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                }
            }
        };
        FFHttpMethodCompletion createCompletionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                ++counter;
                [ff grabBagAddItemAtFfUrl:_patientReferral.ffUrl
                             toObjAtFfUrl:patient.ffUrl
                              grabBagName:WMPatientRelationships.referrals
                               onComplete:completionHandler];
                ++counter;
                [ff grabBagAddItemAtFfUrl:_patientReferral.ffUrl
                             toObjAtFfUrl:participant.ffUrl
                              grabBagName:WMParticipantRelationships.sourceReferrals
                               onComplete:completionHandler];
            }
        };
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ff createObj:_patientReferral atUri:[NSString stringWithFormat:@"/%@", [WMPatientReferral entityName]] onComplete:createCompletionHandler];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (void)setPatientReferral:(WMPatientReferral *)patientReferral
{
    if (_patientReferral == patientReferral) {
        return;
    }
    // else
    _patientReferral = patientReferral;
    _patient = patientReferral.patient;
    _referree = patientReferral.referree;
    if (nil == patientReferral.dateAccepted) {
        patientReferral.dateAccepted = [NSDate date];
    }
}

- (WMPatient *)patient
{
    if (_patient) {
        return _patient;
    }
    // else
    if (_patientReferral.patient) {
        return _patientReferral.patient;
    }
    // else
    return self.appDelegate.navigationCoordinator.patient;
}

- (NSString *)messageTextViewText
{
    WMTextViewTableViewCell *cell = (WMTextViewTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell.textViewText;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // message input
                    cellReuseIdentifier = @"TextCell";
                    break;
                }
                default: {
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
            }
            break;
        }
        case 1: {
            // message history
            cellReuseIdentifier = @"MessageHistoryCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (NSArray *)messageHistory
{
    if (nil == _messageHistory) {
        _messageHistory = _patientReferral.attributedStringMessageHistory;
    }
    return _messageHistory;
}

- (void)presentChoosePatientViewController
{
    WMPatientTableViewController *patientTableViewController = [[WMPatientTableViewController alloc] initWithNibName:@"WMPatientTableViewController" bundle:nil];
    patientTableViewController.delegate = self;
    [self.navigationController pushViewController:patientTableViewController animated:YES];
}

- (void)presentChooseParticipantViewController
{
    WMParticipantTableViewController *participantTableViewController = [[WMParticipantTableViewController alloc] initWithNibName:@"WMParticipantTableViewController" bundle:nil];
    participantTableViewController.delegate = self;
    [self.navigationController pushViewController:participantTableViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.view endEditing:YES];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (managedObjectContext.undoManager.canUndo) {
            [managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            managedObjectContext.undoManager = nil;
        }
    }
    if (_didCreateReferral) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_patientReferral from:self.patient grabBagName:WMPatientRelationships.referrals error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff grabBagRemove:_patientReferral from:self.appDelegate.participant grabBagName:WMParticipantRelationships.sourceReferrals error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_patientReferral error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    [self.delegate patientReferralViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    if (nil == _referree) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing To"
                                                            message:@"Please select the participant you want to refer the patient."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSString *message = self.messageTextViewText;
    if ([message length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Message"
                                                            message:@"Please add a message to your referral."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else
    WMParticipant *participant = self.appDelegate.participant;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        managedObjectContext.undoManager = nil;
    }
    [_patientReferral prependMessage:message from:participant];
    // wait for back end calls to complete
    __block NSInteger counter = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            if (--counter == 0) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [weakSelf.delegate patientReferralViewControllerDidFinish:weakSelf];
            }
        }
    };
    if (_didChangeReferree) {
        ++counter;
        _patientReferral.dateAccepted = nil;
        [ff grabBagRemoveItemAtFfUrl:_patientReferral.ffUrl
                      fromObjAtFfUrl:_patientReferral.referree.ffUrl
                         grabBagName:WMParticipantRelationships.targetReferrals
                          onComplete:completionHandler];
        ++counter;
        [ff grabBagAddItemAtFfUrl:_patientReferral.ffUrl
                     toObjAtFfUrl:participant.ffUrl
                      grabBagName:WMParticipantRelationships.sourceReferrals
                       onComplete:completionHandler];
    }
    _patientReferral.referree = _referree;
    if (_didAddPatientToReferral) {
        ++counter;
        self.patientReferral.patient = _patient;
        [ff grabBagAddItemAtFfUrl:_patientReferral.ffUrl
                     toObjAtFfUrl:_patient.ffUrl
                      grabBagName:WMPatientRelationships.referrals
                       onComplete:completionHandler];
    }
    ++counter;
    [ff grabBagAddItemAtFfUrl:_patientReferral.ffUrl
                 toObjAtFfUrl:_referree.ffUrl
                  grabBagName:WMParticipantRelationships.targetReferrals
                   onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
       [ff updateObj:_patientReferral onComplete:completionHandler onOffline:completionHandler];
    }];
}

- (IBAction)deletePatientReferral:(id)sender
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __block NSInteger counter = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            if (--counter == 0) {
                [managedObjectContext MR_deleteObjects:@[_patientReferral]];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                _patientReferral = nil;
                [weakSelf.delegate patientReferralViewControllerDidFinish:weakSelf];
            }
        }
    };
    if (_patientReferral.referrer) {
        ++counter;
        [_patientReferral.referrer removeSourceReferralsObject:_patientReferral];
        [ff grabBagRemoveItemAtFfUrl:_patientReferral.ffUrl
                      fromObjAtFfUrl:_patientReferral.referrer.ffUrl
                         grabBagName:WMParticipantRelationships.sourceReferrals
                          onComplete:completionHandler];
    }
    if (_patientReferral.referree) {
        ++counter;
        [_patientReferral.referree removeTargetReferralsObject:_patientReferral];
        [ff grabBagRemoveItemAtFfUrl:_patientReferral.ffUrl
                      fromObjAtFfUrl:_patientReferral.referree.ffUrl
                         grabBagName:WMParticipantRelationships.targetReferrals
                          onComplete:completionHandler];
    }
    if (_patientReferral.patient) {
        ++counter;
        [_patientReferral.patient removeReferralsObject:_patientReferral];
        [ff grabBagRemoveItemAtFfUrl:_patientReferral.ffUrl
                      fromObjAtFfUrl:_patientReferral.patient.ffUrl
                         grabBagName:WMPatientRelationships.referrals
                          onComplete:completionHandler];
    }
    ++counter;
    [ff deleteObj:_patientReferral
       onComplete:completionHandler
        onOffline:completionHandler];
}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient
{
    // update our reference to current patient
    if (nil != patient) {
        _didAddPatientToReferral = YES;
        _patient = patient;
    }
    [self.navigationController popViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ParticipantTableViewControllerDelegate

- (NSPredicate *)participantPredicate
{
    WMParticipant *participant = self.appDelegate.participant;
    return [NSPredicate predicateWithFormat:@"%K == %@ AND %K != %@", WMParticipantRelationships.team, participant.team, WMParticipantAttributes.userName, participant.userName];
}

- (void)participantTableViewControllerDidCancel:(WMParticipantTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)participantTableViewController:(WMParticipantTableViewController *)viewController didSelectParticipant:(WMParticipant *)participant
{
    if (_referree && participant != _referree) {
        _didChangeReferree = YES;
    }
    _referree = participant;
    [self.navigationController popViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    height = 128.0;
                    break;
                }
            }
            break;
        }
        case 1: {
            // message history
            CGFloat width = CGRectGetWidth(self.view.bounds) - self.tableView.separatorInset.left - self.tableView.separatorInset.right;
            NSAttributedString *message = [self.messageHistory objectAtIndex:indexPath.row];
            CGRect rect = [message boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
            height = MAX(CGRectGetHeight(rect), 88.0);
            break;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 1: {
                    // patient
                    if (nil == _patientReferral.patient) {
                        [self presentChoosePatientViewController];
                    }
                    break;
                }
                case 2: {
                    // refer to
                    [self presentChooseParticipantViewController];
                    break;
                }
            }
            break;
        }
        case 1: {
            // nothing now
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self.messageHistory count] ? 2:1);
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
            count = [self.messageHistory count];
            break;
        }
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Message to Team Member";
    if (section == 1) {
        title = @"Message History";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    WMTextViewTableViewCell *myCell = (WMTextViewTableViewCell *)cell;
                    [myCell updateWithPrompt:nil message:nil];
                    break;
                }
                case 1: {
                    cell.textLabel.text = @"Patient";
                    cell.detailTextLabel.text = [self.patient lastNameFirstName];
                    cell.accessoryType = (nil == _patientReferral.patient ? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone);
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Refer To";
                    cell.detailTextLabel.text = _referree.name;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
        case 1: {
            NSAttributedString *message = [self.messageHistory objectAtIndex:indexPath.row];
            cell.textLabel.attributedText = message;
            break;
        }
    }
    
}

@end
