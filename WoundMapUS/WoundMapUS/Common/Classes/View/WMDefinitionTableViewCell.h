//
//  WMDefinitionTableViewCell.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/19/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMDefinition;

@interface WMDefinitionTableViewCell : APTableViewCell

@property (strong, nonatomic) WMDefinition *definition;
@property (nonatomic) BOOL drawFullDescription;

+ (CGFloat)heightThatFitsDefinition:(WMDefinition *)definition fullDescription:(BOOL)fullDescription width:(CGFloat)width;

@end
