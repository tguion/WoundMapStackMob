//
//  WMAddressEditorViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMAddressEditorViewController, WMAddress;

@protocol AddressEditorViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)addressEditorViewController:(WMAddressEditorViewController *)viewController didEditAddress:(WMAddress *)address;
- (void)addressEditorViewControllerDidCancel:(WMAddressEditorViewController *)viewController;

@end

@interface WMAddressEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<AddressEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMAddress *address;

@end
