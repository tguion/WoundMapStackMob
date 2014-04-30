//
//  IAPPurchaseViewController.m
//  WoundPUMP
//
//  Created by John Scarpaci on 7/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "IAPNonConsumableViewController.h"
#import "IAPProduct.h"
#import "IAPProduct.h"
#import "IAPManager.h"
#import "IAPBaseViewController.h"

@interface IAPNonConsumableViewController ()

@end

@implementation IAPNonConsumableViewController

#pragma mark View Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.preferredContentSize = CGSizeMake(320.0, 360.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (nil == self.skProduct) {
        self.purchaseButton.enabled = NO;
        self.purchaseButtonDescView.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (nil == self.navigationController) {
        [self clearAllReferences];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    [super reloadData];
    if (nil != self.skProduct) {
        self.purchaseButton.enabled = YES;
        self.purchaseButtonDescView.enabled = YES;
    }
}


@end
