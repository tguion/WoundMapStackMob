//
//  WMCompassView.h
//  WoundPUMP
//
//  Created by Todd Guion on 7/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMNavigationPatientPhotoButton, WMPatient;

typedef enum {
    MapBaseRotationDirection_West = 0,
    MapBaseRotationDirection_North = 1,
    MapBaseRotationDirection_East = 2,
    MapBaseRotationDirection_South = 3,
} MapBaseRotationDirection;

typedef enum {
    CompassViewActionStateNone = 0,
    CompassViewActionStateHome = 1,
    CompassViewActionStateLevel1 = 2,
    CompassViewActionStateLevel2 = 3,
    CompassViewActionStateLevel3 = 4,
} CompassViewActionState;

@interface WMCompassView : UIView

@property (assign, nonatomic) MapBaseRotationDirection rotationState;
@property (assign, nonatomic) CompassViewActionState actionState;

@property (nonatomic) CGFloat compassPanelMinX;
@property (nonatomic) CGFloat compassPanelMaxX;

@property (weak, nonatomic) IBOutlet UIImageView *compassNeedleImage;
@property (weak, nonatomic) IBOutlet WMNavigationPatientPhotoButton *patientPhotoView;
@property (strong, nonatomic) NSArray *navigationNodeControls;
@property (readonly, nonatomic) BOOL hasNavigationNodeControls;

- (void)recalculateDimensions;

- (void)recenterNavigationControls;
- (void)animateNodesIntoActivePosition;

- (IBAction)rotateToWestAction:(id)sender;
- (IBAction)rotateToNorthAction:(id)sender;
- (IBAction)rotateToEastAction:(id)sender;
- (IBAction)rotateToSouthAction:(id)sender;

- (void)updateForPatient:(WMPatient *)patient;
- (void)updateForPatientPhotoProcessing;
- (void)updateForPatientPhotoProcessed;

- (void)showPatientRefreshing;
- (void)hidePatientRefreshing;

@end
