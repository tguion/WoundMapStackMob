//
//  WMSelectWoundPhotoForDateController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/3/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMSelectWoundPhotoForDateController.h"

@interface WMSelectWoundPhotoForDateController ()

@end

@implementation WMSelectWoundPhotoForDateController

@synthesize cacheDelegate;

- (void)loadView
{
    [super loadView];
    self.title = @"Select Photo";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.cacheDelegate dismissSelectWoundPhotoByDateController];
}

@end
