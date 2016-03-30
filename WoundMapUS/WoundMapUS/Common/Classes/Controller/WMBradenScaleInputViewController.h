//
//  WMBradenScaleInputViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/26/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMBradenScaleViewController.h"
#import "WMBradenSectionSelectCellViewController.h"

@class WMBradenScale, WMBradenSection;

@protocol BradenSectionCellDelegate <NSObject>

- (void)updateExpandedMapForBradenSection:(WMBradenSection *)bradenSection expanded:(BOOL)expanded;

@end

@interface WMBradenScaleInputViewController : WMBaseViewController

@property (weak, nonatomic) id<BradenScaleInputDelegate> delegate;

@property (strong, nonatomic) WMBradenScale *bradenScale;
@property (nonatomic) BOOL newBradenScaleFlag;

@end
