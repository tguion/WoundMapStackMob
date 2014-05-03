//
//  WMTextViewTableViewCell.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMTextViewTableViewCell : UITableViewCell

@property (nonatomic) NSString *textViewText;

- (void)updateWithPrompt:(NSString *)prompt message:(NSString *)message;

@end
