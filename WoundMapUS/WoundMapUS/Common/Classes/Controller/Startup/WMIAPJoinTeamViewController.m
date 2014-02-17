//
//  WMIAPJoinTeamViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPJoinTeamViewController.h"

@interface WMIAPJoinTeamViewController ()

@end

@implementation WMIAPJoinTeamViewController

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

#pragma mark - Actions

- (IBAction)purchaseAction:(id)sender
{
    [self.delegate iapJoinTeamViewControllerDidPurchase:self];
}

- (IBAction)declineAction:(id)sender
{
    [self.delegate iapJoinTeamViewControllerDidDecline:self];
}

@end
