//
//  WMWoundTreatmentSummaryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundTreatmentSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMFatFractal.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "ConstraintPack.h"

#define kWoundTreatmentGroupMaximumRecords 3

@interface WMWoundTreatmentSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMWoundTreatmentSummaryViewController

@synthesize woundTreatmentGroup=_woundTreatmentGroup, selectedWound=_selectedWound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Treatment Summary";
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
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", wound.ffUrl, WMWoundRelationships.treatmentGroups] onComplete:onComplete];
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
    [self clearDataCache];
}

#pragma mark - Core

- (void)clearDataCache
{
    _selectedWound = nil;
    _woundTreatmentGroup = nil;
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
        NSArray *woundTreatmentGroups = [self.selectedWound sortedWoundTreatmentsAscending:NO];
        NSInteger index = 0;
        for (WMWoundTreatmentGroup *woundTreatmentGroup in woundTreatmentGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[woundTreatmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kWoundTreatmentGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else if (self.woundTreatmentGroup) {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.woundTreatmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
