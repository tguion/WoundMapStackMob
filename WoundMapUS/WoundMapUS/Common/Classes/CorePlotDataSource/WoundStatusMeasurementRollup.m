//
//  WoundStatusMeasurementRollup.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/6/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WoundStatusMeasurementRollup.h"
#import "WMUtilities.h"

@interface WoundStatusMeasurementRollup ()
@property (nonatomic, getter=isUpdatedForReferenceDate) BOOL updatedForReferenceDateFlag;
@end

@implementation WoundStatusMeasurementRollup

@synthesize woundMeasurementGroupObjectIDs=_woundMeasurementGroupObjectIDs;
@synthesize title=_title, key=_key, yUnit=_yUnit, data=_data, dates=_dates, dateMinimum=_dateMinimum, dateMaximum=_dateMaximum, yMinimum=_yMinimum, yMaximum=_yMaximum;
@synthesize dayNumberMinimum=_dayCountMinimum, dayNumberMaximum=_dayCountMaximum;
@synthesize sortRank=_sortRank;
@dynamic valueCount;
@synthesize xKey=_xKey, yKey=_yKey, updatedForReferenceDateFlag=_updatedForReferenceDateFlag;

- (NSString *)description
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.valueCount];
    for (NSDictionary *dictionary in self.data) {
        [array addObject:[NSString stringWithFormat:@"(%@,%@)", [dictionary objectForKey:self.xKey], [dictionary objectForKey:self.yKey]]];
    }
    NSString *xyData = [array componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"%@: data:%@", [super description], xyData];
}

- (id)xKey
{
    if (nil == _xKey) {
        _xKey = [NSNumber numberWithInt:CPTScatterPlotFieldX];
    }
    return _xKey;
}

- (id)yKey
{
    if (nil == _yKey) {
        _yKey = [NSNumber numberWithInt:CPTScatterPlotFieldY];
    }
    return _yKey;
}

- (id)init
{
    if (self = [super init]) {
        _data = [[NSMutableArray alloc] initWithCapacity:32];
        _dates = [[NSMutableArray alloc] initWithCapacity:32];
        _woundMeasurementGroupObjectIDs = [[NSMutableArray alloc] initWithCapacity:32];
    }
    return self;
}

- (NSInteger)valueCount
{
    return [_data count];
}

- (void)addDataForDate:(NSDate *)date value:(NSDecimalNumber *)value woundMeasurementGroupObjectID:(NSManagedObjectID *)objectID
{
    [_dates addObject:date];
    if (nil != objectID) {
        [_woundMeasurementGroupObjectIDs addObject:objectID];
    }
    date = [WMUtilities roundDateToBeginningOfDay:date];
    NSInteger dayNumber = [date timeIntervalSinceReferenceDate]/kOneDayTimeInterval;
    [self.data addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:dayNumber], self.xKey,
                          value, self.yKey,
                          nil]];
    if (0 == _dayCountMinimum || dayNumber < _dayCountMinimum) {
        _dayCountMinimum = dayNumber;
    }
    if (0 == _dayCountMaximum || dayNumber > _dayCountMaximum) {
        _dayCountMaximum = dayNumber;
    }
    if (nil == _dateMinimum || [date compare:_dateMinimum] == NSOrderedAscending) {
        _dateMinimum = date;
    }
    if (nil == _dateMaximum || [date compare:_dateMaximum] == NSOrderedDescending) {
        _dateMaximum = date;
    }
    if (nil == _yMinimum || [value floatValue] < [_yMinimum floatValue]) {
        _yMinimum = value;
    }
    if (nil == _yMaximum || [value floatValue] > [_yMaximum floatValue]) {
        _yMaximum = value;
    }
}

// adjust dayNumber to be relative to referenceDayNumber
- (void)updateDataForReferenceDateDayNumber:(NSInteger)referenceDayNumber
{
    if (self.isUpdatedForReferenceDate) {
        return;
    }
    // else
    self.updatedForReferenceDateFlag = YES;
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:self.valueCount];
    for (NSDictionary *dictionary in self.data) {
        NSNumber *dayNumber = [dictionary objectForKey:self.xKey];
        dayNumber = [NSNumber numberWithInt:([dayNumber intValue] - referenceDayNumber)];
        id value = [dictionary objectForKey:self.yKey];
        [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                         dayNumber, self.xKey,
                         value, self.yKey,
                         nil]];
    }
    self.data = data;
}

- (NSDate *)dateForDayNumber:(NSInteger)dayNumber
{
    id dn0 = [NSNumber numberWithInt:dayNumber];
    NSInteger index = 0;
    BOOL found = NO;
    for (NSDictionary *dictionary in self.data) {
        id dn = [dictionary objectForKey:self.xKey];
        if ([dn isEqual:dn0]) {
            found = YES;
            break;
        }
        // else
        ++index;
    }
    return (found ? [self.dates objectAtIndex:index]:nil);
}

@end
