//
//  WMSeedDatabaseManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSeedDatabaseManager.h"
#import "WMInstruction.h"
#import "WMParticipantType.h"
#import "WMParticipantType.h"
#import "WMWoundType.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMPatient.h"
#import "WMBradenCare.h"
#import "WMWoundType.h"
#import "WMDefinition.h"
#import "WMInstruction.h"
#import "IAPProduct.h"
#import "CoreDataHelper.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMSeedDatabaseManager ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@end

@implementation WMSeedDatabaseManager

#pragma mark - Initialization

+ (WMSeedDatabaseManager *)sharedInstance
{
    static WMSeedDatabaseManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMSeedDatabaseManager alloc] init];
    });
    return SharedInstance;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DLog(@"reading plists and seeding database start");
        [WMBradenCare seedDatabase:managedObjectContext];
        [WMDefinition seedDatabase:managedObjectContext];
        [WMInstruction seedDatabase:managedObjectContext];
        [WMWoundType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs) {
            // update backend
            [ffm createArray:objectIDs collection:[WMWoundType entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                // handle children to-many relationship
                WMWoundType *woundType = (WMWoundType *)object;
                NSAssert([woundType isKindOfClass:[WMWoundType class]], @"Expected WMWoundType, but received %@", woundType);
                if ([woundType.children count]) {
                    for (WMWoundType *child in woundType.children) {
                        [ff queueGrabBagAddItemAtUri:child.ffUrl toObjAtUri:woundType.ffUrl grabBagName:WMWoundTypeRelationships.children];
                    }
                }
            }];
        }];
        [WMParticipantType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs) {
            // update backend
            [ffm createArray:objectIDs collection:[WMParticipantType entityName] ff:ff completionHandler:nil];
        }];
//        [WCAmountQualifier seedDatabase:managedObjectContext persistentStore:nil];
//        [WCWoundOdor seedDatabase:managedObjectContext persistentStore:nil];
//        [WCInterventionStatus seedDatabase:managedObjectContext persistentStore:nil];
//        [WCInterventionEventType seedDatabase:managedObjectContext persistentStore:nil];
//        [WMMedicationCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMDeviceCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMSkinAssessmentCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMCarePlanCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WCWoundLocation seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundTreatment seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundMeasurement seedDatabase:managedObjectContext persistentStore:nil];
        [WMNavigationTrack seedDatabase:managedObjectContext  completionHandler:^(NSError *error, NSArray *objectIDs) {
            // update backend
            [ffm createArray:objectIDs collection:[WMNavigationTrack entityName] ff:ff completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                if ([object isKindOfClass:[WMNavigationNode class]]) {
                    // handle subnodes to-many relationship
                    WMNavigationNode *navigationNode = (WMNavigationNode *)object;
                    if ([navigationNode.subnodes count]) {
                        for (WMNavigationNode *subnode in navigationNode.subnodes) {
                            [ff queueGrabBagAddItemAtUri:subnode.ffUrl toObjAtUri:navigationNode.ffUrl grabBagName:WMNavigationNodeRelationships.subnodes];
                        }
                    }
                } else if ([object isKindOfClass:[WMNavigationStage class]]) {
                    // handle nodes to-many relationship
                    WMNavigationStage *navigationStage = (WMNavigationStage *)object;
                    if ([navigationStage.nodes count]) {
                        for (WMNavigationNode *node in navigationStage.nodes) {
                            [ff queueGrabBagAddItemAtUri:node.ffUrl toObjAtUri:navigationStage.ffUrl grabBagName:WMNavigationStageRelationships.nodes];
                        }
                    }
                } else if ([object isKindOfClass:[WMNavigationTrack class]]) {
                    // handle stages to-many relationship
                    WMNavigationTrack *navigationTrack = (WMNavigationTrack *)object;
                    if ([navigationTrack.stages count]) {
                        for (WMNavigationStage *stage in navigationTrack.stages) {
                            [ff queueGrabBagAddItemAtUri:stage.ffUrl toObjAtUri:navigationTrack.ffUrl grabBagName:WMNavigationTrackRelationships.stages];
                        }
                    }
                }
            }];
        }];
//        [WMPsychoSocialItem seedDatabase:stackMobContext persistentStore:nil];
        DLog(@"reading plists and seeding database finished");
    });
}

- (void)seedTeamDatabase:(WMTeam *)team completionHandler:(void (^)(NSError *))handler
{
    
}

@end
