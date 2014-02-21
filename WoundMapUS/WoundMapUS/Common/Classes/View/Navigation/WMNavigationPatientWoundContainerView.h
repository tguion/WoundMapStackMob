//
//  WMNavigationPatientWoundContainerView.h
//  WoundPUMP
//
//  Created by Todd Guion on 8/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMNavigationNode, WMNavigationNodeButton;

@protocol NavigationPatientWoundViewDelegate <NSObject>

@property (readonly, nonatomic) WMNavigationNode *addPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *selectPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *editPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *addWoundNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *selectWoundNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *editWoundNavigationNode;

@end

@interface WMNavigationPatientWoundContainerView : UIView

@property (weak, nonatomic) IBOutlet id<NavigationPatientWoundViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *patientAddNavigationNodeButton;
@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *patientEditNavigationNodeButton;
@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *patientSelectNavigationNodeButton;
@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *woundAddNavigationNodeButton;
@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *woundEditNavigationNodeButton;
@property (weak, nonatomic) IBOutlet WMNavigationNodeButton *woundSelectNavigationNodeButton;

@property (nonatomic) BOOL drawTopLine;
@property (readonly, nonatomic) BOOL swipeEnabled;
@property (nonatomic) CGFloat deltaY;

- (void)resetState:(BOOL)animate;
- (void)updatePatientAndWoundNodes;
- (void)updateContentForPatient;

@end
