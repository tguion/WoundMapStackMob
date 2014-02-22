//
//  WMHomeBaseViewController_iPhone.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMHomeBaseViewController_iPhone.h"
#import "WMPhotosContainerViewController.h"
#import "WMNavigationCoordinator.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WCAppDelegate.h"
#import <objc/runtime.h>

@interface WMHomeBaseViewController_iPhone ()

@end

@implementation WMHomeBaseViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationPatientWoundContainerView.drawTopLine = NO;
    self.navigationPatientWoundContainerView.deltaY = 0.0;
    // update navigation bar
    [self updateNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // else restore transform for patient wound stage cell
    [self.navigationPatientWoundContainerView resetState:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Model/View synchronization

- (void)updateNavigationBar
{
    [super updateNavigationBar];
    // show policy editor if home
    if (nil == self.parentNavigationNode) {
        WMNavigationTrack *navigationTrack = self.appDelegate.navigationCoordinator.navigationTrack;
        if (!sel_isEqual(self.navigationItem.leftBarButtonItem.action, @selector(editPoliciesAction:)) && !navigationTrack.skipPolicyEditor) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"]
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(editPoliciesAction:)];
        } else if (navigationTrack.skipPolicyEditor) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    } else {
        NSString *imageName = nil;
        if (nil == self.parentNavigationNode.parentNode) {
            // one step from home
            imageName = @"home";
        } else {
            // more than one step from home
            imageName = @"homeback";
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(homeAction:)];
    }
}

#pragma mark - View Controllers

- (WMPhotosContainerViewController *)photosContainerViewController
{
    return [[WMPhotosContainerViewController alloc] initWithNibName:@"WMPhotosContainerViewController" bundle:nil];
}


@end
