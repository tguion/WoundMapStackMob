//
//  WCMasterViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "StackMob.h"

@class WCDetailViewController;

@interface WCMasterViewController : WMBaseViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) WCDetailViewController *detailViewController;

@end
