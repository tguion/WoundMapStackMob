//
//  WMBradenCellSelectTableViewCell.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "APTableViewCell.h"

@class WMBradenCell;

@interface WMBradenCellSelectTableViewCell : APTableViewCell

@property (strong, nonatomic) WMBradenCell *bradenCell;

+ (CGFloat)recommendedHeightForBradenCell:(WMBradenCell *)bradenCell forWidth:(CGFloat)width;

@end
