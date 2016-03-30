//
//  WMShareViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMShareViewController.h"
#import "WMPrintConfigureViewController.h"
#import "IAPNonConsumableViewController.h"
#import "WMPatientReferralViewController.h"
#import "WMFTPConfigurationViewController.h"
#import "WMRequestConsultViewController.h"
#import "PrintConfiguration.h"
#import "WMParticipant.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
#import "WMPsychoSocialGroup.h"
#import "WMSkinAssessmentGroup.h"
#import "WMCarePlanGroup.h"
#import "WMPatientReferral.h"
#import "IAPManager.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMEmailManager.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WMShareViewController () <PrintConfigureViewControllerDelegate, MFMailComposeViewControllerDelegate, PatientReferralDelegate, FTPConfigurationDelegate, RequestConsultDelegate>

@property (weak, nonatomic) IBOutlet UILabel *creditStatus;
@property (weak, nonatomic) IBOutlet UIButton *purchaseMoreTokensButton;
@property (strong, nonatomic) IBOutlet UIView *selectPDFSectionFooterView;

@property (nonatomic) SelectWoundAndActionShareOption shareOption;

@property (readonly, nonatomic) WMPrintConfigureViewController *printConfigureViewController;
@property (readonly, nonatomic) WMPatientReferralViewController *patientReferralViewController;
@property (readonly, nonatomic) WMFTPConfigurationViewController *ftpConfigurationViewController;
@property (readonly, nonatomic) WMRequestConsultViewController *requestConsultViewController;

@property (strong, nonatomic) WMPatientReferral *patientReferral;

- (void)navigateToEmailClinicalAssessmentDocument;
- (void)navigateToPrintClinicalAssessmentDocument;
- (void)navigateToPushEMR;

- (IBAction)purchaseMoreTokens:(id)sender;

@end

@implementation WMShareViewController

CGFloat kCreditsMargin = 20;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        self.preferredContentSize = CGSizeMake(320.0, 420.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Share Record";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    _creditStatus.backgroundColor = [UIColor whiteColor];
    _creditStatus.textColor = [UIColor grayColor];
    // TODO jms: remove... for debug purposes
    //    self.navigationItem.leftBarButtonItems =
    //        [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"diag dump" style:UIBarButtonItemStylePlain target:self action:@selector(diagDumpAction:)],
    //                                  [[UIBarButtonItem alloc] initWithTitle:@"token delete" style:UIBarButtonItemStylePlain target:self action:@selector(resetTokenAction:)],
    //                                  nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCreditStatusText];
}

- (void)updateCreditStatusText
{
    IAPManager *iapManager = [IAPManager sharedInstance];
    WMParticipant *participant = self.appDelegate.participant;
    IAPTokenCountHandler completionHandler = ^(NSError *error, NSInteger tokenCount, NSDate *lastTokenCreditPurchaseDate) {
        NSInteger creditsAvailable = participant.reportTokenCountValue;
        NSString *creditStatusText = [NSString stringWithFormat:@"CREDITS REMAINING: %ld", (long)creditsAvailable];
        
        NSDate *lastPurchasedDate = participant.lastTokenCreditPurchaseDate;
        if (nil != lastPurchasedDate) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            creditStatusText = [NSString stringWithFormat:@"%@\nCREDITS LAST PURCHASED: %@",
                                creditStatusText,
                                [dateFormatter stringFromDate:lastPurchasedDate]];
        }
        if (creditsAvailable < 0) {
            creditStatusText =
            [NSString stringWithFormat:@"%@\nCREDITS APPEAR TO HAVE BEEN USED ON ANOTHER iOS DEVICE. WoundMap CAN RESOLVE THIS WITH A SUBSEQUENT CREDIT PURCHASE.",
             creditStatusText];
        }
        _creditStatus.text = creditStatusText;
        [_creditStatus sizeToFit];
        
        [_selectPDFSectionFooterView updateConstraints];
        [self.tableView reloadData];
    };
    [iapManager pdfTokensAvailable:completionHandler];
}

-(NSDictionary *)creditStatusTextAttributes
{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                            [UIColor blackColor], NSForegroundColorAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName,
                            nil];
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.delegate shareViewControllerDidFinish:self];
}

- (IBAction)resetTokenAction:(id)sender
{
    IAPManager *iapManager = [IAPManager sharedInstance];
    [iapManager resetTokenCount];
    [self updateCreditStatusText];
}

- (IBAction) diagDumpAction:(id)sender
{
    IAPManager *iapManager = [IAPManager sharedInstance];
    [iapManager diagDumpAction];
}

- (IBAction)purchaseMoreTokens:(id)sender
{
    NSString *productIdentifier = @"pdf report aggregator";
    __weak __typeof(&*self)weakSelf = self;
    [self presentIAPViewControllerForProductIdentifier:productIdentifier
                                          successBlock:^(SKPaymentTransaction *transaction) {
                                              [weakSelf updateCreditStatusText];
                                          } proceedAlways:YES
                                            withObject:sender];
}

#pragma mark - View Controllers

- (WMPrintConfigureViewController *)printConfigureViewController
{
    WMPrintConfigureViewController *printConfigureViewController = [[WMPrintConfigureViewController alloc] initWithNibName:@"WMPrintConfigureViewController" bundle:nil];
    printConfigureViewController.delegate = self;
    return printConfigureViewController;
}

- (WMPatientReferralViewController *)patientReferralViewController
{
    WMPatientReferralViewController *patientReferralViewController = [[WMPatientReferralViewController alloc] initWithNibName:@"WMPatientReferralViewController" bundle:nil];
    patientReferralViewController.delegate = self;
    patientReferralViewController.patientReferral = [self.patient patientReferral];
    return patientReferralViewController;
}

- (WMFTPConfigurationViewController *)ftpConfigurationViewController
{
    WMFTPConfigurationViewController *viewController = [[WMFTPConfigurationViewController alloc] initWithNibName:@"WMFTPConfigurationViewController" bundle:nil];
    viewController.delegate = self;
    return viewController;
}

- (WMRequestConsultViewController *)requestConsultViewController
{
    WMRequestConsultViewController *viewController = [[WMRequestConsultViewController alloc] initWithNibName:@"WMRequestConsultViewController" bundle:nil];
    viewController.delegate = self;
    return viewController;
}

#pragma mark - Navigation

- (void)navigateToEmailClinicalAssessmentDocument
{
    // TODO finish navigate to email with attachement
}

- (void)navigateToPrintClinicalAssessmentDocument
{
    // TODO finish navigate to print
}

- (void)navigateToPushEMR
{
    // TODO finish navigate to push EMR
}

- (void)navigateToPatientReferral
{
    [self.navigationController pushViewController:self.patientReferralViewController animated:YES];
}

- (void)navigateToRequestConsult
{
    [self.navigationController pushViewController:self.requestConsultViewController animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
            //			message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
            //			message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
            //			message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
            //			message.text = @"Result: failed";
			break;
		default:
            //			message.text = @"Result: not sent";
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - PrintConfigureViewControllerDelegate

- (BOOL)shouldRequestPassword
{
    if (self.shareOption == SelectWoundAndActionShareOption_Email) {
        WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
        return userDefaultsManager.shouldRequestPasswordForEmailAttachment;
    }
    // else
    return NO;
}

- (BOOL)hasRiskAssessment
{
    return ([WMMedicationGroup medicalGroupsCount:self.patient] + [WMDeviceGroup deviceGroupsCount:self.patient] > 0) + [WMPsychoSocialGroup psychoSocialGroupsCount:self.patient];
}

- (BOOL)hasSkinAssessment
{
    return [WMSkinAssessmentGroup skinAssessmentGroupsCount:self.patient] > 0;
}

- (BOOL)hasCarePlan
{
    return [WMCarePlanGroup carePlanGroupsCount:self.patient] > 0;
}

- (void)printConfigureViewController:(WMPrintConfigureViewController *)controller
 didConfigurePrintWithConfigureation:(PrintConfiguration *)printConfiguration
                   fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    IAPManager *iapManager = [IAPManager sharedInstance];
    WMEmailManager *emailManager = [WMEmailManager sharedInstance];
    [self.navigationController popViewControllerAnimated:NO];
    __weak __typeof(&*self)weakSelf = self;
    switch (self.shareOption) {
        case SelectWoundAndActionShareOption_Print: {
            NSURL *url = [pdfPrintManager pdfURLForPatient:controller.patient];
            [pdfPrintManager drawPDFToURL:url forPatient:controller.patient printConfiguration:printConfiguration];
            [pdfPrintManager printURL:url patient:self.patient fromBarButtonItem:barButtonItem
                        onPrintFinish:^(BOOL completed, NSError *error) {
                            if (completed && error == nil) {
                                [iapManager sharePdfReportCreditHasBeenUsed];
                                [weakSelf updateCreditStatusText];
                            }
                            if (weakSelf.isIPadIdiom) {
                                [weakSelf.tableView reloadData];
                            }
                        }];
            break;
        }
        case SelectWoundAndActionShareOption_Email: {
            NSURL *url = [pdfPrintManager pdfURLForPatient:controller.patient];
            [pdfPrintManager drawPDFToURL:url forPatient:controller.patient printConfiguration:printConfiguration];
            [emailManager displayComposerSheet:self
                                     attachPDF:url
                             passwordProtected:[printConfiguration.password length]
                                  onMailFinish:^(MFMailComposeResult result, NSError *error) {
                                      if (error == nil && (result == MFMailComposeResultSaved || result == MFMailComposeResultSent)) {
                                          [iapManager sharePdfReportCreditHasBeenUsed];
                                          [weakSelf updateCreditStatusText];
                                      }
                                      if (weakSelf.isIPadIdiom) {
                                          [weakSelf.tableView reloadData];
                                      }
                                  }];
            break;
        }
        case SelectWoundAndActionShareOption_FTP: {
            NSURL *url = [pdfPrintManager pdfURLForPatient:controller.patient];
            [pdfPrintManager drawPDFToURL:url forPatient:controller.patient printConfiguration:printConfiguration];
            WMFTPConfigurationViewController *viewController = self.ftpConfigurationViewController;
            viewController.url = url;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navigationController.delegate = self.appDelegate;
            [self presentViewController:navigationController animated:YES completion:^{
                // nothing
            }];
            break;
        }
        case SelectWoundAndActionShareOption_EMR: {
            break;
        }
        case SelectWoundAndActionShareOption_iCloud: {
            break;
        }
    }
    // clear viewController cache
    [controller clearAllReferences];
}

- (void)printConfigureViewControllerDidCancel:(WMPrintConfigureViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear viewController cache
    [controller clearAllReferences];
}

#pragma mark - PatientReferralDelegate

- (void)patientReferralViewControllerDidFinish:(WMPatientReferralViewController *)viewController
{
    _patientReferral = viewController.patientReferral;
    [self.navigationController popViewControllerAnimated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    // RPN push notification
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    ffm.postSynchronizationEvents = YES;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)patientReferralViewControllerDidCancel:(WMPatientReferralViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FTPConfigurationDelegate

- (void)ftpConfigurationViewControllerDidFinish:(WMFTPConfigurationViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - RequestConsultDelegate

- (void)requestConsultViewControllerDidFinish:(WMRequestConsultViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IAPManager support

- (void)navigateToSharePdfReportView
{
    WMParticipant *participant = self.appDelegate.participant;
    WMTeam *team = participant.team;
    if (team) {
        [self navigateToPrintConfigureViewController];
    } else {
        // Do not navigate to Share Record view if no wounds or missing photos on wounds.
        if ([self hasAdequateWoundInformation]) {
            // not coming from navigation node so hardcoding
            NSString *productIdentifier = @"pdf report aggregator";
            __weak __typeof(&*self)weakSelf = self;
            BOOL proceed = [self presentIAPViewControllerForProductIdentifier:productIdentifier
                                                                 successBlock:^(SKPaymentTransaction *transaction) {
                                                                     [weakSelf navigateToPrintConfigureViewController];
                                                                 } withObject:self.selectPDFSectionFooterView];
            // self.shareButton.superview
            if (proceed) {
                [self navigateToPrintConfigureViewController];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Wound Information"
                                                                message:@"At least one wound must exist and all wounds must have photos in order to share documents."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void) navigateToPrintConfigureViewController {
    [self.navigationController pushViewController:self.printConfigureViewController animated:YES];
}

- (void)sharePdfReportFailureAlert:(NSString*)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Feature Unavailable"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)hasAdequateWoundInformation
{
    BOOL anyHavePhotos = NO;
    if (self.patient.woundCount > 0) {
        for (WMWound *wound in self.patient.wounds) {
            if (wound.woundPhotosCount > 0) {
                anyHavePhotos = YES;
                break;
            }
        }
    }
    return anyHavePhotos;
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // Print - should navigate to a print configure view controller ???
                    self.shareOption = SelectWoundAndActionShareOption_Print;
                    break;
                }
                case 1: {
                    // Email
                    self.shareOption = SelectWoundAndActionShareOption_Email;
                    break;
                }
                case 2: {
                    // FTP
                    self.shareOption = SelectWoundAndActionShareOption_FTP;
                    break;
                }
                case 3: {
                    // EMR
                    self.shareOption = SelectWoundAndActionShareOption_EMR;
                    break;
                }
                case 4: {
                    // iCloud
                    self.shareOption = SelectWoundAndActionShareOption_iCloud;
                    break;
                }
            }
            [self navigateToSharePdfReportView];
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // Consult
                    [self navigateToRequestConsult];
                    break;
                }
                case 1: {
                    // Referral
                    [self navigateToPatientReferral];
                    break;
                }
            }
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0.0;
    WMParticipant *participant = self.appDelegate.participant;
    if (participant.team) {
        return height;
    }
    // else
    switch (section) {
        case 0: {
            height = 20.0 + CGRectGetHeight(_creditStatus.frame) + 8.0 + CGRectGetHeight(_purchaseMoreTokensButton.frame) + 20.0;
            break;
        }
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    WMParticipant *participant = self.appDelegate.participant;
    if (participant.team) {
        return nil;
    }
    // else
    UIView *view = nil;
    switch (section) {
        case 0: {
            view = _selectPDFSectionFooterView;
            break;
        }
    }
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 3;
    if (section == 1) {
        count = (self.appDelegate.participant.team ? 2:1);
    }
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                    // Print
                    cell.imageView.image = [UIImage imageNamed:@"ui_print"];
                    cell.textLabel.text = @"Print";
                    break;
                }
                case 1: {
                    // Send Email
                    cell.imageView.image = [UIImage imageNamed:@"ui_email"];
                    cell.textLabel.text = @"Email with Attachment";
                    break;
                }
                case 2: {
                    // Send by sftp
                    cell.imageView.image = [UIImage imageNamed:@"ui_emed_record"];
                    cell.textLabel.text = @"Send by FTP";
                    break;
                }
                case 3: {
                    // Push to EMR
                    cell.imageView.image = [UIImage imageNamed:@"ui_emed_record"];
                    cell.textLabel.text = @"Push to EMR";
                    break;
                }
                case 4: {
                    // Share using iCloud
                    cell.imageView.image = [UIImage imageNamed:@"ui_icloud"];
                    cell.textLabel.text = @"Share using iCloud";
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // Consultant
                    cell.textLabel.text = @"Request Consult";
                    break;
                }
                case 1: {
                    // Referral
                    cell.textLabel.text = @"Refer to Team Member";
                    cell.detailTextLabel.text = _patientReferral.referree.name;
                    break;
                }
            }
            break;
        }
    }
}

@end
