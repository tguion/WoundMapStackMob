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

#pragma mark - Pariticipant

- (NSString *)lastUserName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.lastUserName"];
}

- (void)setLastUserName:(NSString *)lastUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastUserName forKey:@"com.mobilehealthware.woundmap.lastUserName"];
    [userDefaults synchronize];
}

#pragma mark - Patient

- (NSString *)lastTeamName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.lastTeamName"];
}

- (void)setLastTeamName:(NSString *)lastTeamName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastTeamName forKey:@"com.mobilehealthware.woundmap.lastTeamName"];
    [userDefaults synchronize];
}

- (NSString *)lastPatientFFURLForUserGUID:(NSString *)guid
{
    NSDictionary *userGUID2PatientFFURLMap = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.mobilehealthware.woundmap.lastPatientId"];
    return userGUID2PatientFFURLMap[guid];
}

- (void)setLastPatientFFURL:(NSString *)patientFFURL forUserGUID:(NSString *)guid
{
    NSMutableDictionary *userGUID2PatientFFURLMap = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.mobilehealthware.woundmap.lastPatientId"] mutableCopy];
    if (nil == userGUID2PatientFFURLMap) {
        userGUID2PatientFFURLMap = [[NSMutableDictionary alloc] init];
    }
    userGUID2PatientFFURLMap[guid] = patientFFURL;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userGUID2PatientFFURLMap forKey:@"com.mobilehealthware.woundmap.lastPatientId"];
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
        [dictionary removeObjectForKey:ffUrl];
    } else {
        [dictionary setObject:lastWoundFFURLOnDevice forKey:ffUrl];
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
    [userDefaults setObject:[DOB_Formatter stringFromDate:lastDateOfBirth] forKey:@"com.mobilehealthware.woundmap.lastDateOfBirth"];
    [userDefaults synchronize];
}

- (NSString *)woundPositionTermKey
{
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.woundPositionTermKey"];
    if (nil == string) {
        string = @"title";
        self.woundPositionTermKey = string;
    }
    return string;
}

- (void)setWoundPositionTermKey:(NSString *)woundPositionTermKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:woundPositionTermKey forKey:@"com.mobilehealthware.woundmap.woundPositionTermKey"];
    [userDefaults synchronize];
}

- (NSString *)defaultIdRoot
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.defaultIdRoot"];
}

- (void)setDefaultIdRoot:(NSString *)defaultIdRoot
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaultIdRoot forKey:@"com.mobilehealthware.woundmap.defaultIdRoot"];
    [userDefaults synchronize];
}

- (NSInteger)hoursSinceLastPatientListUpdate
{
    double lastDateUpdated = [[NSUserDefaults standardUserDefaults] doubleForKey:@"com.mobilehealthware.woundmap.lastPatientListUpdate"];
    if (lastDateUpdated == 0.0) {
        return NSIntegerMax;
    }
    // else
    NSTimeInterval nowTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    return (nowTimeInterval - lastDateUpdated)/24.0 + 1;
}

- (void)patientListUpdated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:[NSDate timeIntervalSinceReferenceDate] forKey:@"com.mobilehealthware.woundmap.lastPatientListUpdate"];
}

- (NSSet *)woundPhotoObjectIdsToUpload
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [NSSet setWithArray:[userDefaults stringArrayForKey:@"com.mobilehealthware.woundmap.woundPhotoObjectIds"]];
}

- (void)setWoundPhotoObjectIdsToUpload:(NSSet *)woundPhotoObjectIdsToUpload
{
    NSMutableArray *uris = [NSMutableArray array];
    for (NSManagedObjectID *objectID in woundPhotoObjectIdsToUpload) {
        NSURL *uri = [objectID URIRepresentation];
        [uris addObject:[uri absoluteString]];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uris forKey:@"com.mobilehealthware.woundmap.woundPhotoObjectIds"];
    [userDefaults synchronize];
}

- (void)clearWoundPhotoObjectIDs
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"com.mobilehealthware.woundmap.woundPhotoObjectIds"];
}

#pragma mark - FF

- (NSDictionary *)lastRefreshTimeMap
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.mobilehealthware.woundmap.lastRefreshTimeMap"];
}

- (void)setLastRefreshTime:(NSDictionary *)lastRefreshTimeMap
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastRefreshTimeMap forKey:@"com.mobilehealthware.woundmap.lastRefreshTimeMap"];
    [userDefaults synchronize];
}

#pragma mark - Clinical Care Setting/Stage of Care

- (WMNavigationTrack *)defaultNavigationTrack:(NSManagedObjectContext *)managedObjectContext
{
    NSString *defaultNavigationTrackFFURL = self.defaultNavigationTrackFFURL;
    WMNavigationTrack *navigationTrack = nil;
    if (defaultNavigationTrackFFURL) {
        navigationTrack = [WMNavigationTrack trackForFFURL:defaultNavigationTrackFFURL
                                      managedObjectContext:managedObjectContext];
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
    [userDefaults setObject:defaultNavigationTrackFFURL forKey:@"com.mobilehealthware.woundmap.navigationTrackFFURL"];
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
    [userDefaults setObject:encryptionPassword forKey:@"com.mobilehealthware.woundmap.encryptionPassword"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFtoRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFtoRecipients"];
}

- (void)setEmailPDFtoRecipients:(NSArray *)emailPDFtoRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:emailPDFtoRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFtoRecipients"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFccRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFccRecipients"];
}

- (void)setEmailPDFccRecipients:(NSArray *)emailPDFccRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:emailPDFccRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFccRecipients"];
    [userDefaults synchronize];
}

- (NSArray *)emailPDFbccRecipients
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"com.mobilehealthware.woundmap.emailPDFbccRecipients"];
}

- (void)setEmailPDFbccRecipients:(NSArray *)emailPDFbccRecipients
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:emailPDFbccRecipients forKey:@"com.mobilehealthware.woundmap.emailPDFbccRecipients"];
    [userDefaults synchronize];
}

- (NSString *)pdfHeaderPrefix
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.pdfHeaderPrefix"];
}

- (void)setPdfHeaderPrefix:(NSString *)pdfHeaderPrefix
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pdfHeaderPrefix forKey:@"com.mobilehealthware.woundmap.pdfHeaderPrefix"];
    [userDefaults synchronize];
}

#pragma mark - FTP

- (NSString *)lastFTPHost
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.ftpHost"];
}

- (void)setLastFTPHost:(NSString *)lastFTPHost
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastFTPHost forKey:@"com.mobilehealthware.woundmap.ftpHost"];
    [userDefaults synchronize];
}

- (NSString *)lastFTPPath
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.ftpPath"];
}

- (void)setLastFTPPath:(NSString *)lastFTPPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastFTPPath forKey:@"com.mobilehealthware.woundmap.ftpPath"];
    [userDefaults synchronize];
}

- (NSString *)lastFTPUserName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.ftpUserName"];
}

- (void)setLastFTPUserName:(NSString *)lastFTPUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastFTPUserName forKey:@"com.mobilehealthware.woundmap.ftpUserName"];
    [userDefaults synchronize];
}

- (NSString *)lastFTPPassword
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"com.mobilehealthware.woundmap.ftpPassword"];
}

- (void)setLastFTPPassword:(NSString *)lastFTPPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lastFTPPassword forKey:@"com.mobilehealthware.woundmap.ftpPassword"];
    [userDefaults synchronize];
}

@end
