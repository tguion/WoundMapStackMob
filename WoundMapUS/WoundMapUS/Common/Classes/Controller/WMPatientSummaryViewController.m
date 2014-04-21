//
//  WMPatientSummaryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientSummaryViewController.h"
#import "WMPatient.h"
#import "WMPatient+CoreText.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "ConstraintPack.h"

@interface WMPatientSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMPatientSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Patient Detail Summary";
    self.automaticallyAdjustsScrollViewInsets = NO;
    // load text view
    UITextView* tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    tv.editable = NO;
    [self.view addSubview:tv];
    self.textView = tv;
    // add constraints
    PREPCONSTRAINTS(tv);
    StretchToSuperview(tv, 0.0, 500);
    id topGuide = self.topLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (tv, topGuide);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[tv]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view layoutSubviews]; // You must call this method here or the system raises an exception
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.textView.attributedText = [self.patient descriptionAsMutableAttributedStringWithBaseFontSize:12];
}

- (WMPatient *)patient
{
    if (nil == _patient) {
        WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
        _patient = appDelegate.navigationCoordinator.patient;
    }
    return _patient;
}

@end
