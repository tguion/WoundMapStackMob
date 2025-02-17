//
//  WMUtilities.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/29/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define WM_ASSERT_MAIN_THREAD NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

extern NSTimeInterval kOneDayTimeInterval;

@interface WMUtilities : NSObject

+ (void)logError:(NSError *)error;
+ (BOOL)isBitSetForValue:(NSInteger)value atPosition:(NSInteger)position;
+ (NSInteger)updateBitForValue:(NSInteger)value atPosition:(NSInteger)position to:(BOOL)yesOrNo;

+ (UIBarButtonItem *)barButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar;
+ (NSInteger)indexOfBarButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar;
+ (void)insertBarButtonItem:(UIBarButtonItem *)barButtonItem inToolbar:(UIToolbar *)toolbar atIndex:(NSInteger)index;
+ (void)removeBarButtonItemWithTag:(NSInteger)tag inToolbar:(UIToolbar *)toolbar;

+ (NSDate *)roundDateToBeginningOfDay:(NSDate *)date;
+ (NSDate *)dateByAddingMonthToDate:(NSDate *)date;
+ (NSDate *)dateByAddingMonths:(NSInteger)numberMonths toDate:(NSDate *)date;
+ (NSDate *)dateByAddingDays:(NSInteger)numberDays toDate:(NSDate *)date;

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;

@end
