//
//  WMWoundPhotoSlideShowViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/3/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMWoundPhotoSlideShowViewController.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMGridImageViewContainer.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

#define kImageFadeTimeInterval 0.5              // interval to fade top image to reveal next image
#define kMinimumTransitionSliderValue 1.0       // translates to 5 second transition
#define kMaximumTransitionSliderValue 5.0       // translates to 1 second transition
#define kHideNavigationAndToolbarInterval 4.0   // interval to hide navigation and toolbar

@interface WMWoundPhotoSlideShowViewController ()

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;

@property (weak, nonatomic) WMGridImageViewContainer *topImageView;          // imageView/date label on top
@property (weak, nonatomic) WMGridImageViewContainer *bottomImageView;       // imageView/date label under topImageView
@property (strong, nonatomic) IBOutlet UIView *woundPhotoWrapImageView;             // image to flash when we wrap to starting date

@property (readonly, nonatomic) BOOL nextWoundPhotoWillWrap;                        // YES if we are about to wrap

@property (strong, nonatomic) NSArray *sortedWoundPhotos;                           // cached sorted photo objectIDs
@property (nonatomic) BOOL photosTakenInLandscapeFlag;                              // YES is photos taken in landscape mode (needed for transform)
@property (strong, nonatomic) NSTimer *transitionImageTimer;                        // timer to transition to next (or first) image
@property (nonatomic) NSTimeInterval transitionTimeInterval;                        // calculated from transitionTimeIntervalSlider value
@property (strong, nonatomic) UISlider *transitionTimeIntervalSlider;               // slider in toobar to adjust the transition interval
@property (nonatomic) NSInteger woundPhotoIndex;                                    // index into sortedWoundPhotos of current photo
@property (readonly, nonatomic) WMWoundPhoto *nextWoundPhoto;                       // calculated next photo (may wrap to index 0)

@property (strong, nonatomic) NSTimer *hideBarsTimer;                               // timer to hide navigiation bar and toolbar

@end

@interface WMWoundPhotoSlideShowViewController (PrivateMethods)
- (void)incrementNextWoundPhotoIndex;
- (void)updatePhotosTakenInLandscapeFlag;
- (IBAction)transitionIntervalBeganChangeAction:(id)sender;
- (IBAction)transitionIntervalChangedAction:(id)sender;
- (void)handleTransitionTimerEvent:(NSTimer *)timer;
- (void)configureHideBarsTimer;
- (void)handleHideBarTimerEvent:(NSTimer *)timer;
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer;
@end

@implementation WMWoundPhotoSlideShowViewController (PrivateMethods)

- (void)incrementNextWoundPhotoIndex
{
    if ((self.woundPhotoIndex + 1) == [self.sortedWoundPhotos count]) {
        self.woundPhotoIndex = 0;
    } else {
        ++self.woundPhotoIndex;
    }
}

- (void)updatePhotosTakenInLandscapeFlag
{
    BOOL result = NO;
    for (NSManagedObjectID *objectID in self.sortedWoundPhotos) {
        WMWoundPhoto *woundPhoto = (WMWoundPhoto *)[self.managedObjectContext objectWithID:objectID];
        if (woundPhoto.landscapeOrientation) {
            result = YES;
            break;
        }
    }
    self.photosTakenInLandscapeFlag = result;
}

- (IBAction)transitionIntervalBeganChangeAction:(id)sender
{
    [self.transitionImageTimer invalidate];
    self.transitionImageTimer = nil;
    [self.hideBarsTimer invalidate];
    self.hideBarsTimer = nil;
    [self configureHideBarsTimer];
}

- (IBAction)transitionIntervalChangedAction:(id)sender
{
    self.transitionTimeInterval = -self.transitionTimeIntervalSlider.value + 6;
    // invalidate timer and restart
    [self.transitionImageTimer invalidate];
    self.transitionImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.transitionTimeInterval
                                                                 target:self
                                                               selector:@selector(handleTransitionTimerEvent:)
                                                               userInfo:nil
                                                                repeats:YES];
//    self.topImageView.frame = self.view.bounds;
//    self.bottomImageView.frame = self.view.bounds;
}

- (void)handleTransitionTimerEvent:(NSTimer *)timer
{
    if (self.nextWoundPhotoWillWrap) {
        // show wrap image
        self.woundPhotoWrapImageView.alpha = 1.0;
        self.woundPhotoWrapImageView.center = self.topImageView.center;
        [self.topImageView addSubview:self.woundPhotoWrapImageView];
    }
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:kImageFadeTimeInterval animations:^{
//        weakSelf.bottomImageView.frame = weakSelf.view.bounds;  // dont' understand how the views go to CGRectZero
//        weakSelf.topImageView.frame = weakSelf.view.bounds;     // dont' understand how the views go to CGRectZero
        weakSelf.topImageView.alpha = 0.0;
        weakSelf.bottomImageView.alpha = 1.0;
//        DLog(@"view:%@", weakSelf.view);
//        DLog(@"topImageView:%@, bottomImageView:%@", weakSelf.topImageView, weakSelf.bottomImageView);
//        DLog(@"topImageView.imageView:%@, bottomImageView.imageView:%@", weakSelf.topImageView.imageView, weakSelf.bottomImageView.imageView);
//        DLog(@"topImageView.imageView.image:%@, bottomImageView.imageView.image:%@", NSStringFromCGSize(weakSelf.topImageView.imageView.image.size), NSStringFromCGSize(weakSelf.bottomImageView.imageView.image.size));
    } completion:^(BOOL completed) {
        // make sure timer was not invalidate
        if (nil != weakSelf.transitionImageTimer) {
            //        DLog(@"woundPhoto index has completed drawing: %d", weakSelf.woundPhotoIndex + 1);
            // remove wrap image
            [weakSelf.woundPhotoWrapImageView removeFromSuperview];
            // restore the transforms
            weakSelf.topImageView.imageView.transform = CGAffineTransformIdentity;
            weakSelf.bottomImageView.imageView.transform = CGAffineTransformIdentity;
            // put the back (current nextWoundPhoto) woundPhoto into top view - this will apply the transform
            //        DLog(@"placing wound photo index  %d into top view", [weakSelf.sortedWoundPhotos indexOfObject:weakSelf.nextWoundPhoto]);
            weakSelf.topImageView.woundPhoto = weakSelf.nextWoundPhoto;
            // make it show
            weakSelf.topImageView.alpha = 1.0;
            // make the back image not show
            weakSelf.bottomImageView.alpha = 0.0;
            // increment for next woundPhoto
            [weakSelf incrementNextWoundPhotoIndex];
            // put the next woundPhoto into back - this will apply the transform
            //        DLog(@"placing wound photo index  %d into bottom view", [weakSelf.sortedWoundPhotos indexOfObject:weakSelf.nextWoundPhoto]);
            weakSelf.bottomImageView.woundPhoto = weakSelf.nextWoundPhoto;
        }
    }];
}

- (void)configureHideBarsTimer
{
    [self.hideBarsTimer invalidate];
    self.hideBarsTimer = [NSTimer scheduledTimerWithTimeInterval:kHideNavigationAndToolbarInterval
                                                          target:self
                                                        selector:@selector(handleHideBarTimerEvent:)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)handleHideBarTimerEvent:(NSTimer *)timer
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (nil == self.transitionImageTimer) {
        [self performSelector:@selector(transitionIntervalChangedAction:) withObject:self.transitionTimeIntervalSlider afterDelay:0.0];
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self configureHideBarsTimer];
}

@end

@implementation WMWoundPhotoSlideShowViewController

@synthesize delegate;
@synthesize topImageView=_topImageView, bottomImageView=_bottomImageView, woundPhotoWrapImageView=_woundPhotoWrapImageView;
@synthesize sortedWoundPhotos=_sortedWoundPhotos, photosTakenInLandscapeFlag;
@synthesize transitionImageTimer=_transitionImageTimer, transitionTimeIntervalSlider=_transitionTimeIntervalSlider, transitionTimeInterval=_transitionTimeInterval;
@dynamic nextWoundPhoto, nextWoundPhotoWillWrap;
@synthesize hideBarsTimer=_hideBarsTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure navigation
    self.title = self.patient.lastNameFirstName;
    // configure toolbar
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                         [[UIBarButtonItem alloc] initWithCustomView:self.transitionTimeIntervalSlider],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                         [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_grid.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)],
                         nil];
    // install bar show gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    // update orientation
    [self updatePhotosTakenInLandscapeFlag];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    // update imageViews
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    self.topImageView.configureForSlideShow = YES;
    self.bottomImageView.configureForSlideShow = YES;
    self.topImageView.displayOption = isPad ? WoundPhotoDisplayOptionFull:WoundPhotoDisplayOptionThumbnail;
    self.bottomImageView.displayOption = isPad ? WoundPhotoDisplayOptionFull:WoundPhotoDisplayOptionThumbnail;
    self.topImageView.applyWoundPhotoTransform = YES;
    self.bottomImageView.applyWoundPhotoTransform = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.topImageView.frame = self.view.bounds;
//    self.bottomImageView.frame = self.view.bounds;
    self.topImageView.woundPhoto = (WMWoundPhoto *)[self.managedObjectContext objectWithID:[self.sortedWoundPhotos objectAtIndex:0]];
    self.bottomImageView.woundPhoto = (WMWoundPhoto *)[self.managedObjectContext objectWithID:[self.sortedWoundPhotos objectAtIndex:1]];
    // get the ball rolling
    [self configureHideBarsTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_transitionImageTimer invalidate];
    _transitionImageTimer = nil;
    [_hideBarsTimer invalidate];
    _hideBarsTimer = nil;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _sortedWoundPhotos = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (self.photosTakenInLandscapeFlag ? UIInterfaceOrientationLandscapeLeft:UIInterfaceOrientationPortrait));
}

#pragma mark - Accessors

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

#pragma mark - Core

- (UISlider *)transitionTimeIntervalSlider
{
    if (nil == _transitionTimeIntervalSlider) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 16.0)];
        slider.minimumValue = kMinimumTransitionSliderValue;
        slider.maximumValue = kMaximumTransitionSliderValue;
        slider.value = kMinimumTransitionSliderValue;
        slider.minimumValueImage = [UIImage imageNamed:@"ui_turtle.png"];
        slider.maximumValueImage = [UIImage imageNamed:@"ui_rabbit.png"];
        slider.continuous = NO;
        [slider addTarget:self action:@selector(transitionIntervalBeganChangeAction:) forControlEvents:UIControlEventAllTouchEvents];
        [slider addTarget:self action:@selector(transitionIntervalChangedAction:) forControlEvents:UIControlEventValueChanged];
        _transitionTimeIntervalSlider = slider;
    }
    return _transitionTimeIntervalSlider;
}

- (NSArray *)sortedWoundPhotos
{
    if (nil == _sortedWoundPhotos) {
        _sortedWoundPhotos = self.wound.sortedWoundPhotoIDs;
    }
    return _sortedWoundPhotos;
}

- (WMWoundPhoto *)nextWoundPhoto
{
    NSInteger index = self.woundPhotoIndex + 1;
    if (index == [self.sortedWoundPhotos count]) {
        // at end of array
        index = 0;
    }
    // else
    return (WMWoundPhoto *)[self.managedObjectContext objectWithID:[self.sortedWoundPhotos objectAtIndex:index]];
}

- (BOOL)nextWoundPhotoWillWrap
{
    return (_woundPhotoIndex + 1) == [self.sortedWoundPhotos count];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [_transitionImageTimer invalidate];
    _transitionImageTimer = nil;
    [self.delegate woundPhotoSlideShowViewControllerDidFinish:self];
}

@end
