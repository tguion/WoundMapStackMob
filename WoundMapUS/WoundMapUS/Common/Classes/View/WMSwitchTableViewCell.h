//
//  WMSwitchTableViewCell.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSwitchTableViewCell : UITableViewCell

- (void)updateWithLabelText:(NSString *)labelText value:(BOOL)value target:(id)target action:(SEL)action tag:(NSInteger)tag;

@end
