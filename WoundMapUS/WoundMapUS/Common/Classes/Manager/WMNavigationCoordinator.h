//
//  WMNavigationCoordinator.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPatientChangedNotification;
extern NSString *const kWoundChangedNotification;
extern NSString *const kWoundPhotoChangedNotification;
extern NSString *const kWoundWillDeleteNotification;
extern NSString *const kWoundPhotoAddedNotification;
extern NSString *const kWoundPhotoWillDeleteNotification;
extern NSString *const kNavigationTrackChangedNotification;
extern NSString *const kNavigationStageChangedNotification;

@class WMPatient, WMWound, WMWoundPhoto;
@class WMNavigationTrack, WMNavigationStage;

@interface WMNavigationCoordinator : NSObject

+ (WMNavigationCoordinator *)sharedInstance;

@property (strong, nonatomic) WMPatient *patient;           // active patient
@property (strong, nonatomic) WMWound *wound;               // active wound
@property (strong, nonatomic) WMWoundPhoto *woundPhoto;     // active woundPhoto

@property (nonatomic) WMNavigationTrack *navigationTrack;   // active track
@property (nonatomic) WMNavigationStage *navigationStage;   // active stage

@property (readonly, nonatomic) WMWound *lastWoundForPatient;
- (WMWound *)selectLastWoundForPatient;
- (void)deleteWound:(WMWound *)wound;

- (void)deleteWoundPhoto:(WMWoundPhoto *)woundPhoto;

@end
