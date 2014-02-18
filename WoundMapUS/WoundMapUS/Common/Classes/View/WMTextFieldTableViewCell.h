//
//  WMTextFieldTableViewCell.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMTextFieldTableViewCell : UITableViewCell

@property (readonly, nonatomic) UITextField *textField;

- (void)updateWithLabelText:(NSString *)labelText valueText:(NSString *)valueText valuePrompt:(NSString *)promptText;

@end
