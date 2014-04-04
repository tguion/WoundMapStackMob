//
//  WMChooseTrackViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMChooseTrackViewController, WMNavigationTrack;

@protocol ChooseTrackDelegate <NSObject>

@property (readonly, nonatomic) NSPredicate *navigationTrackPredicate;

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack;
- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController;

@end

@interface WMChooseTrackViewController : WMBaseViewController

@property (weak, nonatomic) id<ChooseTrackDelegate> delegate;

@end
