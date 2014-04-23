//
//  WMPhotoZoomViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/12/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMPhotoZoomViewController.h"
#import "WMWoundPhoto.h"
#import "WMImageScrollView.h"
#import "WMWoundMeasurementLabel.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

@interface WMPhotoZoomViewController ()
@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;  // observers that do away when the view dissappears
@end

@implementation WMPhotoZoomViewController

@synthesize initialFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // listen for woundPhoto change
    __weak __typeof(self) weakSelf = self;
    // woundPhoto was selected
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kWoundPhotoChangedNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [weakSelf handleWoundPhotoChanged:[notification object]];
                                                                }];
    [self.opaqueNotificationObservers addObject:observer];
    
    id bottomGuide = self.bottomLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_woundMeasurementLabel, bottomGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_woundMeasurementLabel]-8-[bottomGuide]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view layoutSubviews]; // You must call this method here or the system raises an exception
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAssert1(nil != self.woundPhoto, @"%@.woundPhoto is nil", NSStringFromClass([self class]));
    self.woundMeasurementLabel.text = self.woundPhoto.photoLabelText;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterForNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (void)unregisterForNotifications
{
    // stop listening
    for (id observer in self.opaqueNotificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [self.opaqueNotificationObservers removeAllObjects];
}

- (CGRect)targetFrameInView:(UIView *)aView
{
    return [_scrollView targetFrameInView:aView];
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

- (void)handleWoundPhotoChanged:(NSManagedObjectID *)woundPhotoObjectID
{
    self.woundMeasurementLabel.text = self.woundPhoto.photoLabelText;
}

@end
