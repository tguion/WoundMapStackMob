//
//  WMUtilities.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/29/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMUtilities.h"
#import "WMPatient.h"
#import "WCAppDelegate.h"

NSTimeInterval kOneDayTimeInterval = 60.0 * 60 * 24.0;

@implementation WMUtilities

#pragma mark - Log Utilities

+ (void)logError:(NSError *)error
{
    if (nil == error) {
        return;
    }
    // else
    DLog(@"*** ERROR ***: %@", [error localizedDescription]);
	NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
	if ([detailedErrors count]) {
		for (NSError *detailedError in detailedErrors) {
            DLog(@"  DetailedError: %@", [detailedError userInfo]);
		}
	} else {
        DLog(@"  %@", [error userInfo]);
	}
    // check for session time-out
    if ([error.domain isEqualToString:@"FatFractal"] && error.code == 401) {
        WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate handleFatFractalSignout];
    }
}

#pragma mark - Bit Utilities

+ (BOOL)isBitSetForValue:(NSInteger)value atPosition:(NSInteger)position
{
	return (value & (1 << position));
}

+ (NSInteger)updateBitForValue:(NSInteger)value atPosition:(NSInteger)position to:(BOOL)yesOrNo
{
	if (yesOrNo) {
		value |= (1 << position);
	} else {
		value &= ~(1 << position);
	}
	return value;
}

#pragma mark - UIToolbar Utilities

+ (UIBarButtonItem *)barButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %d", tag];
    return (UIBarButtonItem *)[[toolbar.items filteredArrayUsingPredicate:predicate] lastObject];
}

+ (NSInteger)indexOfBarButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar
{
    if (nil == toolbar) {
        return NSNotFound;
    }
    // else
    NSInteger index = 0;
    for (UIBarButtonItem *barButtonItem in toolbar.items) {
        if (barButtonItem.tag == tag) {
            return index;
        }
        // else
        ++index;
    }
    // else
    return NSNotFound;
}

+ (void)insertBarButtonItem:(UIBarButtonItem *)barButtonItem inToolbar:(UIToolbar *)toolbar atIndex:(NSInteger)index
{
	NSMutableArray *items = [toolbar.items mutableCopy];
	[items insertObject:barButtonItem atIndex:index];
	[toolbar setItems:items];
}

+ (void)removeBarButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar
{
	NSMutableArray *items = [toolbar.items mutableCopy];
	NSInteger index = [self indexOfBarButtonItemWithTag:tag inToolbar:toolbar];
	if (index == NSNotFound) {
		return;
	}
	// else
	[items removeObjectAtIndex:index];
	[toolbar setItems:items];
}

#pragma mark - Date Utilities

+ (NSDate *)roundDateToBeginningOfDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit) fromDate:date];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *roundedDownDate = [calendar dateByAddingComponents:components toDate:date options:0];
    return roundedDownDate;
}

+ (NSDate *)dateByAddingMonthToDate:(NSDate *)date
{
    return [self dateByAddingMonths:1 toDate:date];
}

+ (NSDate *)dateByAddingMonths:(NSInteger)numberMonths toDate:(NSDate *)date
{
    if (nil == date) {
        date = [NSDate date];
    }
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:numberMonths];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:date options:0];
}

+ (NSDate *)dateByAddingDays:(NSInteger)numberDays toDate:(NSDate *)date
{
    if (nil == date) {
        date = [NSDate date];
    }
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:numberDays];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:date options:0];
}

#pragma mark - Validation

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
