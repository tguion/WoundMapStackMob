//
//  WMChooseStageViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMChooseStageViewController;
@class WMNavigationTrack, WMNavigationStage;

@protocol ChooseStageDelegate <NSObject>

@property (readonly, nonatomic) WMNavigationTrack *navigationTrack;
@property (readonly, nonatomic) WMNavigationStage *navigationStage;

- (void)chooseStageViewController:(WMChooseStageViewController *)chooseStageViewController didSelectNavigationStage:(WMNavigationStage *)navigationStage;
- (void)chooseStageViewControllerDidCancel:(WMChooseStageViewController *)chooseStageViewController;

@end

@interface WMChooseStageViewController : WMBaseViewController

@property (weak, nonatomic) id<ChooseStageDelegate> delegate;

@end
