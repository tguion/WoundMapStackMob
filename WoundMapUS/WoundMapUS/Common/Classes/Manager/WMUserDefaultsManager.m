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

- (NSString *)lastWoundFFURLOnDeviceForPatientFFURL:(NSString *)ffUrl
{
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.mobilehealthware.woundmap.lastWoundFFURLOnDevice"];
    return [dictionary objectForKey:ffUrl];
}

- (void)setLastWoundFFURLOnDevice:(NSString *)lastWoundFFURLOnDevice forPatientFFURL:(NSString *)ffUrl
{
    if ([ffUrl length] == 0) {
        DLog(@"%@ setLastWoundIdOnDevice:forPatientId - patient.ffUrl is nil !!!", NSStringFromClass([self class]));
        return;
    }
    // else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[userDefaults dictionaryForKey:@"com.mobilehealthware.woundmap.lastWoundFFURLOnDevice"] mutableCopy];
    if (nil == dictionary) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    if (nil == lastWoundFFURLOnDevice) {
        [dictionary removeObjectForKey:lastWoundFFURLOnDevice];
    } else {
        [dictionary setValue:lastWoundFFURLOnDevice forKey:ffUrl];
    }
    [userDefaults setObject:dictionary forKey:@"com.mobilehealthware.woundmap.lastWoundFFURLOnDevice"];
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
    NSString *defaultNavigationTrackFFURL = self.defaultNavigationTrackFFURL;
    WMNavigationTrack *navigationTrack = nil;
    if (defaultNavigationTrackFFURL) {
        navigationTrack = [WMNavigationTrack trackForFFURL:defaultNavigationTrackFFURL
                                      managedObjectContext:managedObjectContext
                                           persistentStore:store];
    }
    return navigationTrack;
}

- (NSString *)defaultNavigationTrackFFURL
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.navigationTrackFFURL"];
}

- (void)setDefaultNavigationTrackFFURL:(NSString *)defaultNavigationTrackFFURL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:defaultNavigationTrackFFURL forKey:@"com.mobilehealthware.woundmap.navigationTrackFFURL"];
    [userDefaults synchronize];
}

#pragma mark - Email

- (NSString *)encryptionPassword
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.encryptionPassword"];
}

- (void)setEncryptionPassword:(NSString *)encryptionPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:encryptionPassword forKey:@"com.mobilehealthware.woundmap.encryptionPassword"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFtoRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFtoRecipients"];
}

- (void)setEmailPDFtoRecipients:(NSArray *)emailPDFtoRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:emailPDFtoRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFtoRecipients"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFccRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFccRecipients"];
}

- (void)setEmailPDFccRecipients:(NSArray *)emailPDFccRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:emailPDFccRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFccRecipients"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFbccRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFbccRecipients"];
}

- (void)setEmailPDFbccRecipients:(NSArray *)emailPDFbccRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:emailPDFbccRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFbccRecipients"];
    [userDefaults synchronize];
}

- (NSString *)pdfHeaderPrefix
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.pdfHeaderPrefix"];
}

- (void)setPdfHeaderPrefix:(NSString *)pdfHeaderPrefix
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:pdfHeaderPrefix forKey:@"com.mobilehealthware.woundmap.pdfHeaderPrefix"];
    [userDefaults synchronize];
}


@end
