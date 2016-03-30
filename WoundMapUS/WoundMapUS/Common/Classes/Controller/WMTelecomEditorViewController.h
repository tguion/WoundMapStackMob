//
//  WMTelecomEditorViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMTelecomEditorViewController, WMTelecom;

@protocol TelecomEditorViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)telecomEditorViewController:(WMTelecomEditorViewController *)viewController didEditTelecom:(WMTelecom *)telecom;
- (void)telecomEditorViewControllerDidCancel:(WMTelecomEditorViewController *)viewController;

@end

@interface WMTelecomEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<TelecomEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMTelecom *telecom;

@end
