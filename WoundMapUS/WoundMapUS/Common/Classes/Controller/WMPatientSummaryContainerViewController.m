//
//  WMPatientSummaryContainerViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientSummaryContainerViewController.h"
#import "WMPatientSummaryViewController.h"
#import "WMCarePlanSummaryViewController.h"
#import "WMSkinAssessmentSummaryViewController.h"
#import "WMMedicationSummaryViewController.h"
#import "WMDevicesSummaryViewController.h"
#import "WMPsychoSocialSummaryViewController.h"
#import "WMNutritionSummaryViewController.h"
#import "WMWoundMeasurementSummaryViewController.h"
#import "WMWoundTreatmentSummaryViewController.h"
#import "WMPatient.h"
#import "WMCarePlanGroup.h"
#import "WMSkinAssessmentGroup.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
#import "WMPsychoSocialGroup.h"
#import "WMNutritionGroup.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundTreatmentGroup.h"
#import "WMDesignUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

@interface WMPatientSummaryContainerViewController () <UIScrollViewDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMPatient *patient;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *noDataView;

@property (strong, nonatomic) NSMutableArray *viewTitles;

@property (strong, nonatomic) WMPatientSummaryViewController *patientSummaryViewController;
@property (strong, nonatomic) WMCarePlanSummaryViewController *carePlanSummaryViewController;
@property (strong, nonatomic) WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController;
@property (strong, nonatomic) WMMedicationSummaryViewController *medicationSummaryViewController;
@property (strong, nonatomic) WMDevicesSummaryViewController *devicesSummaryViewController;
@property (strong, nonatomic) WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController;
@property (strong, nonatomic) WMNutritionSummaryViewController *nutritionSummaryViewController;
@property (readonly, nonatomic) WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController;
@property (readonly, nonatomic) WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController;

- (IBAction)pageControlValueChangedAction:(id)sender;

- (void)showNoDataView;
- (void)hideNoDataView;

@end

@implementation WMPatientSummaryContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure navigation
    [self setEdgesForExtendedLayout:UIRectEdgeNone];    // don't understand why need this
    self.title = self.patient.lastNameFirstName;
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (!isPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // install child view controllers
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGRect frame = _scrollView.bounds;
    WMPatientSummaryViewController *patientSummaryViewController = self.patientSummaryViewController;
    if (patientSummaryViewController) {
        patientSummaryViewController.view.frame = frame;
        [self addChildViewController:patientSummaryViewController];
        [_scrollView addSubview:patientSummaryViewController.view];
        [patientSummaryViewController didMoveToParentViewController:self];
        patientSummaryViewController.automaticallyAdjustsScrollViewInsets = NO;
        [self.viewTitles addObject:@"Patient Details"];
        frame.origin.x += width;
    }
    WMCarePlanSummaryViewController *carePlanSummaryViewController = self.carePlanSummaryViewController;
    if (nil != carePlanSummaryViewController) {
        carePlanSummaryViewController.view.frame = frame;
        [self addChildViewController:carePlanSummaryViewController];
        [_scrollView addSubview:carePlanSummaryViewController.view];
        [carePlanSummaryViewController didMoveToParentViewController:self];
        carePlanSummaryViewController.automaticallyAdjustsScrollViewInsets = NO;
        [self.viewTitles addObject:@"Care Plan"];
        frame.origin.x += width;
    }
    WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController = self.skinAssessmentSummaryViewController;
    if (nil != skinAssessmentSummaryViewController) {
        skinAssessmentSummaryViewController.view.frame = frame;
        [self addChildViewController:skinAssessmentSummaryViewController];
        [_scrollView addSubview:skinAssessmentSummaryViewController.view];
        [skinAssessmentSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:@"Skin Assessment"];
        frame.origin.x += width;
    }
    WMMedicationSummaryViewController *medicationSummaryViewController = self.medicationSummaryViewController;
    if (nil != medicationSummaryViewController) {
        medicationSummaryViewController.view.frame = frame;
        [self addChildViewController:medicationSummaryViewController];
        [_scrollView addSubview:medicationSummaryViewController.view];
        [medicationSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:@"Risk Assessment - Medications"];
        frame.origin.x += width;
    }
    WMNutritionSummaryViewController *nutritionSummaryViewController = self.nutritionSummaryViewController;
    if (nil != nutritionSummaryViewController) {
        nutritionSummaryViewController.view.frame = frame;
        [self addChildViewController:nutritionSummaryViewController];
        [_scrollView addSubview:nutritionSummaryViewController.view];
        [nutritionSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:@"Risk Assessment - Nutrition"];
        frame.origin.x += width;
    }
    WMDevicesSummaryViewController *devicesSummaryViewController = self.devicesSummaryViewController;
    if (nil != devicesSummaryViewController) {
        devicesSummaryViewController.view.frame = frame;
        [self addChildViewController:devicesSummaryViewController];
        [_scrollView addSubview:devicesSummaryViewController.view];
        [devicesSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:@"Risk Assessment - Devices"];
        frame.origin.x += width;
    }
    // Risk Assessment - Psycho/Social
    WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController = self.psychoSocialSummaryViewController;
    if (nil != psychoSocialSummaryViewController) {
        psychoSocialSummaryViewController.view.frame = frame;
        [self addChildViewController:psychoSocialSummaryViewController];
        [_scrollView addSubview:psychoSocialSummaryViewController.view];
        [psychoSocialSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:@"Risk Assessment - Psychosocial"];
        frame.origin.x += width;
    }
    // Wound Assessment
    NSArray *sortedWounds = self.patient.sortedWounds;
    for (WMWound *wound in sortedWounds) {
        if ([WMWoundMeasurementGroup woundMeasurementGroupsCountForWound:wound] == 0) {
            continue;
        }
        // else
        WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController = self.woundMeasurementSummaryViewController;
        woundMeasurementSummaryViewController.selectedWound = wound;
        woundMeasurementSummaryViewController.view.frame = frame;
        [self addChildViewController:woundMeasurementSummaryViewController];
        [_scrollView addSubview:woundMeasurementSummaryViewController.view];
        [woundMeasurementSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:[NSString stringWithFormat:@"%@ - Wound Assessment", wound.shortName]];
        frame.origin.x += width;
    }
    // Wound Treatment
    for (WMWound *wound in sortedWounds) {
        if (0 == wound.woundTreatmentGroupCount) {
            continue;
        }
        // else
        WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController = self.woundTreatmentSummaryViewController;
        woundTreatmentSummaryViewController.selectedWound = wound;
        woundTreatmentSummaryViewController.view.frame = frame;
        [self addChildViewController:woundTreatmentSummaryViewController];
        [_scrollView addSubview:woundTreatmentSummaryViewController.view];
        [woundTreatmentSummaryViewController didMoveToParentViewController:self];
        [self.viewTitles addObject:[NSString stringWithFormat:@"%@ - Wound Treatment", wound.shortName]];
        frame.origin.x += width;
    }
    if ([self.viewTitles count] > 0) {
        [self hideNoDataView];
        self.viewTitleLabel.text = [self.viewTitles firstObject];
        _scrollView.contentSize = CGSizeMake(CGRectGetMinX(frame), CGRectGetHeight(_scrollView.frame));
        _pageControl.numberOfPages = [self.viewTitles count];
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0x6A6A6A);
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xD2D2D2);
    } else {
        [self showNoDataView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (NSMutableArray *)viewTitles
{
    if (nil == _viewTitles) {
        _viewTitles = [[NSMutableArray alloc] init];
    }
    return _viewTitles;
}

- (WMPatientSummaryViewController *)patientSummaryViewController
{
    if (nil == _patientSummaryViewController) {
        if (self.patient.hasPatientDetails) {
            _patientSummaryViewController = [[WMPatientSummaryViewController alloc] initWithNibName:@"WMPatientSummaryViewController" bundle:nil];
            _patientSummaryViewController.patient = self.patient;
        }
    }
    return _patientSummaryViewController;
}

- (WMCarePlanSummaryViewController *)carePlanSummaryViewController
{
    if (nil == _carePlanSummaryViewController) {
        if ([WMCarePlanGroup carePlanGroupsCount:self.patient]) {
            _carePlanSummaryViewController = [[WMCarePlanSummaryViewController alloc] initWithNibName:@"WMCarePlanSummaryViewController" bundle:nil];
            _carePlanSummaryViewController.drawFullHistory = YES;
        }
    }
    return _carePlanSummaryViewController;
}

- (WMSkinAssessmentSummaryViewController *)skinAssessmentSummaryViewController
{
    if (nil == _skinAssessmentSummaryViewController) {
        if ([WMSkinAssessmentGroup skinAssessmentGroupsCount:self.patient]) {
            _skinAssessmentSummaryViewController = [[WMSkinAssessmentSummaryViewController alloc] initWithNibName:@"WMSkinAssessmentSummaryViewController" bundle:nil];
            _skinAssessmentSummaryViewController.drawFullHistory = YES;
        }
    }
    return _skinAssessmentSummaryViewController;
}

- (WMMedicationSummaryViewController *)medicationSummaryViewController
{
    if (nil == _medicationSummaryViewController) {
        if ([WMMedicationGroup medicalGroupsCount:self.patient]) {
            _medicationSummaryViewController = [[WMMedicationSummaryViewController alloc] initWithNibName:@"WMMedicationSummaryViewController" bundle:nil];
            _medicationSummaryViewController.drawFullHistory = YES;
        }
    }
    return _medicationSummaryViewController;
}

- (WMDevicesSummaryViewController *)devicesSummaryViewController
{
    if (nil == _devicesSummaryViewController) {
        if ([WMDeviceGroup deviceGroupsCount:self.patient]) {
            _devicesSummaryViewController = [[WMDevicesSummaryViewController alloc] initWithNibName:@"WMDevicesSummaryViewController" bundle:nil];
            _devicesSummaryViewController.drawFullHistory = YES;
        }
    }
    return _devicesSummaryViewController;
}

- (WMPsychoSocialSummaryViewController *)psychoSocialSummaryViewController
{
    if ([WMPsychoSocialGroup psychoSocialGroupsCount:self.patient]) {
        _psychoSocialSummaryViewController = [[WMPsychoSocialSummaryViewController alloc] initWithNibName:@"WMPsychoSocialSummaryViewController" bundle:nil];
        _psychoSocialSummaryViewController.drawFullHistory = YES;
    }
    return _psychoSocialSummaryViewController;
}

- (WMNutritionSummaryViewController *)nutritionSummaryViewController
{
    if ([WMNutritionGroup nutritionGroupsCount:self.patient]) {
        _nutritionSummaryViewController = [[WMNutritionSummaryViewController alloc] initWithNibName:@"WMNutritionSummaryViewController" bundle:nil];
        _nutritionSummaryViewController.drawFullHistory = YES;
    }
    return _nutritionSummaryViewController;
}

- (WMWoundMeasurementSummaryViewController *)woundMeasurementSummaryViewController
{
    return [[WMWoundMeasurementSummaryViewController alloc] initWithNibName:@"WMWoundMeasurementSummaryViewController" bundle:nil];
}

- (WMWoundTreatmentSummaryViewController *)woundTreatmentSummaryViewController
{
    return [[WMWoundTreatmentSummaryViewController alloc] initWithNibName:@"WMWoundTreatmentSummaryViewController" bundle:nil];
}

#pragma mark - Core

- (void)showNoDataView
{
    if (nil != self.noDataView.superview) {
        return;
    }
    // else
    self.noDataView.frame = self.view.bounds;
    [self.view addSubview:self.noDataView];
}

- (void)hideNoDataView
{
    if (nil == self.noDataView.superview) {
        return;
    }
    // else
    [self.noDataView removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

// any offset changes
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = rintf(scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame));
    self.pageControl.currentPage = currentPage;
    self.viewTitleLabel.text = [self.viewTitles objectAtIndex:self.pageControl.currentPage];
}

#pragma mark - Actions

- (IBAction)pageControlValueChangedAction:(id)sender
{
    CGFloat pageWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat pageHeight = CGRectGetHeight(_scrollView.frame);
    [_scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * CGRectGetWidth(_scrollView.frame), 0.0, pageWidth, pageHeight) animated:YES];
    self.viewTitleLabel.text = [self.viewTitles objectAtIndex:self.pageControl.currentPage];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate patientSummaryContainerViewControllerDidFinish:self];
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (0 == [self.childViewControllers count]) {
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        return;
    }
    // else
    _scrollView.delegate = nil;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (0 == [self.childViewControllers count]) {
        return;
    }
    // else
    CGFloat width = CGRectGetWidth(_scrollView.bounds);
    CGFloat height = CGRectGetHeight(_scrollView.bounds);
    CGRect frame = _scrollView.bounds;
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    for (UIViewController *viewController in self.childViewControllers) {
        viewController.view.frame = frame;
        frame.origin.x += width;
    }
    _scrollView.contentSize = CGSizeMake(_pageControl.numberOfPages * width, height);
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_pageControl.currentPage];
    [_scrollView scrollRectToVisible:viewController.view.frame animated:YES];
    _scrollView.delegate = self;
}

@end
