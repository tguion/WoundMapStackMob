//
//  WMPrintConfigureViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/24/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMSelectWoundPhotoViewController.h"

@class WMPrintConfigureViewController, PrintConfiguration;

@protocol PrintConfigureViewControllerDelegate <NSObject>

@property (readonly, nonatomic) BOOL shouldRequestPassword;
@property (readonly, nonatomic) BOOL hasRiskAssessment;
@property (readonly, nonatomic) BOOL hasSkinAssessment;
@property (readonly, nonatomic) BOOL hasCarePlan;

- (void)printConfigureViewController:(WMPrintConfigureViewController *)controller
 didConfigurePrintWithConfigureation:(PrintConfiguration *)configuration
                   fromBarButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)printConfigureViewControllerDidCancel:(WMPrintConfigureViewController *)controller;

@end

@interface WMPrintConfigureViewController : WMBaseViewController <SelectWoundPhotoViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id<PrintConfigureViewControllerDelegate> delegate;

@end
