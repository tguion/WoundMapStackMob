//
//  WMInstructionTableViewCell.h
//  WoundMAP
//
//  Created by Todd Guion on 11/18/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@interface WMInstructionTableViewCell : APTableViewCell

@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDictionary *titleAttributes;
@property (strong, nonatomic) NSDictionary *textAttributes;
@property (nonatomic) CGFloat verticalMargin;

+ (CGFloat)heightForTitle:(NSString *)title
                     text:(NSString *)text
          titleAttributes:(NSDictionary *)titleAttributes
           textAttributes:(NSDictionary *)textAttributes
                    width:(CGFloat)width
           verticalMargin:(CGFloat)verticalMargin;

@end
