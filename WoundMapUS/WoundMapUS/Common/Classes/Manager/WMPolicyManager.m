//
//  WMPolicyManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPolicyManager.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
//#import "WMWoundMeasurementGroup.h"
//#import "WMWoundTreatmentGroup.h"
//#import "WMCarePlanGroup.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
//#import "WMBradenScale.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
//#import "WMPsychoSocialGroup.h"
//#import "WMSkinAssessmentGroup.h"
#import "WMNavigationNodeButton.h"
#import "WMNavigationCoordinator.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"

@implementation WMPolicyManager

+ (WMPolicyManager *)sharedInstance
{
    static WMPolicyManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPolicyManager alloc] init];
    });
    return SharedInstance;
}

@end
