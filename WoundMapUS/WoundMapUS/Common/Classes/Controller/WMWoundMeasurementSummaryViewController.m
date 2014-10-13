//
//  WMWoundMeasurementSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementGroup+CoreText.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "ConstraintPack.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

#define kWoundMeasurementGroupMaximumRecords 3

@interface WMWoundMeasurementSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMWoundMeasurementSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Assessment Summary";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
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
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
            [weakSelf updateText];
        }
    };
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.wounds] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        counter = [patient.wounds count];
        for (WMWound *wound in patient.wounds) {
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", wound.ffUrl, WMWoundRelationships.measurementGroups] onComplete:onComplete];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _selectedWound = nil;
    _woundMeasurementGroup = nil;
}

- (WMPatient *)patient
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.navigationCoordinator.patient;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    BOOL drawFullHistory = (nil != self.selectedWound);
    if (drawFullHistory) {
        NSArray *woundMeasurementGroups = [self.selectedWound sortedWoundMeasurementsAscending:NO];
        NSInteger index = 0;
        for (WMWoundMeasurementGroup *woundMeasurementGroup in woundMeasurementGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[woundMeasurementGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kWoundMeasurementGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else if (self.woundMeasurementGroup) {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.woundMeasurementGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

- (IBAction)doneAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
