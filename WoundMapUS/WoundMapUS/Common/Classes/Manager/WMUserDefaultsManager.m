//
//  WMUserDefaultsManager.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMUserDefaultsManager.h"

NSDateFormatter * DOB_Formatter;

@implementation WMUserDefaultsManager

+ (WMUserDefaultsManager *)sharedInstance
{
    static WMUserDefaultsManager *_UserDefaultsManager = nil;
    if (nil == _UserDefaultsManager) {
        _UserDefaultsManager = [[WMUserDefaultsManager alloc] init];
        DOB_Formatter = [[NSDateFormatter alloc] init];
        [DOB_Formatter setDateStyle:NSDateFormatterMediumStyle];
        [DOB_Formatter setTimeStyle:NSDateFormatterNoStyle];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [_UserDefaultsManager updateToiCloud:note];
                                                      }];
    }
    return _UserDefaultsManager;
}

- (void)updateToiCloud:(NSNotification*)notificationObject
{
}


- (NSString *)lastTeamName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.lastTeamName"];
}

- (void)setLastTeamName:(NSString *)lastTeamName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:lastTeamName forKey:@"com.mobilehealthware.woundmap.lastTeamName"];
    [userDefaults synchronize];
}

- (NSDate *)lastDateOfBirth
{
    NSString *dateString = [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.lastDateOfBirth"];
    if (nil != dateString) {
        return [DOB_Formatter dateFromString:dateString];
    }
    // else
    return [NSDate dateWithTimeIntervalSinceNow:-60*60*24*365*50];
}

- (void)setLastDateOfBirth:(NSDate *)lastDateOfBirth
{
    if (nil == lastDateOfBirth) {
        lastDateOfBirth = [NSDate date];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[DOB_Formatter stringFromDate:lastDateOfBirth] forKey:@"com.mobilehealthware.woundmap.lastDateOfBirth"];
    [userDefaults synchronize];
}

@end
