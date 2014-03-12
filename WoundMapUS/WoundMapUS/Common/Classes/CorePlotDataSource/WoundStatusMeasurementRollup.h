//
//  WoundStatusMeasurementRollup.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/6/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//
//  Data rollup for WCWoundMeasurementValues in WMWoundMeasurementGroup for key or for Braden Scale series

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface WoundStatusMeasurementRollup : NSObject

@property (strong, nonatomic) id xKey;
@property (strong, nonatomic) id yKey;

@property (strong, nonatomic) NSMutableArray *woundMeasurementGroupObjectIDs;

@property (strong, nonatomic) NSString *title;                  // WMWoundMeasurement.title, eg "Tissue in Wound"
@property (strong, nonatomic) NSString *key;                    // WMWoundMeasurement.title subcategory, eg "Granular(red)"
@property (strong, nonatomic) NSString *yUnit;                  // y-axis unit
@property (strong, nonatomic) NSMutableArray *data;             // array of dictionaries, with each dictionary has x and y value
@property (strong, nonatomic) NSMutableArray *dates;            // original dates for data
@property (strong, nonatomic) NSDate *dateMinimum;              // minimum date for data
@property (strong, nonatomic) NSDate *dateMaximum;              // maximum date for data
@property (nonatomic) NSInteger dayNumberMinimum;               // minimum x-value when looking at x-value as days from reference date
@property (nonatomic) NSInteger dayNumberMaximum;               // maximum x-value when looking at x-value as days from reference date
@property (strong, nonatomic) NSDecimalNumber *yMinimum;        // minimum y value
@property (strong, nonatomic) NSDecimalNumber *yMaximum;        // maximum y value
@property(readonly, nonatomic) NSInteger valueCount;            // number of values
@property(nonatomic) NSInteger sortRank;                        // sorting rank

- (void)addDataForDate:(NSDate *)date value:(NSDecimalNumber *)value woundMeasurementGroupObjectID:(NSManagedObjectID *)objectID;
- (void)updateDataForReferenceDateDayNumber:(NSInteger)referenceDayNumber;

- (NSDate *)dateForDayNumber:(NSInteger)dayNumber;

@end
