//
//  APTableViewCell.h
//
//  Created by Todd Guion on 5/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APTableViewCell : UITableViewCell

@property (weak, nonatomic) UIView *customContentView;
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
+ (Class)contentViewClass;

- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier 
				class:(Class)contentViewClass;

- (void)drawContentView:(CGRect)r; // subclasses should implement

@end

@interface APTableViewGradientCell : APTableViewCell
{
	
}

@end

@interface APTableViewCellView : UIView

@property (weak, nonatomic)	APTableViewCell *parentCell;

- (id)initWithParent:(APTableViewCell *)parent;

@end
