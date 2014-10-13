//
//  WMSkinAssessmentSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSkinAssessmentSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentGroup+CoreText.h"
#import "ConstraintPack.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kSkinAssessentGroupMaximumRecords 3

@interface WMSkinAssessmentSummaryViewController ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMSkinAssessmentSummaryViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@synthesize skinAssessmentGroup=_skinAssessmentGroup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Assessment Summary";
    // load text view
    UITextView *tv = [[UITextView alloc] initWithFrame:self.view.bounds];
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
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.skinAssessmentGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
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

#pragma mark - Core

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (void)clearDataCache
{
    _skinAssessmentGroup = nil;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    if (_drawFullHistory) {
        NSArray *skinAssessmentGroups = [WMSkinAssessmentGroup sortedSkinAssessmentGroups:self.appDelegate.navigationCoordinator.patient];
        NSInteger index = 0;
        for (WMSkinAssessmentGroup *skinAssessmentGroup in skinAssessmentGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[skinAssessmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kSkinAssessentGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.skinAssessmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
