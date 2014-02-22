//
//  WMNavigationCoordinator.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNavigationCoordinator.h"
#import "WMUserDefaultsManager.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

NSString *const kPatientChangedNotification = @"PatientChangedNotification";
NSString *const kWoundChangedNotification = @"WoundChangedNotification";
NSString *const kWoundPhotoChangedNotification = @"WoundPhotoChangedNotification";
NSString *const kNavigationStageChangedNotification = @"NavigationStageChangedNotification";
NSString *const kNavigationTrackChangedNotification = @"NavigationTrackChangedNotification";

@interface WMNavigationCoordinator ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation WMNavigationCoordinator

+ (WMNavigationCoordinator *)sharedInstance
{
    static WMNavigationCoordinator *_SharedInstance = nil;
    if (nil == _SharedInstance) {
        _SharedInstance = [[WMNavigationCoordinator alloc] init];
    }
    return _SharedInstance;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.coreDataHelper.stackMobStore mainThreadContext];
}

#pragma mark - Core

- (void)setPatient:(WMPatient *)patient
{
    WM_ASSERT_MAIN_THREAD;
    if ([_patient isEqual:patient]) {
        return;
    }
    // else
    _patient = patient;
    if (nil != _patient) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangedNotification object:[_patient objectID]];
    }
}

- (void)setWound:(WMWound *)wound
{
    WM_ASSERT_MAIN_THREAD;
    if ([_wound isEqual:wound]) {
        return;
    }
    // else
    _wound = wound;
    if (nil != _wound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWoundChangedNotification object:[_wound objectID]];
    }
}

- (void)setWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    WM_ASSERT_MAIN_THREAD;
    if ([_woundPhoto isEqual:woundPhoto]) {
        return;
    }
    // else
    _woundPhoto = woundPhoto;
    if (nil != _woundPhoto) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWoundPhotoChangedNotification object:[_woundPhoto objectID]];
    }
}

- (WMNavigationTrack *)navigationTrack
{
    WM_ASSERT_MAIN_THREAD;
    WMNavigationTrack *navigationTrack = self.patient.stage.track;
    if (nil == navigationTrack) {
        navigationTrack = [[WMUserDefaultsManager sharedInstance] defaultNavigationTrack:self.managedObjectContext persistentStore:nil];
    }
    return navigationTrack;
}

- (void)setNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    WM_ASSERT_MAIN_THREAD;
    NSAssert(nil != navigationTrack, @"Do not set navigationTrack to nil");
    BOOL patientNavigationTrackDidChange = NO;
    [[WMUserDefaultsManager sharedInstance] setDefaultNavigationTrackTitle:navigationTrack.title];
    WMPatient *patient = self.patient;
    if (nil != patient) {
        WMNavigationTrack *patientNavigationTrack = patient.stage.track;
        if (![patientNavigationTrack isEqual:navigationTrack]) {
            patient.stage = navigationTrack.initialStage;
            patientNavigationTrackDidChange = YES;
        }
    }
    if (patientNavigationTrackDidChange) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationTrackChangedNotification object:[navigationTrack objectID]];
    }
}

- (WMNavigationStage *)navigationStage
{
    WM_ASSERT_MAIN_THREAD;
    return self.patient.stage;
}

- (void)setNavigationStage:(WMNavigationStage *)navigationStage
{
    WM_ASSERT_MAIN_THREAD;
    NSAssert(nil != navigationStage, @"Do not set navigationStage to nil");
    WMPatient *patient = self.patient;
    if (nil != patient) {
        WMNavigationStage *patientNavigationStage = patient.stage;
        if (![patientNavigationStage isEqual:navigationStage]) {
            patient.stage = navigationStage;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationStageChangedNotification object:[navigationStage objectID]];
        }
    }
}

@end
