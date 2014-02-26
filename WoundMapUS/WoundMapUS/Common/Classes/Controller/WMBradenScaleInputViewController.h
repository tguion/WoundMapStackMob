//
//  WMBradenScaleInputViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/26/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMBradenScale, WMBradenSection;

@protocol BradenSectionCellDelegate <NSObject>

- (void)updateExpandedMapForBradenSection:(WMBradenSection *)bradenSection expanded:(BOOL)expanded;

@end

@interface WMBradenScaleInputViewController : WMBaseViewController

@property (weak, nonatomic) id<BradenSectionCellDelegate> delegate;

@property (strong, nonatomic) WMBradenScale *bradenScale;

@end
