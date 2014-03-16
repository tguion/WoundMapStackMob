//
//  WMSignInViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSignInViewController;
@class WMParticipant;

@protocol SignInViewControllerDelegate <NSObject>

- (void)signInViewController:(WMSignInViewController *)viewController didSignInParticipant:(WMParticipant *)participant;
- (void)signInViewControllerDidCancel:(WMSignInViewController *)viewController;

@end

@interface WMSignInViewController : WMBaseViewController

@property (weak, nonatomic) id<SignInViewControllerDelegate> delegate;

@end
