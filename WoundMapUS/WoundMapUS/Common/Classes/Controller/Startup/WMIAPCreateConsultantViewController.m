//
//  WMIAPCreateConsultantViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPCreateConsultantViewController.h"
#import "IAPProduct.h"
#import "WMUtilities.h"

@interface WMIAPCreateConsultantViewController ()

@end

@implementation WMIAPCreateConsultantViewController

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
    self.title = @"Consulting Group";
    self.iapProduct = [IAPProduct productForIdentifier:kCreateConsultingGroupProductIdentifier
                                                create:YES
                                  managedObjectContext:self.managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
