//
//  WMEmailManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMEmailManager.h"
#import "WMUserDefaultsManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMEmailManager ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMUserDefaultsManager *userDefaultsManager;
@property (strong, nonatomic) UIViewController *requestingViewController;
@end

@implementation WMEmailManager

#pragma mark - Initialization

+ (WMEmailManager *)sharedInstance
{
    static WMEmailManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMEmailManager alloc] init];
    });
    return SharedInstance;
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMUserDefaultsManager *)userDefaultsManager
{
    return [WMUserDefaultsManager sharedInstance];
}

-(void)displayComposerSheet:(UIViewController *)requestingViewController
                  attachPDF:(NSURL *)pdfURL
          passwordProtected:(BOOL)passwordProtected
               onMailFinish:(OnMailFinish)onMailFinish
{
    _requestingViewController = requestingViewController;
    _onMailFinish = onMailFinish;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    // may return nil if no email account is set up
    if (nil == picker) {
        [self mailComposeController:nil didFinishWithResult:MFMailComposeResultFailed error:nil];
        return;
    }
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Hello from WoundMap!"];
    
    // Set up the recipients.
    NSArray *toRecipients = self.userDefaultsManager.emailPDFtoRecipients;
    NSArray *ccRecipients = self.userDefaultsManager.emailPDFccRecipients;
    NSArray *bccRecipients = self.userDefaultsManager.emailPDFbccRecipients;
    [picker setToRecipients:toRecipients];
    [picker setCcRecipients:ccRecipients];
    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email.
    NSData *myData = [NSData dataWithContentsOfURL:pdfURL];
    [picker addAttachmentData:myData mimeType:@"application/pdf" fileName:pdfURL.lastPathComponent];
    
    // Fill out the email body text.
    NSString *emailBody = @"See attached patient report.";
    if (passwordProtected) {
        emailBody = [emailBody stringByAppendingString:@" (The PDF is password protected. Contact me with appropriate security precautions to get the password.)"];
    }
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [requestingViewController presentViewController:picker animated:YES completion:^{
        // what to do when email is showing
        DLog(@"EmailManager displayComposerSheet completion block");    // jms 7/17/2013
    }];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	// Notifies users about errors associated with the interface
    NSString *message = nil;
	switch (result) {
		case MFMailComposeResultCancelled:
            message = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
            message = @"Result: saved";
			break;
		case MFMailComposeResultSent:
            message = @"Result: sent";
			break;
		case MFMailComposeResultFailed: {
            message = @"Result: failed";
            if (nil != error) {
                message = [error localizedDescription];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Failed"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
			break;
        }
		default:
            message = @"Result: not sent";
			break;
	}
    [_requestingViewController dismissViewControllerAnimated:YES completion:^{
        // what to do after complete email
        DLog(@"Email %@", message);
    }];
    _onMailFinish(result, error);
    _onMailFinish = nil;
}

@end
