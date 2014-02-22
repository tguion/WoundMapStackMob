//
//  WMHomeBaseViewController_iPad.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMHomeBaseViewController_iPad.h"
#import "WMPhotosContainerViewController_iPad.h"

@interface WMHomeBaseViewController_iPad ()

@end

@implementation WMHomeBaseViewController_iPad

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

#pragma mark - View Controllers

- (WMPhotosContainerViewController *)photosContainerViewController
{
    return [[WMPhotosContainerViewController_iPad alloc] initWithNibName:@"WMPhotosContainerViewController_iPad" bundle:nil];
}

@end
