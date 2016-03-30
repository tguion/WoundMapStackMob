//
//  WMNavigationCoordinator_iPad.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/22/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMNavigationCoordinator_iPad.h"
#import "WMPhotosContainerViewController_iPad.h"
#import "MBProgressHUD.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMNavigationCoordinator_iPad ()
@property (readonly, nonatomic) WMPhotosContainerViewController_iPad *photosContainerViewController;
@end

@implementation WMNavigationCoordinator_iPad

+ (WMNavigationCoordinator_iPad *)sharedInstance
{
    static WMNavigationCoordinator_iPad *_SharedInstance = nil;
    if (nil == _SharedInstance) {
        _SharedInstance = [[WMNavigationCoordinator_iPad alloc] init];
    }
    return _SharedInstance;
}

- (WMPhotosContainerViewController_iPad *)photosContainerViewController
{
    UIViewController *viewController = self.appDelegate.window.rootViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[WMPhotosContainerViewController_iPad class]]) {
                return (WMPhotosContainerViewController_iPad *)vc;
            }
        }
    }
    // else
    return nil;
}

#pragma mark - Wound Measurements

- (void)viewController:(UIViewController *)viewController beginMeasurementsForWoundPhoto:(WMWoundPhoto *)woundPhoto addingPhoto:(BOOL)addingPhoto
{
    [super viewController:viewController beginMeasurementsForWoundPhoto:woundPhoto addingPhoto:addingPhoto];
    self.initialMeasurePhotoViewController = viewController;
    UINavigationController *navigationController = viewController.navigationController;
    // wait for tiling to finish
    if (woundPhoto.waitingForTilingToFinish) {
        return;
    }
    // else adjust image or scale
    [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
    // adjust image or scale
    if ([woundPhoto.wound hasPreviousWoundPhoto:woundPhoto]) {
        // adjust image
        WMTransformPhotoViewController *transformViewController = [[WMTransformPhotoViewController alloc] initWithNibName:@"WMTransformPhotoViewController" bundle:nil];
        transformViewController.delegate = self;
        [navigationController pushViewController:transformViewController animated:YES];
    } else {
        // set photo scale
        WMPhotoScaleViewController *photoScaleViewController = [[WMPhotoScaleViewController alloc] initWithNibName:@"WMPhotoScaleViewController" bundle:nil];
        photoScaleViewController.delegate = self;
        [navigationController pushViewController:photoScaleViewController animated:YES];
    }
}

@end
