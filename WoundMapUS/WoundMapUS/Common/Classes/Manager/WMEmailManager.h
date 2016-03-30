//
//  WMEmailManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

typedef void (^OnMailFinish)(MFMailComposeResult result, NSError* error);

@interface WMEmailManager : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) OnMailFinish onMailFinish;

+ (WMEmailManager *)sharedInstance;

-(void)displayComposerSheet:(UIViewController *)requestingViewController
                  attachPDF:(NSURL *)pdfURL
          passwordProtected:(BOOL)passwordProtected
               onMailFinish:(OnMailFinish)onMailFinish;

@end
