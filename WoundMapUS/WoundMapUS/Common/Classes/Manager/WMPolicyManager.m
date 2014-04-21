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
#import "WMWoundMeasurementGroup.h"
#import "WMWoundTreatmentGroup.h"
#import "WMCarePlanGroup.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMBradenScale.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
#import "WMPsychoSocialGroup.h"
#import "WMSkinAssessmentGroup.h"
#import "WMNavigationNodeButton.h"
#import "WMNavigationCoordinator.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

NSString *const kTaskDidCompleteNotification = @"TaskDidCompleteNotification";

@interface WMPolicyManager ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMNavigationCoordinator *navigationCoordinator;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;
@property (strong, nonatomic) NSMutableSet *registeredButtons;

+ (NSInteger)complianceDeltaForFrequencyUnit:(NavigationNodeFrequencyUnit)frequencyUnit
                              frequencyValue:(NSInteger)frequencyValue
                                dateModified:(NSDate *)dateModified;

@end

@interface WMPolicyManager (PrivateMethods)

- (NSDate *)dateModifiedForNavigationNode:(WMNavigationNode *)navigationNode;
- (NSDate *)dateCreatedCutoff:(NavigationNodeFrequencyUnit)closeUnit closeValue:(NSInteger)closeValue;
- (NSInteger)complianceDeltaForNavigationNode:(WMNavigationNode *)navigationNode;
- (NSInteger)complianceDeltaForNavigationNodes:(NSArray *)navigationNodes;

@end

@implementation WMPolicyManager (PrivateMethods)

// determine the date modified for a node
- (NSDate *)dateModifiedForNavigationNode:(WMNavigationNode *)navigationNode
{
    NSDate *dateModified = nil;
    switch (navigationNode.navigationNodeIdentifier) {
        case kBradenScaleNode: {
            dateModified = [WMBradenScale lastCompleteBradenScaleDataModified:self.patient];
            break;
        }
        case kMedicationsNode: {
            dateModified = [WMMedicationGroup mostRecentOrActiveMedicationGroupDateModified:self.patient];
            break;
        }
        case kDevicesNode: {
            dateModified = [WMDeviceGroup mostRecentOrActiveDeviceGroupDateModified:self.patient];
            break;
        }
        case kPsycoSocialNode: {
            dateModified = [WMPsychoSocialGroup mostRecentOrActivePsychoSocialGroupDateModified:self.patient];
            break;
        }
        case kSkinAssessmentNode: {
            dateModified = [WMSkinAssessmentGroup mostRecentOrActiveSkinAssessmentGroupDateModified:self.patient];
            break;
        }
        case kTakePhotoNode: {
            dateModified = [WMWound mostRecentWoundPhotoDateCreatedForWound:self.wound];
            break;
        }
        case kMeasurePhotoNode: {
            WMWoundPhoto *woundPhoto = self.woundPhoto;
            if (nil != woundPhoto) {
                dateModified = [WMWoundMeasurementGroup mostRecentWoundMeasurementGroupDateCreatedForDimensions:self.woundPhoto];
            }
            break;
        }
        case kWoundAssessmentNode: {
            WMWoundPhoto *woundPhoto = self.woundPhoto;
            if (nil != woundPhoto) {
                dateModified = [WMWoundMeasurementGroup mostRecentWoundMeasurementGroupDateModifiedExcludingDimensions:self.woundPhoto];
                //self.wound.lastWoundPhoto.measurementGroup.dateModifiedExludingMeasurement;
            }
            break;
        }
        case kWoundTreatmentNode: {
            dateModified = [WMWoundTreatmentGroup mostRecentDateModified:self.wound];
            break;
        }
        case kCarePlanNode: {
            dateModified = [WMCarePlanGroup mostRecentOrActiveCarePlanGroupDateModified:self.patient];
            break;
        }
        case kWoundsNode: {
            dateModified = self.wound.createdAt;
            break;
        }
        case kAddWoundNode: {
            dateModified = self.wound.createdAt;
            break;
        }
        default:
            break;
    }
    return dateModified;
}

- (NSDate *)dateCreatedCutoff:(NavigationNodeFrequencyUnit)closeUnit closeValue:(NSInteger)closeValue
{
    NSParameterAssert(closeUnit != NavigationNodeFrequencyUnit_None);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    switch (closeUnit) {
        case NavigationNodeFrequencyUnit_Hourly: {
            dateComponents.hour = -closeValue;
            break;
        }
        case NavigationNodeFrequencyUnit_Daily: {
            dateComponents.day = -closeValue;
            break;
        }
        case NavigationNodeFrequencyUnit_Weekly: {
            dateComponents.week = -closeValue;
            break;
        }
        case NavigationNodeFrequencyUnit_Monthly: {
            dateComponents.month = -closeValue;
            break;
        }
        default:
            break;
    }
    return [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
}

- (NSInteger)complianceDeltaForNavigationNode:(WMNavigationNode *)navigationNode
{
    NSInteger complianceDelta = 0;
    NavigationNodeIdentifier navigationNodeIdentifier = navigationNode.navigationNodeIdentifier;
    NavigationNodeFrequencyUnit frequenceyUnit = navigationNode.frequencyUnitValue;
    NSInteger frequenceValue = [navigationNode.frequencyValue integerValue];
    NSDate *dateModified = [self dateModifiedForNavigationNode:navigationNode];
    WMNavigationNodeButton *navigationNodeButton = [[self.registeredButtons filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"navigationNode == %@", navigationNode]] anyObject];
    if (nil == dateModified && 0 == [navigationNode.subnodes count]) {
        // if required but nil, return the maximum, otherwise 1
        complianceDelta = (navigationNode.isRequired ? 3:1);
        navigationNodeButton.complianceDelta = complianceDelta;
        return complianceDelta;
    }
    // else
    switch (navigationNodeIdentifier) {
        case kInitialStageNode:
        case kFollowupStageNode:
        case kDischargeStageNode:
        case kSelectPatientNode:
        case kEditPatientNode:
        case kAddPatientNode:
        case kSelectWoundNode:
        case kEditWoundNode:
        case kAddWoundNode:
        case kSelectStageNode:
        case kBrowsePhotosNode:
        case kViewGraphsNode:
        case kShareNode:
        case kEmailReportNode:
        case kPrintReportNode:
        case kPushEMRNode:
        case kPatientSummaryNode:
            break;
        case kWoundsNode: {
            // examine all subnodes
            complianceDelta = [self complianceDeltaForNavigationNodes:[navigationNode.subnodes allObjects]];
            break;
        }
        case kRiskAssessmentNode: {
            // examine all subnodes
            complianceDelta = [self complianceDeltaForNavigationNodes:[navigationNode.subnodes allObjects]];
            break;
        }
        case kBradenScaleNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kMedicationsNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kDevicesNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kPsycoSocialNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kSkinAssessmentNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kPhotoNode: {
            if (nil == self.wound) {
                complianceDelta = -1;
            } else {
                complianceDelta = [self complianceDeltaForNavigationNodes:[navigationNode.subnodes allObjects]];
            }
            break;
        }
        case kTakePhotoNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kMeasurePhotoNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
        case kWoundAssessmentNode: {
            if (nil == self.wound) {
                complianceDelta = -1;
            } else {
                complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            }
            break;
        }
        case kWoundTreatmentNode: {
            if (nil == self.wound) {
                complianceDelta = -1;
            } else {
                complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            }
            break;
        }
        case kCarePlanNode: {
            complianceDelta = [WMPolicyManager complianceDeltaForFrequencyUnit:frequenceyUnit frequencyValue:frequenceValue dateModified:dateModified];
            break;
        }
    }
    navigationNodeButton.complianceDelta = complianceDelta;
    return complianceDelta;
}

- (NSInteger)complianceDeltaForNavigationNodes:(NSArray *)navigationNodes
{
    NSInteger complianceDelta = 0;
    for (WMNavigationNode *navigationNode in navigationNodes) {
        complianceDelta = MAX(complianceDelta, [self complianceDeltaForNavigationNode:navigationNode]);
    }
    return complianceDelta;
}

@end

@implementation WMPolicyManager

@synthesize registeredButtons=_registeredButtons;

+ (WMPolicyManager *)sharedInstance
{
    static WMPolicyManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPolicyManager alloc] init];
    });
    return SharedInstance;
}

- (NSInteger)closeExpiredRecords:(WMNavigationNode *)navigationNode
{
    NavigationNodeIdentifier navigationNodeIdentifier = navigationNode.navigationNodeIdentifier;
    NavigationNodeFrequencyUnit unit = navigationNode.closeUnitValue;
    NSInteger closeValue = [navigationNode.closeValue integerValue];
    if (0 == closeValue || NavigationNodeFrequencyUnit_None == unit) {
        return 0;
    }
    // else
    NSDate *dateCreatedCutoff = [self dateCreatedCutoff:unit closeValue:closeValue];
    NSInteger count = 0;
    switch (navigationNodeIdentifier) {
        case kBradenScaleNode: {
            // fetch all WCBradenScale where dateCreate > dateCreatedCutoff
            count = [WMBradenScale closeBradenScalesCreatedBefore:dateCreatedCutoff
                                                          patient:self.patient];
            break;
        }
        case kMedicationsNode: {
            // fetch all WCMedicationGroup where dateCreate > dateCreatedCutoff
            count = [WMMedicationGroup closeMedicationGroupsCreatedBefore:dateCreatedCutoff
                                                                  patient:self.patient];
            break;
        }
        case kDevicesNode: {
            // fetch all WCDeviceGroup where dateCreate > dateCreatedCutoff
            count = [WMDeviceGroup closeDeviceGroupsCreatedBefore:dateCreatedCutoff
                                                          patient:self.patient];
            break;
        }
        case kPsycoSocialNode: {
            // fetch all WCPsychoSocialGroup where dateCreate > dateCreatedCutoff
            count = [WMPsychoSocialGroup closePsychoSocialGroupsCreatedBefore:dateCreatedCutoff
                                                                      patient:self.patient];
            break;
        }
        case kSkinAssessmentNode: {
            // fetch all WCSkinAssessmentGroup where dateCreate > dateCreatedCutoff
            count = [WMSkinAssessmentGroup closeSkinAssessmentGroupsCreatedBefore:dateCreatedCutoff
                                                                          patient:self.patient];
            break;
        }
        case kWoundAssessmentNode: {
            // fetch all WCWoundMeasurementGroup where dateCreate > dateCreatedCutoff
            count = [WMWoundMeasurementGroup closeWoundAssessmentGroupsCreatedBefore:dateCreatedCutoff
                                                                             patient:self.patient];
            break;
        }
        case kWoundTreatmentNode: {
            // fetch all WCWoundTreatmentGroup where dateCreate > dateCreatedCutoff
            count = [WMWoundTreatmentGroup closeWoundTreatmentGroupsCreatedBefore:dateCreatedCutoff
                                                                          patient:self.patient];
            break;
        }
        case kCarePlanNode: {
            // fetch all WMCarePlanGroup where dateCreate > dateCreatedCutoff
            count = [WMCarePlanGroup closeCarePlanGroupsCreatedBefore:dateCreatedCutoff
                                                              patient:self.patient];
            break;
        }
        default: {
            NSAssert1(NO, @"Uncovered node: %@", navigationNode);
            break;
        }
    }
    return count;
}

+ (NSInteger)complianceDeltaForFrequencyUnit:(NavigationNodeFrequencyUnit)frequencyUnit
                              frequencyValue:(NSInteger)frequencyValue
                                dateModified:(NSDate *)dateModified
{
    if (nil == dateModified) {
        return 1;
    }
    // else
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    static NSDateComponents *DateComponents[5];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        dc.year = 1;
        DateComponents[0] = dc;
        dc = [[NSDateComponents alloc] init];
        dc.hour = 1;
        DateComponents[1] = dc;
        dc = [[NSDateComponents alloc] init];
        dc.day = 1;
        DateComponents[2] = dc;
        dc = [[NSDateComponents alloc] init];
        dc.week = 1;
        DateComponents[3] = dc;
        dc = [[NSDateComponents alloc] init];
        dc.month = 1;
        DateComponents[4] = dc;
    });
    NSDate *complianceDate = [calendar dateByAddingComponents:DateComponents[frequencyUnit] toDate:dateModified options:0];
    // now back up to see how many units out of compliance
    NSDate *now = [NSDate date];
    NSInteger complianceDelta = 0;
    while ([now earlierDate:complianceDate] != now) {
        if (complianceDelta == 0) {
            // skip the missing (1) index
            ++complianceDelta;
        }
        ++complianceDelta;
        if (complianceDelta >= 3) {
            break;
        }
        // else
        complianceDate = [calendar dateByAddingComponents:DateComponents[frequencyUnit] toDate:complianceDate options:0];
    }
    complianceDelta = MIN(3, complianceDelta);
    return complianceDelta;
}

- (id)init
{
    self = [super init];
    if (nil != self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kPatientChangedNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [self performSelector:@selector(updateRegisteredButtons) withObject:nil afterDelay:0.0];
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kWoundChangedNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [self performSelector:@selector(updateRegisteredButtons) withObject:nil afterDelay:0.0];
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kNavigationStageChangedNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [self performSelector:@selector(updateRegisteredButtons) withObject:nil afterDelay:0.0];
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kTaskDidCompleteNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          // we may need to know what node has finished
                                                          NavigationNodeIdentifier navigationNodeIdentifier = (NavigationNodeIdentifier)[[notification object] intValue];
                                                          DLog(@"PolicyManager received notification for task completed %d", navigationNodeIdentifier);
                                                          [self performSelector:@selector(updateRegisteredButtonWithNavigationNodeIdentifier:) withObject:[NSNumber numberWithInt:navigationNodeIdentifier] afterDelay:0.0];
                                                      }];
        // handle woundPhoto delete
        [[NSNotificationCenter defaultCenter] addObserverForName:kWoundPhotoWillDeleteNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [self performSelector:@selector(updateRegisteredButtons) withObject:nil afterDelay:0.0];
                                                      }];
    }
    return self;
}

- (void)handleICloudAccountChanged
{
    [self.registeredButtons makeObjectsPerformSelector:@selector(setNavigationNode:) withObject:nil];
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMNavigationCoordinator *)navigationCoordinator
{
    return self.appDelegate.navigationCoordinator;
}

- (WMPatient *)patient
{
    return self.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    WMWound *wound = self.navigationCoordinator.wound;
    if (nil == wound) {
        wound = self.navigationCoordinator.lastWoundForPatient;
    }
    return wound;
}

- (WMWoundPhoto *)woundPhoto
{
    return self.navigationCoordinator.woundPhoto;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (UIImage *)statusImageForComplianceDelta:(NSInteger)complianceDelta
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSString *fileName = nil;
    NSString *suffix = (isPad ? @"_iPad":@"_iPhone");
    switch (complianceDelta) {
        case 0: {
            fileName = @"alert_green";
            break;
        }
        case 1: {
            fileName = @"alert_green";
            break;
        }
        case 2: {
            fileName = @"alert_yellow";
            break;
        }
        case 3: {
            fileName = @"alert_red";
            break;
        }
        default:
            break;
    }
    return [UIImage imageNamed:[fileName stringByAppendingString:suffix]];
}

- (UIImage *)statusImageForNavigationNode:(WMNavigationNode *)navigationNode
{
    NSInteger complianceDelta = [self complianceDeltaForNavigationNode:navigationNode];
    return [self statusImageForComplianceDelta:complianceDelta];
}

// determine the navigation node we recommend from list
- (WMNavigationNode *)recommendedNavigationNodeForNavigationNodes:(NSArray *)navigationNodes
{
    if (0 == [navigationNodes count] || nil == self.patient) {
        return nil;
    }
    // else
    NSMutableArray *orderedNavigationNodes = [[NSMutableArray alloc] initWithCapacity:[navigationNodes count]];
    NSInteger complianceDelta = 0;
    NSEnumerator *enumeration = [navigationNodes objectEnumerator];
    for (WMNavigationNode *navigationNode in enumeration) {
        NSInteger delta = [self complianceDeltaForNavigationNode:navigationNode];
        if (delta > complianceDelta) {
            // this is the winner (or loser) so far
            complianceDelta = delta;
            [orderedNavigationNodes insertObject:navigationNode atIndex:0];
        } else {
            [orderedNavigationNodes addObject:navigationNode];
        }
    }
    return [orderedNavigationNodes objectAtIndex:0];
}

#pragma mark - Button Registration

- (NSMutableSet *)registeredButtons
{
    if (nil == _registeredButtons) {
        _registeredButtons = [[NSMutableSet alloc] initWithCapacity:36];
    }
    return _registeredButtons;
}

- (void)registerNavigationNodeButton:(WMNavigationNodeButton *)navigationNodeButton
{
    [self.registeredButtons addObject:navigationNodeButton];
}

- (void)unregisterNavigationNodeButton:(WMNavigationNodeButton *)navigationNodeButton
{
    [self.registeredButtons removeObject:navigationNodeButton];
}

- (void)updateRegisteredButtonWithNavigationNodeIdentifier:(NSNumber *)navigationNodeIdentifier
{
    WMNavigationNodeButton *navigationNodeButton = [[self.registeredButtons filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"navigationNode.taskIdentifier == %@", navigationNodeIdentifier]] anyObject];
    navigationNodeButton.complianceDelta = [self complianceDeltaForNavigationNode:navigationNodeButton.navigationNode];
}

- (void)updateRegisteredButtons
{
    [self updateRegisteredButtonsInArray:[self.registeredButtons allObjects]];
}

- (void)updateRegisteredButtonsInArray:(NSArray *)navigationButtons
{
    if (nil == self.patient) {
        return;
    }
    // else
    for (WMNavigationNodeButton *navigationNodeButton in navigationButtons) {
        navigationNodeButton.complianceDelta = [self complianceDeltaForNavigationNode:navigationNodeButton.navigationNode];
    }
}

- (BOOL)buttonIsRegistered:(WMNavigationNodeButton *)navigationNodeButton
{
    return [self.registeredButtons containsObject:navigationNodeButton];
}

@end
