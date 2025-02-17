//
//  WMUserDefaultsManager.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMNavigationTrack;

@interface WMUserDefaultsManager : NSObject

+ (WMUserDefaultsManager *)sharedInstance;

@property (nonatomic) BOOL splashViewInstructionViewed;
@property (nonatomic) BOOL showUserNameOnSignIn;
@property (nonatomic) NSString *lastUserName;
@property (nonatomic) NSString *lastTeamName;
- (NSString *)lastPatientFFURLForUserGUID:(NSString *)guid;
- (void)setLastPatientFFURL:(NSString *)patientFFURL forUserGUID:(NSString *)guid;
@property (nonatomic) NSDate *lastDateOfBirth;
@property (nonatomic) NSString *defaultNavigationTrackFFURL;
@property (nonatomic) BOOL shouldRequestPasswordForEmailAttachment;
@property (strong, nonatomic) NSString *encryptionPassword;       // password to protect PDF
@property (strong, nonatomic) NSArray *emailPDFtoRecipients;
@property (strong, nonatomic) NSArray *emailPDFccRecipients;
@property (strong, nonatomic) NSArray *emailPDFbccRecipients;
@property (strong, nonatomic) NSString *pdfHeaderPrefix;
@property (nonatomic) NSDictionary *lastRefreshTimeMap;
@property (nonatomic) NSString *woundPositionTermKey;           // key used to display wound position (Left, Right, etc)
@property (nonatomic) NSString *defaultIdRoot;
- (NSString *)defaultIdRootAtIndex:(NSInteger)index;
- (void)setDefaultIdRoot:(NSString *)idRoot atIndex:(NSInteger)index;
@property (readonly, nonatomic) NSInteger hoursSinceLastPatientListUpdate;
- (void)patientListUpdated;
@property (nonatomic) NSSet *woundPhotoObjectIdsToUpload;
- (void)clearWoundPhotoObjectIDs;

@property (nonatomic) NSString *lastFTPHost;
@property (nonatomic) NSInteger lastFTPPort;
@property (nonatomic) NSString *lastFTPPath;
@property (nonatomic) NSString *lastFTPUserName;
@property (nonatomic) NSString *lastFTPPassword;

- (WMNavigationTrack *)defaultNavigationTrack:(NSManagedObjectContext *)managedObjectContext;

- (NSString *)lastWoundFFURLOnDeviceForPatientFFURL:(NSString *)ffUrl;
- (void)setLastWoundFFURLOnDevice:(NSString *)lastWoundFFURLOnDevice forPatientFFURL:(NSString *)ffUrl;

@end
