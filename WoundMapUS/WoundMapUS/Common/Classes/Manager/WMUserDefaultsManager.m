//
//  WMUserDefaultsManager.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMUserDefaultsManager.h"
#import "WMNavigationTrack.h"
#import "WMUtilities.h"

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

#pragma mark - Patient

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

- (NSString *)lastPatientId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.lastPatientId"];
}

- (void)setLastPatientId:(NSString *)lastPatientId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:lastPatientId forKey:@"com.mobilehealthware.woundmap.lastPatientId"];
    [userDefaults synchronize];
}

- (NSString *)lastWoundIdOnDeviceForPatietId:(NSString *)patientId
{
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.mobilehealthware.woundmap.lastWoundIdOnDevice"];
    return [dictionary objectForKey:patientId];
}

- (void)setLastWoundIdOnDevice:(NSString *)lastWoundIdOnDevice forPatientId:(NSString *)patientId
{
    if ([patientId length] == 0) {
        DLog(@"%@ setLastWoundIdOnDevice:forPatientId - patientId is nil !!!", NSStringFromClass([self class]));
        return;
    }
    // else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[userDefaults dictionaryForKey:@"com.mobilehealthware.woundmap.lastWoundIdOnDevice"] mutableCopy];
    if (nil == dictionary) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    if (nil == lastWoundIdOnDevice) {
        [dictionary removeObjectForKey:lastWoundIdOnDevice];
    } else {
        [dictionary setValue:lastWoundIdOnDevice forKey:patientId];
    }
    [userDefaults setObject:dictionary forKey:@"com.mobilehealthware.woundmap.lastWoundIdOnDevice"];
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

#pragma mark - Clinical Care Setting/Stage of Care

- (WMNavigationTrack *)defaultNavigationTrack:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSString *navigationTrackId = self.defaultNavigationTrackId;
    WMNavigationTrack *navigationTrack = nil;
    if (navigationTrackId) {
        navigationTrack = [WMNavigationTrack trackForId:navigationTrackId
                                   managedObjectContext:managedObjectContext
                                        persistentStore:store];
    }
    return navigationTrack;
}

- (NSString *)defaultNavigationTrackId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.navigationTrackId"];
}

- (void)setDefaultNavigationTrackId:(NSString *)defaultNavigationTrackId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:defaultNavigationTrackId forKey:@"com.mobilehealthware.woundmap.navigationTrackId"];
    [userDefaults synchronize];
}

@end
