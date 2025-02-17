//
//  WMPersonEditorViewController.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/17/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMPersonEditorViewController, WMPerson;

@protocol PersonEditorViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMPerson *person;

- (void)personEditorViewController:(WMPersonEditorViewController *)viewController didEditPerson:(WMPerson *)person;
- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController;

@end

@interface WMPersonEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<PersonEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMPerson *person;

@end
