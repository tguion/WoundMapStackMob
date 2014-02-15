//
//  WMPatientManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMPatient, WMNavigationTrack;

@interface WMPatientManager : NSObject

@property (readonly, nonatomic) NSInteger patientCount;
@property (readonly, nonatomic) WMPatient *lastModifiedActivePatient;

+ (WMPatientManager *)sharedInstance;

- (WMNavigationTrack *)navigationTrackForCurrentPatient:(NSManagedObjectContext *)managedObjectContext
                                        persistentStore:(NSPersistentStore *)store;

@end
