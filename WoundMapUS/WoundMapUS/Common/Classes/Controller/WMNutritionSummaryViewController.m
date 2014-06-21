//
//  WMNutritionSummaryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/22/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNutritionSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMNutritionGroup.h"
#import "WMNutritionGroup+CoreText.h"
#import "ConstraintPack.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kNutritionGroupMaximumRecords 3

@interface WMNutritionSummaryViewController ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMNavigationCoordinator *navigationCoordinator;
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMNutritionSummaryViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMNavigationCoordinator *)navigationCoordinator
{
    return self.appDelegate.navigationCoordinator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Nutrition Summary";
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
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.nutritionGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
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

#pragma mark - BaseViewController

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (void)clearDataCache
{
    _nutritionGroup = nil;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    if (_drawFullHistory) {
        NSArray *nutritionGroups = [WMNutritionGroup sortedNutritionGroups:self.navigationCoordinator.patient];
        NSInteger index = 0;
        for (WMNutritionGroup *nutritionGroup in nutritionGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[nutritionGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kNutritionGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.nutritionGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
