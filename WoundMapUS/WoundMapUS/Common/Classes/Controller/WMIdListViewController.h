//
//  WMIdListViewController
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMIdListViewController;

@protocol IdListViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, nonatomic) id<idSource> idSource;
@property (readonly, nonatomic) BOOL persistRootAsDefault;

- (void)idListViewControllerDidFinish:(WMIdListViewController *)viewController;
- (void)idListViewControllerDidCancel:(WMIdListViewController *)viewController;

@end

@interface WMIdListViewController : WMBaseViewController

@property (weak, nonatomic) id<IdListViewControllerDelegate> delegate;

@end
