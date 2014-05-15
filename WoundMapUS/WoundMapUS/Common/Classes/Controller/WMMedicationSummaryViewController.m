//
//  WMMedicationSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMMedicationSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMMedicationGroup.h"
#import "WMMedicationGroup+CoreText.h"
#import "WMFatFractal.h"
#import "ConstraintPack.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

#define kMedicationGroupMaximumRecords 3

@interface WMMedicationSummaryViewController ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMMedicationSummaryViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Medication Summary";
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
    [ff getObjFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.medicationGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        [weakSelf updateText];
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

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (void)clearDataCache
{
    _medicationGroup = nil;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    if (_drawFullHistory) {
        NSArray *medicationGroups = [WMMedicationGroup sortedMedicationGroups:self.appDelegate.navigationCoordinator.patient];
        NSInteger index = 0;
        for (WMMedicationGroup *medicationGroup in medicationGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[medicationGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kMedicationGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.medicationGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
