//
//  WMWoundTreatmentSummaryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundTreatmentSummaryViewController.h"
#import "WMWound.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMWound.h"
#import "ConstraintPack.h"

#define kWoundTreatmentGroupMaximumRecords 3

@interface WMWoundTreatmentSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@interface WMWoundTreatmentSummaryViewController ()

@end

@implementation WMWoundTreatmentSummaryViewController

@synthesize woundTreatmentGroup=_woundTreatmentGroup, selectedWound=_selectedWound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Treatment Summary";
    self.automaticallyAdjustsScrollViewInsets = NO;
    // load text view
    UITextView* tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    tv.editable = NO;
    [self.view addSubview:tv];
    self.textView = tv;
    // add constraints
    PREPCONSTRAINTS(tv);
    StretchToSuperview(tv, 0.0, 500);
    [self.view layoutSubviews]; // You must call this method here or the system raises an exception
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
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
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.woundTreatmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
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

@end
