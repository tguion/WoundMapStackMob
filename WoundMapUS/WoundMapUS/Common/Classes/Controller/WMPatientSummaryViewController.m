//
//  WMPatientSummaryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMPatient+CoreText.h"
#import "WMMedicalHistoryGroup.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMFatFractal.h"
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
    // load text view
    UITextView* tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    tv.editable = NO;
    [self.view addSubview:tv];
    self.textView = tv;
    // add constraints
    PREPCONSTRAINTS(tv);
    StretchToSuperview(tv, 0.0, 500);
    [self.view layoutSubviews]; // You must call this method here or the system raises an exception
    // make sure we have data
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.medicalHistoryGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        weakSelf.textView.attributedText = [patient descriptionAsMutableAttributedStringWithBaseFontSize:12];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
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
