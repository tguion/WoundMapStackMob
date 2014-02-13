//
//  WMSignInViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMSimpleTableViewController.h"

@class WMSignInViewController;
@class WMParticipant;

@protocol SignInViewControllerDelegate <NSObject>

- (void)signInViewControllerWillAppear:(WMSignInViewController *)viewController;
- (void)signInViewControllerWillDisappear:(WMSignInViewController *)viewController;
- (void)signInViewController:(WMSignInViewController *)viewController didSignInParticipant:(WMParticipant *)participant;

@end

@interface WMSignInViewController : WMBaseViewController <SimpleTableViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) id<SignInViewControllerDelegate> delegate;

- (void)reset;

@end
