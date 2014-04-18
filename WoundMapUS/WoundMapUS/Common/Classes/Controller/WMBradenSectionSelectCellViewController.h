//
//  WMBradenSectionSelectCellViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMBradenSection, WMBradenCell, WMBradenSectionSelectCellViewController;

@protocol BradenCellSelectionDelegate <NSObject>

- (void)controller:(WMBradenSectionSelectCellViewController *)viewController didSelectBradenCell:(WMBradenCell *)bradenCell;

@end

@interface WMBradenSectionSelectCellViewController : WMBaseViewController

@property (weak, nonatomic) id<BradenCellSelectionDelegate> delegate;

@property (strong, nonatomic) WMBradenSection *bradenSection;
@property (nonatomic) BOOL newBradenScaleFlag;
@property (strong, nonatomic) WMBradenCell *selectedBradenCell;

@end
