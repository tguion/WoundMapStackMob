//
//  WMPsychoSocialSummaryViewController.m
//  WoundMAP
//
//  Created by Todd Guion on 11/26/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPsychoSocialSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMPsychoSocialGroup.h"
#import "WMPsychoSocialGroup+CoreText.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "ConstraintPack.h"
#import "WMUtilities.h"

#define kPsychoSocialGroupMaximumRecords 3

@interface WMPsychoSocialSummaryViewController ()
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMPsychoSocialSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Psychosocial Summary";
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
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.psychosocialGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
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

- (WMPatient *)patient
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.navigationCoordinator.patient;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    WMPatient *patient = appDelegate.navigationCoordinator.patient;
    if (_drawFullHistory) {
        NSArray *psychoSocialGroups = [WMPsychoSocialGroup sortedPsychoSocialGroups:patient];
        NSInteger index = 0;
        for (WMPsychoSocialGroup *psychoSocialGroup in psychoSocialGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[psychoSocialGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kPsychoSocialGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.psychoSocialGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
