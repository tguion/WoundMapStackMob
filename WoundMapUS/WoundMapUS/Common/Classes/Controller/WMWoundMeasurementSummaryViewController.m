//
//  WMWoundMeasurementSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementSummaryViewController.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementGroup+CoreText.h"
#import "ConstraintPack.h"

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
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.woundMeasurementGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _selectedWound = nil;
    _woundMeasurementGroup = nil;
}

@end
