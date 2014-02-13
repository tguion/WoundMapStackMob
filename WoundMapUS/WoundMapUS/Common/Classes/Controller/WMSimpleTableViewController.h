//
//  WMSimpleTableViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/22/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSimpleTableViewController;

@protocol SimpleTableViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSString *navigationTitle;
@property (readonly, nonatomic) NSArray *valuesForDisplay;
@property (readonly, nonatomic) NSArray *selectedValuesForDisplay;

- (void)simpleTableViewController:(WMSimpleTableViewController *)simpleTableViewController didSelectValues:(NSArray *)selectedValues;
- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)simpleTableViewController;

@end

@interface WMSimpleTableViewController : WMBaseViewController

@property (weak, nonatomic) id<SimpleTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *values;              // values to display in cell
@property (strong, nonatomic) id referenceObject;
@property (strong, nonatomic) NSMutableSet *selectedValues;
@property (nonatomic) BOOL allowMultipleSelection;

@end
