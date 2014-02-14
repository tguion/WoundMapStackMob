//
//  WMUserDefaultsManager.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMNavigationTrack;

@interface WMUserDefaultsManager : NSObject

+ (WMUserDefaultsManager *)sharedInstance;

@property (nonatomic) NSString *lastTeamName;
@property (nonatomic) NSString *lastPatientId;
@property (nonatomic) NSDate *lastDateOfBirth;
@property (nonatomic) NSString *defaultNavigationTrackTitle;

- (WMNavigationTrack *)defaultNavigationTrack:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end
