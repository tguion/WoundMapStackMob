//
//  WMCreateAccountViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMCreateAccountViewController;
@class WMParticipant;

@protocol CreateAccountDelegate <NSObject>

- (void)createAccountViewController:(WMCreateAccountViewController *)viewController didCreateParticipant:(WMParticipant *)participant;
- (void)createAccountViewControllerDidCancel:(WMCreateAccountViewController *)viewController;

@end

@interface WMCreateAccountViewController : WMBaseViewController

@property (weak, nonatomic) id<CreateAccountDelegate> delegate;

@end
