//
//  WMIAPProductTextTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@interface WMIAPProductTextTableViewCell : APTableViewCell

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDictionary *textAttributes;
@property (nonatomic) CGFloat verticalMargin;

@end
