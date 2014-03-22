//
//  WMBradenCellTableViewCell.h
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"
#import "WMBradenScaleInputViewController.h"

@class WMBradenSection;

@interface WMBradenCellTableViewCell : APTableViewCell

@property (strong, nonatomic) WMBradenSection *bradenSection;
@property (weak, nonatomic) id<BradenSectionCellDelegate> delegate;
@property (nonatomic) BOOL expandedFlag;

+ (CGFloat)recommendedHeightForBradenSection:(WMBradenSection *)bradenSection expanded:(BOOL)expanded forWidth:(CGFloat)width;

@end
