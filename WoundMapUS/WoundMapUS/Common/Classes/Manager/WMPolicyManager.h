//
//  WMPolicyManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNavigationNode.h"

extern NSString *const kTaskDidCompleteNotification;

@class WMNavigationNode, WMNavigationNodeButton;

@interface WMPolicyManager : NSObject

+ (WMPolicyManager *)sharedInstance;

- (void)handleICloudAccountChanged;

- (void)registerNavigationNodeButton:(WMNavigationNodeButton *)navigationNodeButton;
- (void)unregisterNavigationNodeButton:(WMNavigationNodeButton *)navigationNodeButton;
- (void)updateRegisteredButtons;
- (void)updateRegisteredButtonsInArray:(NSArray *)navigationButtons;
- (BOOL)buttonIsRegistered:(WMNavigationNodeButton *)navigationNodeButton;

- (UIImage *)statusImageForComplianceDelta:(NSInteger)complianceDelta;
- (UIImage *)statusImageForNavigationNode:(WMNavigationNode *)navigationNode;
- (WMNavigationNode *)recommendedNavigationNodeForNavigationNodes:(NSArray *)navigationNodes;

- (NSInteger)closeExpiredRecords:(WMNavigationNode *)navigationNode;

@end
