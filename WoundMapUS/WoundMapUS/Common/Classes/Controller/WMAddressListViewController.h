//
//  WMAddressListViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMAddressListViewController;

@protocol AddressListViewControllerDelegate <NSObject>

@property (readonly, nonatomic) id<AddressSource> addressSource;

- (void)addressListViewControllerDidFinish:(WMAddressListViewController *)viewController;
- (void)addressListViewControllerDidCancel:(WMAddressListViewController *)viewController;

@end

@interface WMAddressListViewController : WMBaseViewController

@property (weak, nonatomic) id<AddressListViewControllerDelegate> delegate;
@property (nonatomic) BOOL attemptAcquireFromBackEnd;

@end
