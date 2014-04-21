//
//  WMCarePlanSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/4/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanSummaryViewController.h"
#import "WMPatient.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanGroup+CoreText.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "ConstraintPack.h"

#define kCarePlanMaximumRecords 4.0

@interface WMCarePlanSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMCarePlanSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Care Plan Summary";
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
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    if (self.drawFullHistory) {
        WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
        WMPatient *patient = appDelegate.navigationCoordinator.patient;
        NSArray *carePlanGroups = [WMCarePlanGroup sortedCarePlanGroups:patient];
        NSInteger index = 0;
        for (WMCarePlanGroup *carePlanGroup in carePlanGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[carePlanGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kCarePlanMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.carePlanGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
