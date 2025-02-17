//
//  WMIAPProductOptionTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMValue1TableViewCell.h"

@class IAPProduct;

@interface WMIAPProductOptionTableViewCell : WMValue1TableViewCell

@property (strong, nonatomic) IAPProduct *iapProduct;
@property (nonatomic) BOOL selectedFlag;

+ (CGFloat) productOptionTitleTextHeight:(IAPProduct *)iapProduct
                         priceAttributes:(NSDictionary *)priceAttributes
                          textAttributes:(NSDictionary *)textAttributes
                               tableView:(UITableView *)tableView;

+ (NSDictionary *) titleAttributes;
+ (NSDictionary *)priceAttributes;

@end
