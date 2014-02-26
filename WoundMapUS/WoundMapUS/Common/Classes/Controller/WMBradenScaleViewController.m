//
//  WMBradenScaleViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBradenScaleViewController.h"
#import "WMBradenScaleInputViewController.h"
#import "WMBradenScale.h"

@interface WMBradenScaleViewController ()

@property (readonly, nonatomic) WMBradenScaleInputViewController *bradenScaleInputViewController;
@property (nonatomic) BOOL didCancelBradenScaleEdit;
@property (nonatomic) BOOL didCreateBradenScale;

- (void)navigateToBradenScaleEditor:(BOOL)animated;

@end

@implementation WMBradenScaleViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 380.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Braden Scales";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						   target:self
																						   action:@selector(addBradenScaleAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // if not braden scale create and navigate
    if (!_didCancelBradenScaleEdit && nil == [WMBradenScale latestBradenScale:self.managedObjectContext create:NO]) {
        self.bradenScale = [WMBradenScale latestBradenScale:self.managedObjectContext create:YES];
        _didCreateBradenScale = YES;
        // navigate after delay
		[self performSelector:@selector(navigateToBradenScaleEditor:) withObject:@YES afterDelay:0.0];
    } else {
        [self.tableView reloadData];
    }
    self.didCancelBradenScaleEdit = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (BradenScaleInputViewController *)bradenScaleInputViewController
{
    WMBradenScaleInputViewController *bradenScaleInputViewController = [[WMBradenScaleInputViewController alloc] initWithNibName:@"WMBradenScaleInputViewController" bundle:nil];
    bradenScaleInputViewController.delegate = self;
    return bradenScaleInputViewController;
}

- (void)navigateToBradenScaleEditor:(BOOL)animated
{
    WMBradenScaleInputViewController *bradenScaleInputViewController = self.bradenScaleInputViewController;
    bradenScaleInputViewController.bradenScale = self.bradenScale;
	[self.navigationController pushViewController:bradenScaleInputViewController animated:animated];
}

@end
