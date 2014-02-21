//
//  WMIdEditorViewController.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMIdEditorViewController, WMId;

@protocol idEditorViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)idEditorViewController:(WMIdEditorViewController *)viewController didEditId:(WMId *)anId;
- (void)idEditorViewControllerDidCancel:(WMIdEditorViewController *)viewController;

@end

@interface WMIdEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<idEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMId *anId;

@end
