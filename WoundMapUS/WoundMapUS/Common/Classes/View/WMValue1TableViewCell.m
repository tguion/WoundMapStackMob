//
//  WMValue1TableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMValue1TableViewCell.h"

@implementation WMValue1TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // ignore the style argument, use our own to override
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // If you need any further customization
    }
    return self;
}

@end
