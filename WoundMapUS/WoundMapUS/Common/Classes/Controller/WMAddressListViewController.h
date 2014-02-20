//
//  WMAddressListViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMAddressListViewController;

@protocol AddressListViewControllerDelegate <NSObject>

@property (readonly, nonatomic) id<AddressSource> source;

- (void)addressListViewControllerDidFinish:(WMAddressListViewController *)viewController;
- (void)addressListViewControllerDidCancel:(WMAddressListViewController *)viewController;

@end

@interface WMAddressListViewController : WMBaseViewController

@property (weak, nonatomic) id<AddressListViewControllerDelegate> delegate;

@end
