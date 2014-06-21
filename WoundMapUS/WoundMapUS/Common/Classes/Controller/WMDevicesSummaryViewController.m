//
//  WMDevicesSummaryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDevicesSummaryViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMDeviceGroup.h"
#import "WMDeviceGroup+CoreText.h"
#import "ConstraintPack.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kDeviceGroupMaximumRecords 3

@interface WMDevicesSummaryViewController ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMNavigationCoordinator *navigationCoordinator;
@property (weak, nonatomic) UITextView *textView;
@end

@implementation WMDevicesSummaryViewController

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
    self.title = @"Devices Summary";
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
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.deviceGroups] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
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
    _devicesGroup = nil;
}

- (void)updateText
{
    NSMutableAttributedString *descriptionAsMutableAttributedStringWithBaseFontSize = [[NSMutableAttributedString alloc] init];
    if (_drawFullHistory) {
        NSArray *deviceGroups = [WMDeviceGroup sortedDeviceGroups:self.navigationCoordinator.patient];
        NSInteger index = 0;
        for (WMDeviceGroup *deviceGroup in deviceGroups) {
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[deviceGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
            if (++index == kDeviceGroupMaximumRecords) {
                break;
            }
            // else
            [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    } else {
        [descriptionAsMutableAttributedStringWithBaseFontSize appendAttributedString:[self.devicesGroup descriptionAsMutableAttributedStringWithBaseFontSize:12]];
    }
    self.textView.attributedText = descriptionAsMutableAttributedStringWithBaseFontSize;
}

@end
