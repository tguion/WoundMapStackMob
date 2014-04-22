//
//  WMPhotoDepthViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotoDepthViewController.h"
#import "WMWoundPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

@interface WMPhotoDepthViewController ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;

@property (weak, nonatomic) IBOutlet UITextField *depthTextField;
@property (strong, nonatomic) NSDecimalNumberHandler *roundingBehavior;

@end

@interface WMPhotoDepthViewController (PrivateMethods)
- (void)updateModel;
@end

@implementation WMPhotoDepthViewController (PrivateMethods)

- (void)updateModel
{
    self.woundPhoto.measurementGroup.measurementValueDepth.value = self.depthTextField.text;
}

@end

@implementation WMPhotoDepthViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

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
    self.title = @"Depth (cm)";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.depthTextField.text = self.woundPhoto.measurementGroup.measurementValueDepth.value;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (isPad) {
        self.depthTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    [self.depthTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _roundingBehavior = nil;
}

#pragma mark - Core

- (BOOL)showCancelButton
{
    return NO;
}

- (NSDecimalNumberHandler *)roundingBehavior
{
    if (nil == _roundingBehavior) {
        _roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain
                                                                           scale:1
                                                                raiseOnExactness:NO
                                                                 raiseOnOverflow:NO
                                                                raiseOnUnderflow:NO
                                                             raiseOnDivideByZero:NO];
    }
    return _roundingBehavior;
}

- (NSDecimalNumber *)woundDepth
{
    if (0 == [self.depthTextField.text length]) {
        return [NSDecimalNumber zero];
    }
    // else
    return [[NSDecimalNumber decimalNumberWithString:self.depthTextField.text] decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self updateModel];
    [self.delegate photoDepthViewControllerDelegate:self depth:self.woundDepth];
}

@end
