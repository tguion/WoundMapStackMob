//
//  WMTelecomListViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMTelecomListViewController;

@protocol TelecomListViewControllerDelegate <NSObject>

@property (readonly, nonatomic) id<TelecomSource> source;
@property (readonly, nonatomic) NSString *relationshipKey;                      // person, organization, ..

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)telecomListViewControllerDidFinish:(WMTelecomListViewController *)viewController;
- (void)telecomListViewControllerDidCancel:(WMTelecomListViewController *)viewController;

@end

@interface WMTelecomListViewController : WMBaseViewController

@property (weak, nonatomic) id<TelecomListViewControllerDelegate> delegate;

@end
