//
//  WMIAPCreateTeamViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPCreateTeamViewController.h"
#import "IAPProduct.h"
#import "ConstraintPack.h"

@interface WMIAPCreateTeamViewController ()

@end

@implementation WMIAPCreateTeamViewController

@synthesize contentInsets = _contentInsets;

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
    self.title = @"Create Team";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Purchase" style:UIBarButtonItemStylePlain target:self action:@selector(purchaseAction:)];
    // set the product
//    self.iapProduct = [IAPProduct productForIdentifier:kCreateTeamProductIdentifier create:NO managedObjectContext:self.managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions


@end
