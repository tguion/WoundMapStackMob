//
//  WMIAPProductOptionTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMIAPProductOptionTableViewCell.h"
#import "IAPProduct+Custom.h"
#import "IAPBaseViewController.h"

@interface WMIAPProductOptionTableViewCell ()

@property (strong, nonatomic) NSDictionary *titleAttributes;
@property (strong, nonatomic) NSDictionary *priceAttributes;

@end

@implementation WMIAPProductOptionTableViewCell

- (NSDictionary *)titleAttributes
{
    if (nil == _titleAttributes) {
        _titleAttributes = [WMIAPProductOptionTableViewCell titleAttributes];
    }
    return _titleAttributes;
}

- (NSDictionary *)priceAttributes
{
    if (nil == _priceAttributes) {
        _priceAttributes = [WMIAPProductOptionTableViewCell priceAttributes];
    }
    return _priceAttributes;
}

- (void)setIapProduct:(IAPProduct *)iapProduct
{
    if (_iapProduct == iapProduct) {
        return;
    }
    // else
    [self willChangeValueForKey:@"iapProduct"];
    _iapProduct = iapProduct;
    [self didChangeValueForKey:@"iapProduct"];
    [self setNeedsDisplay];
//    self.textLabel.text = iapProduct.title;
    self.detailTextLabel.text = [NSNumberFormatter localizedStringFromNumber:iapProduct.price numberStyle:NSNumberFormatterCurrencyStyle];
}

- (void)setSelectedFlag:(BOOL)selectedFlag
{
    if (_selectedFlag == selectedFlag) {
        return;
    }
    // else
    [self willChangeValueForKey:@"xx"];
    _selectedFlag = selectedFlag;
    [self didChangeValueForKey:@"xx"];
    if (selectedFlag) {
        self.imageView.image = [UIImage imageNamed:@"ui_checkmark"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"ui_circle"];
    }
}

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    CGFloat minX = fmaxf(CGRectGetMaxX(self.imageView.frame) + 8.0, CGRectGetMinX(rect));
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat width = CGRectGetMaxX(rect) - minX;
    CGFloat height = CGRectGetHeight(rect);
    NSString *priceString = [NSNumberFormatter localizedStringFromNumber:_iapProduct.price numberStyle:NSNumberFormatterCurrencyStyle];
    CGSize priceTextSize = [priceString sizeWithAttributes:self.priceAttributes];
    // draw price
    CGRect aRect = CGRectMake(maxX - ceilf(priceTextSize.width + 2.0 * kIAPTextVerticalMargin), ceilf((height - priceTextSize.height)/2.0), ceilf(priceTextSize.width), ceilf(priceTextSize.height));
    [priceString drawInRect:aRect withAttributes:self.priceAttributes];
    // draw title
    UITableView *tableView = (UITableView *)self.superview.superview;
    CGFloat textHeight = [WMIAPProductOptionTableViewCell productOptionTitleTextHeight:_iapProduct
                                                                     priceAttributes:self.priceAttributes
                                                                      textAttributes:self.titleAttributes
                                                                           tableView:tableView];
    aRect = CGRectMake(minX, (height / 2) - (textHeight / 2) + kIAPTextVerticalMargin, width - ceilf(priceTextSize.width) - 4.0, ceilf(rect.size.height));
    [_iapProduct.title drawInRect:aRect withAttributes:self.titleAttributes];
}

+ (CGFloat) productOptionTitleTextHeight:(IAPProduct *)iapProduct
                         priceAttributes:(NSDictionary *)priceAttributes
                          textAttributes:(NSDictionary *)textAttributes
                               tableView:(UITableView *)tableView
{
    CGRect textRect = CGRectZero;
    NSString *priceString = [NSNumberFormatter localizedStringFromNumber:iapProduct.price numberStyle:NSNumberFormatterCurrencyStyle];
    CGSize priceTextSize = [priceString sizeWithAttributes:priceAttributes];
    
    CGFloat viewWidth = CGRectGetWidth(tableView.bounds) - tableView.separatorInset.left - priceTextSize.width;
    textRect = [iapProduct.title boundingRectWithSize:CGSizeMake(viewWidth, 5000.0)
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:textAttributes
                                    context:nil];
    CGFloat height = ceilf(textRect.size.height + 2.0 * kIAPTextVerticalMargin);
    return height;
}

+ (NSDictionary *)titleAttributes
{
    NSDictionary *titleAttributes;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIFont systemFontOfSize:15.0], NSFontAttributeName,
                        [UIColor blackColor], NSForegroundColorAttributeName,
                        paragraphStyle, NSParagraphStyleAttributeName,
                        nil];
    return titleAttributes;
}

+ (NSDictionary *)priceAttributes
{
    NSDictionary *priceAttributes;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    priceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIFont systemFontOfSize:15.0], NSFontAttributeName,
                        [UIColor greenColor], NSForegroundColorAttributeName,
                        paragraphStyle, NSParagraphStyleAttributeName,
                        nil];
    return priceAttributes;
}

@end
