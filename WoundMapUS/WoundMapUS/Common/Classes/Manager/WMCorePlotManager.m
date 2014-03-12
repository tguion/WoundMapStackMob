//
//  WMCorePlotManager.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/3/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMCorePlotManager.h"
#import "CPTGraphHostingView.h"
#import "WMWound.h"
#import "WMBradenScale.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WoundStatusMeasurementRollup.h"
#import "WoundStatusMeasurementPlotDataSource.h"

NSInteger kXOffset = 0; // emperical offset to place data to right of y-axis

@interface WMCorePlotManager (PrivateMethods)

- (void)updateRollupForBradenScalesForWountStatusMeasurementTitle2RollupByKeyMapMap:(NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMap
                                                               managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation WMCorePlotManager (PrivateMethods)

- (void)updateRollupForBradenScalesForWountStatusMeasurementTitle2RollupByKeyMapMap:(NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMap
                                                               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *bradenScales = [WMBradenScale sortedScoredBradenScales:managedObjectContext];
    WoundStatusMeasurementRollup *rollup = [[WoundStatusMeasurementRollup alloc] init];
    rollup.title = kBradenScaleTitle;
    rollup.key = kBradenScaleTitle;
    rollup.sortRank = 0;
    NSMutableDictionary *key2Rollup = [[NSMutableDictionary alloc] initWithCapacity:4];
    [key2Rollup setObject:rollup forKey:kBradenScaleTitle];
    for (WMBradenScale *bradenScale in bradenScales) {
        [rollup addDataForDate:bradenScale.dateCreated value:(NSDecimalNumber *)[NSDecimalNumber numberWithFloat:[bradenScale.score floatValue]] woundMeasurementGroupObjectID:nil];
    }
    // here we have array of all dates (dates) , and a map of key->rollup array for e.g. Dimensions
    [wountStatusMeasurementTitle2RollupByKeyMapMap setObject:key2Rollup forKey:kBradenScaleTitle];
}


@end

@implementation WMCorePlotManager

#pragma mark - Initialization

+ (WMCorePlotManager *)sharedInstance
{
    static WMCorePlotManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMCorePlotManager alloc] init];
    });
    return SharedInstance;
}

#pragma mark - Plot Helper Methods

// map for WMWoundMeasurement.title to map of WMWoundMeasurement.title (measurement child) -> WoundStatusMeasurementRollup instances
- (NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMapForWound:(WMWound *)wound graphableMeasurementTitles:(NSArray *)graphableMeasurementTitles
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSMutableDictionary *wountStatusMeasurementTitle2RollupByKeyMapMap = [[NSMutableDictionary alloc] initWithCapacity:32];
    // collect all WMWoundMeasurementGroup instance for self.wound, and collect (date,value) for each WMWoundMeasurementValue
    NSArray *sortedWoundMeasurementGroups = wound.sortedWoundMeasurements;
    for (NSString *title in graphableMeasurementTitles) {
        // check for Braden Scale, which is not an WMWoundMeasurement
        if ([title isEqualToString:kBradenScaleTitle]) {
            // delete any incomplete and closed
            [WMBradenScale deleteIncompleteClosedBradenScales:wound.managedObjectContext];
            // rollup the WMBradenScale instances
            [self updateRollupForBradenScalesForWountStatusMeasurementTitle2RollupByKeyMapMap:(NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMap
                                                                         managedObjectContext:[wound managedObjectContext]];
        } else {
            NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:32];
            NSMutableDictionary *key2Rollup = [[NSMutableDictionary alloc] initWithCapacity:32];
            // build dates array
            for (WMWoundMeasurementGroup *woundMeasurementGroup in sortedWoundMeasurementGroups) {
                [dates addObject:woundMeasurementGroup.dateCreated];
            }
            // iterate over all sortedWoundMeasurementGroups and add data for each measurement
            for (WMWoundMeasurementGroup *woundMeasurementGroup in sortedWoundMeasurementGroups) {
                WMWoundMeasurement *woundMeasurement = [WMWoundMeasurement woundMeasureForTitle:title
                                                                         parentWoundMeasurement:nil
                                                                                         create:NO
                                                                           managedObjectContext:managedObjectContext
                                                                                persistentStore:nil];
                NSInteger index = 0;
                if (woundMeasurement.hasChildrenWoundMeasurements) {
                    for (WMWoundMeasurement *childWoundMeasurement in woundMeasurement.childrenMeasurements) {
                        NSDate *date = woundMeasurementGroup.dateCreated;
                        NSString *key = childWoundMeasurement.title;
                        WMWoundMeasurementValue *woundMeasurementValue = [woundMeasurementGroup woundMeasurementValueForWoundMeasurement:childWoundMeasurement
                                                                                                                                  create:NO
                                                                                                                                   value:nil
                                                                                                                    managedObjectContext:managedObjectContext];
                        NSDecimalNumber *value = nil;
                        if (nil != woundMeasurementValue && [woundMeasurementValue.value length] > 0) {
                            value = [NSDecimalNumber decimalNumberWithString:woundMeasurementValue.value];
                        }
                        WoundStatusMeasurementRollup *rollup = (WoundStatusMeasurementRollup *)[key2Rollup objectForKey:key];
                        if (nil == rollup) {
                            rollup = [[WoundStatusMeasurementRollup alloc] init];
                            rollup.title = title;
                            rollup.key = key;
                            rollup.yUnit = childWoundMeasurement.unit;
                            rollup.sortRank = index++;
                            [key2Rollup setObject:rollup forKey:key];
                        }
                        if (nil != value) {
                            [rollup addDataForDate:date value:value woundMeasurementGroupObjectID:[woundMeasurementGroup objectID]];
                        }
                    }
                } else {
                    // e.g. wound pain
                    NSDate *date = woundMeasurementGroup.dateCreated;
                    NSString *key = woundMeasurement.title;
                    WMWoundMeasurementValue *woundMeasurementValue = [woundMeasurementGroup woundMeasurementValueForWoundMeasurement:woundMeasurement
                                                                                                                              create:NO
                                                                                                                               value:nil
                                                                                                                managedObjectContext:managedObjectContext];
                    NSDecimalNumber *value = nil;
                    if (nil != woundMeasurementValue && [woundMeasurementValue.value length] > 0) {
                        value = [NSDecimalNumber decimalNumberWithString:woundMeasurementValue.value];
                    }
                    WoundStatusMeasurementRollup *rollup = (WoundStatusMeasurementRollup *)[key2Rollup objectForKey:key];
                    if (nil == rollup) {
                        rollup = [[WoundStatusMeasurementRollup alloc] init];
                        rollup.title = title;
                        rollup.key = key;
                        rollup.yUnit = woundMeasurement.unit;
                        rollup.sortRank = index++;
                        [key2Rollup setObject:rollup forKey:key];
                    }
                    if (nil != value) {
                        [rollup addDataForDate:date value:value woundMeasurementGroupObjectID:[woundMeasurementGroup objectID]];
                    }
                }
            }
            // here we have array of all dates (dates) , and a map of key->rollup array for e.g. Dimensions
            [wountStatusMeasurementTitle2RollupByKeyMapMap setObject:key2Rollup forKey:title];
        }
    }
    return wountStatusMeasurementTitle2RollupByKeyMapMap;
}

@end