//
//  WMWoundTreatmentGroupsViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundTreatmentGroupsViewController.h"
#import "WMWoundTreatmentViewController.h"
#import "WMWoundTreatmentSummaryViewController.h"
#import "WMWoundTreatmentGroup.h"
#import "WMUtilities.h"

@interface WMWoundTreatmentGroupsViewController () <WoundTreatmentViewControllerDelegate>

@end

@implementation WMWoundTreatmentGroupsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
