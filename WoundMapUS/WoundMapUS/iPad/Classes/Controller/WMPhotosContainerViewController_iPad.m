//
//  WMPhotosContainerViewController_iPad.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/22/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotosContainerViewController_iPad.h"
#import "WMPlotGraphViewController.h"
#import "WMWoundMeasurementGroupViewController.h"
#import "WMUnderlayNavigationBar.h"
#import "WMUnderlayToolbar.h"

@interface WMPhotosContainerViewController_iPad () <UIPopoverControllerDelegate>

@property (strong, nonatomic) WMPlotGraphViewController *plotGraphViewController;
@property (strong, nonatomic) UIPopoverController *measurementPopoverController;
@property (strong, nonatomic) UIPopoverController *assessmentPopoverController;
@property (strong, nonatomic) UIPopoverController *woundPopoverController;                      // host wound view controller

@end

@implementation WMPhotosContainerViewController_iPad

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Core

- (WMPlotGraphViewController *)plotGraphViewController
{
    if (nil == _plotGraphViewController) {
        _plotGraphViewController = [[WMPlotGraphViewController alloc] initWithNibName:@"WMPlotGraphViewController" bundle:nil];
    }
    return _plotGraphViewController;
}

#pragma mark - PhotosContainerViewController

#pragma mark - Actions

- (IBAction)photoAssessmentSegmentedControlValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (segmentedControl.selectedSegmentIndex == 2) {
        // Assessment - open in popover
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithNavigationBarClass:[WMUnderlayNavigationBar class] toolbarClass:[WMUnderlayToolbar class]];
        [navigationController setViewControllers:@[self.measurementGroupViewController]];
        self.measurementPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        self.measurementPopoverController.delegate = self;
        [self.measurementPopoverController presentPopoverFromBarButtonItem:self.photoAssessmentBarButtonItem
                                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                  animated:YES];
    } else {
        [super photoAssessmentSegmentedControlValueChangedAction:sender];
    }
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    [_measurementPopoverController dismissPopoverAnimated:YES];
    _measurementPopoverController = nil;
    // reset the segmented control
    self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    [self.measurementPopoverController dismissPopoverAnimated:YES];
    _measurementPopoverController = nil;
    // reset the segmented control
    self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
}

#pragma mark - UIPopoverControllerDelegate

// Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (_measurementPopoverController == popoverController) {
        self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
        _measurementPopoverController = nil;
    }
}

@end
