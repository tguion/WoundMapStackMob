//
//  WMPhotosContainerViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/22/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundPhotoSlideShowViewController.h"
#import "WMWoundMeasurementGroupViewController.h"

@class WMWoundPhoto, WMWoundMeasurementGroupViewController, WMWoundMeasurementSummaryViewController;

typedef enum {
    PhotosContainerViewControllerStateNone          = 0,
    PhotosContainerViewControllerStateGrid          = 1,
    PhotosContainerViewControllerStatePage          = 2,
    PhotosContainerViewControllerStateDateCompare   = 3,
    PhotosContainerViewControllerStateSlideShow     = 4,
    PhotosContainerViewControllerStateZoom          = 5,
    PhotosContainerViewControllerStateGraph         = 6,
} PhotosContainerViewControllerState;

@protocol WoundPhotoCache <NSObject>

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSInteger woundPhotoCount;
@property (strong, nonatomic) WMWoundPhoto *woundPhotoDate1;
@property (strong, nonatomic) WMWoundPhoto *woundPhotoDate2;

- (void)configureNavigation;
- (void)invalidateWoundPhotoCache;
- (NSManagedObjectID *)woundPhotoObjectIDAtIndex:(NSInteger)index;
- (WMWoundPhoto *)woundPhotoAtIndex:(NSInteger)index;
- (void)handleWoundPhotoObjectIDSelection:(NSManagedObjectID *)woundPhotoObjectID atFrame:(CGRect)aFrame;
- (void)handleWoundPhotoSelection:(WMWoundPhoto *)woundPhoto atFrame:(CGRect)aFrame;
- (void)dismissSelectWoundPhotoByDateController;
- (void)transitionToGridController;
- (void)updateToolbarItems:(NSArray *)toolbarItems;

@end

@interface WMPhotosContainerViewController : UIViewController <WoundPhotoCache, WoundMeasurementGroupViewControllerDelegate, WoundPhotoSlideShowViewControllerDelegate, UIPopoverControllerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) PhotosContainerViewControllerState state;                                     // current state of the controller
@property (nonatomic) PhotosContainerViewControllerState previousState;                             // saved state when state is lost
@property (readonly, nonatomic) BOOL isStateNone;
@property (readonly, nonatomic) BOOL isStateGrid;
@property (readonly, nonatomic) BOOL isStatePage;
@property (readonly, nonatomic) BOOL isStateDateCompare;
@property (readonly, nonatomic) BOOL isStateSlideShow;
@property (readonly, nonatomic) BOOL isStateZoom;
@property (readonly, nonatomic) BOOL isStateGraph;

@property (strong, nonatomic) UIViewController *currentChildViewController;                         // current child view controller
@property (readonly, nonatomic) WMWoundMeasurementGroupViewController *measurementGroupViewController;  // Measurements for selected wound photo (replace woundMeasurementsViewController)
@property (readonly, nonatomic) WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController;

@property (strong, nonatomic) UISegmentedControl *gridScrollSegmentedControl;                       // control in toolbar to switch child veiw controller (grid,page,date,play)
@property (strong, nonatomic) UISegmentedControl *photoAssessmentSegmentedControl;                  // show/hide WoundPhotoMeasurementsViewController
@property (weak, nonatomic) UIBarButtonItem *photoAssessmentBarButtonItem;

- (IBAction)photoAssessmentSegmentedControlValueChangedAction:(id)sender;
- (void)removeCurrentChildViewControllerFromParentViewController;

@end
