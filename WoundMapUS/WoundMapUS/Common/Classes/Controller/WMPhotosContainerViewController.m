//
//  WMPhotosContainerViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/22/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotosContainerViewController.h"
#import "WMWoundMeasurementSummaryViewController.h"
#import "WMPhotoGridViewController.h"
#import "WMWoundPhotoViewController.h"
#import "WMComparePhotosViewController.h"
#import "WMPhotoZoomViewController.h"
#import "WMTransformPhotoViewController.h"
#import "WMSelectWoundPhotoForDateController.h"
#import "MBProgressHUD.h"
#import "WMImageScrollView.h"
#import "WMWoundMeasurementLabel.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMPhotoManager.h"
#import "WMPDFPrintManager.h"
#import "WMUserDefaultsManager.h"
#import "WMUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "Faulter.h"
#import "WCAppDelegate.h"

#define kWaitingForTilingToFinishAlertTag 1001
#define kMeasureActionClosedAlertTag 1002
#define kDeletePhotoActionSheetTag 1000

@interface WMPhotosContainerViewController ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;

@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;  // observers that do away when the view dissappears

@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;
@property (strong, nonatomic) NSManagedObjectID *woundPhoto1ObjectID;                               // objectID for woundPhoto for date compare
@property (strong, nonatomic) NSManagedObjectID *woundPhoto2ObjectID;                               // objectID for woundPhoto for date compare
@property (strong, nonatomic) NSArray *cachedSortedWoundPhotos;                                     // cached sorted WMWoundPhotos objectIDs for self.wound
@property (readonly, nonatomic) WMWoundPhoto *lastCachedWoundPhoto;                                 // last cached wound photo TODO: use objectID
@property (strong, nonatomic) WMPhotoGridViewController *photoGridViewController;                     // grid (UICollectionViewController) child view controller
@property (strong, nonatomic) UIPageViewController *photoPageViewController;                        // paging/scrolling (UIPageViewController) child view controller
@property (strong, nonatomic) WMComparePhotosViewController *compareViewController;                   // compare two photos child view controller
@property (strong, nonatomic) WMPhotoZoomViewController *photoZoomViewController;                     // full screen photo viewer zoom/tiled
@property (readonly, nonatomic) WMWoundPhotoSlideShowViewController *slideShowController;             // slide show view controller
@property (strong, nonatomic) UIBarButtonItem *segmentControlBarButtonItem;                         // bar button item hosting segmented control
@property (nonatomic) BOOL selectingWoundPhotoForDate1;                                             // true if selecting date1 wound photo
@property (strong, nonatomic) NSArray *toolbarItemsForBrowsePhotos;                                 // grid, page, date, play
@property (strong, nonatomic) NSArray *toolbarItemsForZoom;                                         // Photo/Assessment + (grid,page,date,play)
@property (nonatomic) BOOL shouldResetPhotoAssessmentSegmentedControlOnViewDidAppear;               // Measure wound returns
@property (strong, nonatomic) UIPopoverController *selectWoundPhotoByDatePopoverController;
@property (readonly, nonatomic) BOOL showingMeasurementsViewController;

@end

@interface WMPhotosContainerViewController (PrivateMethods)

- (void)updateToolbarItems;
- (void)updateToolbar;
- (void)installGridViewController;
- (void)installPageViewController;
- (void)installCompareDateViewController;
- (void)installPhotoZoomViewController:(BOOL)useTransition;
- (void)installSlideShowController;
- (void)presentMeasurementGroupViewController;
- (void)uninstallCurrentChildViewController;
- (WMWoundPhotoViewController *)woundPhotoViewControllerForWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID;
- (void)kickStartPhotoPageViewController;
- (void)updateViewForNewImage;
- (void)updateImageViewAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)indexOfWoundPhoto:(WMWoundPhoto *)woundPhoto;

@end

@implementation WMPhotosContainerViewController (PrivateMethods)

- (void)updateToolbarItems
{
    if (self.isStateZoom) {
        self.toolbarItems = self.toolbarItemsForZoom;
    } else {
        self.toolbarItems = self.toolbarItemsForBrowsePhotos;
    }
}

- (void)updateToolbar
{
    [self updateToolbarItems];
    BOOL hideToolbarFlag = NO;
    if (self.patient) {
        switch (self.state) {
            case PhotosContainerViewControllerStateGrid: {
                hideToolbarFlag = ([WMWound woundPhotoCountForWound:self.wound] < 2 ? YES:NO);
                break;
            }
            case PhotosContainerViewControllerStatePage: {
                // nothing
                break;
            }
            case PhotosContainerViewControllerStateDateCompare: {
                // nothing
                break;
            }
            case PhotosContainerViewControllerStateNone: {
                hideToolbarFlag = YES;
                break;
            }
            case PhotosContainerViewControllerStateZoom: {
                // nothing
                break;
            }
            case PhotosContainerViewControllerStateSlideShow: {
                // nothing
                break;
            }
            case PhotosContainerViewControllerStateGraph: {
                // nothing
                break;
            }
        }
    } else {
        hideToolbarFlag = YES;
    }
    [self.navigationController setToolbarHidden:hideToolbarFlag animated:YES];
}

- (void)installGridViewController
{
    if (self.isStateGrid) {
        return;
    }
    // else animate back if showing zoom controller
    if (self.isStateZoom) {
        UIImageView *anImageView = [[UIImageView alloc] initWithImage:self.woundPhoto.thumbnail];
        CGRect aFrame = self.photoZoomViewController.scrollView.frame;
        aFrame = [self.view convertRect:aFrame fromView:self.photoZoomViewController.view];
        anImageView.frame = aFrame;
        [self.view addSubview:anImageView];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2
                         animations:^{
                             // show the image back
                             anImageView.frame = [weakSelf.view convertRect:weakSelf.photoZoomViewController.initialFrame fromView:weakSelf.photoZoomViewController.view];
                         } completion:^(BOOL finished){
                             [anImageView removeFromSuperview];
                             [weakSelf.photoGridViewController.collectionView reloadData];
                         }];
    }
    self.previousState = self.state;
    self.state = PhotosContainerViewControllerStateGrid;
    self.photoGridViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.photoGridViewController];
    [self.view addSubview:self.photoGridViewController.view];
    [self.photoGridViewController didMoveToParentViewController:self];
    [self removeCurrentChildViewControllerFromParentViewController];
    self.currentChildViewController = self.photoGridViewController;
    self.gridScrollSegmentedControl.selectedSegmentIndex = 0;
    self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
    [self updateToolbar];
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)installPageViewController
{
    if (self.isStatePage) {
        return;
    }
    // else
    self.previousState = self.state;
    self.state = PhotosContainerViewControllerStatePage;
    CGRect frame = CGRectMake(0.0, self.topLayoutGuide.length, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
    self.photoPageViewController.view.frame = frame;
    [self addChildViewController:self.photoPageViewController];
    [self.view addSubview:self.photoPageViewController.view];
    [self.photoPageViewController didMoveToParentViewController:self];
    [self removeCurrentChildViewControllerFromParentViewController];
    self.currentChildViewController = self.photoPageViewController;
    // kick things off by making the first page
    [self performSelector:@selector(kickStartPhotoPageViewController) withObject:nil afterDelay:0.0];
}

- (void)installCompareDateViewController
{
    if (self.isStateDateCompare) {
        return;
    }
    // else
    self.previousState = self.state;
    self.state = PhotosContainerViewControllerStateDateCompare;
    // adjust for insets
    CGRect frame = CGRectMake(0.0, self.topLayoutGuide.length, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
    self.compareViewController.view.frame = frame;
    [self addChildViewController:self.compareViewController];
    [self.view addSubview:self.compareViewController.view];
    [self.compareViewController didMoveToParentViewController:self];
    [self removeCurrentChildViewControllerFromParentViewController];
    self.currentChildViewController = self.compareViewController;
}

- (void)installPhotoZoomViewController:(BOOL)useTransition
{
    if (self.isStateZoom) {
        return;
    }
    // else
    self.previousState = self.state;
    self.state = PhotosContainerViewControllerStateZoom;
    self.photoZoomViewController.view.alpha = 1.0;
    // dump cache - may or may not be able to delete the photo
    self.toolbarItemsForZoom = nil;
    if (useTransition) {
        [self addChildViewController:self.photoZoomViewController];
        __weak __typeof(&*self)weakSelf = self;
        [self transitionFromViewController:self.currentChildViewController toViewController:self.photoZoomViewController
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{
                                    weakSelf.photoZoomViewController.view.frame = weakSelf.view.bounds;
                                } completion:^(BOOL finished) {
                                    [weakSelf.photoZoomViewController didMoveToParentViewController:weakSelf];
                                    weakSelf.photoZoomViewController.woundMeasurementLabel.hidden = YES;
                                    [weakSelf removeCurrentChildViewControllerFromParentViewController];
                                    weakSelf.currentChildViewController = weakSelf.photoZoomViewController;
                                    [weakSelf updateToolbar];
                                    // configure navigation
                                    [weakSelf configureNavigation];
                                    // send notification the transform view was removed
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kTransformControllerDidUninstallNotification object:nil];
                                }];
    } else {
        //        CGRect frame = CGRectMake(0.0, self.topLayoutGuide.length, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
        self.photoZoomViewController.view.frame = self.view.bounds;
        [self addChildViewController:self.photoZoomViewController];
        // make zoom view invisible
        self.photoZoomViewController.view.alpha = 0.0;
        [self.view addSubview:self.photoZoomViewController.view];
        [self.photoZoomViewController didMoveToParentViewController:self];
        [self removeCurrentChildViewControllerFromParentViewController];
        self.currentChildViewController = self.photoZoomViewController;
        // animate in the image
        UIImageView *anImageView = [[UIImageView alloc] initWithImage:self.woundPhoto.thumbnail];
        anImageView.contentMode = UIViewContentModeScaleAspectFit;
        // self.photoZoomViewController.initialFrame in window coordinates
        CGRect aFrame = [self.view convertRect:self.photoZoomViewController.initialFrame fromView:nil];
        anImageView.frame = aFrame;
        [self.view addSubview:anImageView];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.5
                         animations:^{
                             CGRect targetFrame = [weakSelf.photoZoomViewController targetFrameInView:weakSelf.view];
                             anImageView.frame = targetFrame;
                         } completion:^(BOOL finished) {
                             weakSelf.photoZoomViewController.view.alpha = 1.0;
                             [anImageView removeFromSuperview];
                             [weakSelf updateToolbar];
                             // configure navigation
                             [weakSelf configureNavigation];
                         }];
    }
    // clean-up
    self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
}

- (void)installSlideShowController
{
    //    self.previousState = self.state;
    //    self.state = PhotosContainerViewControllerStateSlideShow;
    // present as modal
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.slideShowController];
    [self.navigationController presentViewController:navigationController
                                            animated:YES
                                          completion:^{
                                              //                                              self.state = PhotosContainerViewControllerStateSlideShow;
                                          }];
}

- (void)presentMeasurementGroupViewController
{
    // save document before presenting controller
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    UIViewController *viewController = nil;
    NSAssert(nil != self.woundPhoto, @"%@.woundPhoto is nil - cannot present measurements controller", NSStringFromClass([self class]));
    WMWoundMeasurementGroup *woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto create:NO];
    if (woundMeasurementGroup.isClosed) {
        WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController = self.woundMeasurementSummaryViewController;
        woundMeasurementSummaryViewController.woundMeasurementGroup = woundMeasurementGroup;
        viewController = woundMeasurementSummaryViewController;
    } else {
        NSAssert(nil != self.wound, @"%@.wound is nil - cannot present measurements controller", NSStringFromClass([self class]));
        viewController = self.measurementGroupViewController;
    }
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:^{
        // nothing
    }];
}

- (void)uninstallCurrentChildViewController
{
    if (nil == self.currentChildViewController) {
        return;
    }
    // else
    [self removeCurrentChildViewControllerFromParentViewController];
}

- (WMWoundPhotoViewController *)woundPhotoViewControllerForWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID
{
    WMWoundPhotoViewController *viewController = [[WMWoundPhotoViewController alloc] initWithNibName:@"WMWoundPhotoViewController" bundle:nil];
    viewController.woundPhotoObjectID = woundPhotoObjectID;
    return viewController;
}

- (void)kickStartPhotoPageViewController
{
    self.photoPageViewController.dataSource = self;
    NSArray *objectIDs = self.cachedSortedWoundPhotos;
    NSManagedObjectID *woundPhotoObjectID = [objectIDs count] > 0 ? [objectIDs firstObject]:nil;
    if (nil != woundPhotoObjectID) {
        WMWoundPhotoViewController *pageZero = [self woundPhotoViewControllerForWoundPhotoObjectID:woundPhotoObjectID];
        [self.photoPageViewController setViewControllers:@[pageZero]
                                               direction:UIPageViewControllerNavigationDirectionForward
                                                animated:NO
                                              completion:NULL];
    }
}

- (void)updateViewForNewImage
{
    switch (self.state) {
        case PhotosContainerViewControllerStateGrid: {
            [self.photoGridViewController.collectionView reloadData];
            break;
        }
        case PhotosContainerViewControllerStatePage: {
            // navigate to new image
            WMWoundPhotoViewController *pageLast = [self woundPhotoViewControllerForWoundPhotoObjectID:[self.cachedSortedWoundPhotos lastObject]];
            [self.photoPageViewController setViewControllers:@[pageLast]
                                                   direction:UIPageViewControllerNavigationDirectionForward
                                                    animated:YES
                                                  completion:NULL];
            
            break;
        }
        case PhotosContainerViewControllerStateDateCompare: {
            [self.compareViewController.collectionView reloadData];
            break;
        }
        case PhotosContainerViewControllerStateNone: {
            // reinstall grid
            [self installGridViewController];
            break;
        }
        case PhotosContainerViewControllerStateZoom: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateSlideShow: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateGraph: {
            // nothing
            break;
        }
    }
}

- (void)updateImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.state) {
        case PhotosContainerViewControllerStateGrid: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStatePage: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateDateCompare: {
            UICollectionViewCell *cell = [self.compareViewController.collectionView cellForItemAtIndexPath:indexPath];
            [self.compareViewController configureCell:cell atIndexPath:indexPath];
            break;
        }
        case PhotosContainerViewControllerStateNone: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateZoom: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateSlideShow: {
            // nothing
            break;
        }
        case PhotosContainerViewControllerStateGraph: {
            // nothing
            break;
        }
    }
}

- (NSInteger)indexOfWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSInteger index = NSNotFound;
    if (nil != woundPhoto) {
        NSManagedObjectID *objectID = [woundPhoto objectID];
        index = [self.cachedSortedWoundPhotos indexOfObject:objectID];
    }
    return index;
}

@end

@implementation WMPhotosContainerViewController

@dynamic managedObjectContext;
@synthesize woundPhotoDate1=_woundPhotoDate1, woundPhotoDate2=_woundPhotoDate2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        [self setHidesBottomBarWhenPushed:NO];
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Done or Home
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigation];
    if (self.isStateGrid) {
        [self.photoGridViewController.collectionView reloadData];
    }
    [self updateToolbar];
    [self registerForNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldResetPhotoAssessmentSegmentedControlOnViewDidAppear) {
        self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
        self.shouldResetPhotoAssessmentSegmentedControlOnViewDidAppear = NO;
    }
    if (self.isStateNone) {
        switch (self.previousState) {
            case PhotosContainerViewControllerStateGrid: {
                [self installGridViewController];
                break;
            }
            case PhotosContainerViewControllerStatePage: {
                [self installPageViewController];
                break;
            }
            case PhotosContainerViewControllerStateDateCompare: {
                [self installCompareDateViewController];
                break;
            }
            case PhotosContainerViewControllerStateNone: {
                [self installGridViewController];
                break;
            }
            case PhotosContainerViewControllerStateZoom: {
                [self installPhotoZoomViewController:NO];
                break;
            }
            case PhotosContainerViewControllerStateSlideShow: {
                [self installSlideShowController];
                break;
            }
            case PhotosContainerViewControllerStateGraph: {
                // nothing
                break;
            }
        }
    }
    [self configureNavigation];
    [self updateToolbar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterForNotifications];
    [self faultAllPhotos];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // not much to do here
    if (nil != _woundPhoto1ObjectID && ![[_woundPhotoDate1 objectID] isTemporaryID]) {
        _woundPhoto1ObjectID = [_woundPhotoDate1 objectID];
        _woundPhotoDate1 = nil;
    }
    if (nil != _woundPhoto2ObjectID && ![[_woundPhotoDate2 objectID] isTemporaryID]) {
        _woundPhoto2ObjectID = [_woundPhotoDate2 objectID];
        _woundPhotoDate2 = nil;
    }
    [self faultAllPhotos];
}

- (void)faultAllPhotos
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    for (NSManagedObjectID *objectID in _cachedSortedWoundPhotos) {
        NSManagedObject *woundPhoto = [managedObjectContext objectWithID:objectID];
        NSManagedObjectID *photoObjectID = [woundPhoto valueForKeyPath:@"photo.objectID"];
        [Faulter faultObjectWithID:photoObjectID inContext:managedObjectContext];
        [Faulter faultObjectWithID:objectID inContext:managedObjectContext];
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Accessors

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

#pragma mark - Core

- (void)setState:(PhotosContainerViewControllerState)state
{
    if (_state == state) {
        return;
    }
    // else
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (BOOL)isStateNone
{
    return _state == PhotosContainerViewControllerStateNone;
}

- (BOOL)isStateGrid
{
    return _state == PhotosContainerViewControllerStateGrid;
}

- (BOOL)isStatePage
{
    return _state == PhotosContainerViewControllerStatePage;
}

- (BOOL)isStateDateCompare
{
    return _state == PhotosContainerViewControllerStateDateCompare;
}

- (BOOL)isStateSlideShow
{
    return _state == PhotosContainerViewControllerStateSlideShow;
}

- (BOOL)isStateZoom
{
    return _state == PhotosContainerViewControllerStateZoom;
}

- (BOOL)isStateGraph
{
    return _state == PhotosContainerViewControllerStateGraph;
}

- (void)configureNavigation
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = [NSString stringWithFormat:@"%@: %@", self.patient.lastNameFirstName, self.wound.shortName];
}

- (NSArray *)toolbarItemsForBrowsePhotos
{
    if (nil == _toolbarItemsForBrowsePhotos) {
        self.gridScrollSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Grid", @"Page", @"Date", @"Play", nil]];
        [self.gridScrollSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_grid.png"] forSegmentAtIndex:0];
        [self.gridScrollSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_page.png"] forSegmentAtIndex:1];
        [self.gridScrollSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_calender.png"] forSegmentAtIndex:2];
        [self.gridScrollSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_play.png"] forSegmentAtIndex:3];
        [self.gridScrollSegmentedControl addTarget:self
                                            action:@selector(gridScrollSegmentedControlValueChangedAction:)
                                  forControlEvents:UIControlEventValueChanged];
        self.segmentControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.gridScrollSegmentedControl];
        _toolbarItemsForBrowsePhotos = [[NSArray alloc] initWithObjects:
                                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                                        self.segmentControlBarButtonItem,
                                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                                        nil];
    }
    return _toolbarItemsForBrowsePhotos;
}

- (NSArray *)toolbarItemsForZoom
{
    if (nil == _toolbarItemsForZoom) {
        self.photoAssessmentSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"P", @"M", @"A", nil]];
        [self.photoAssessmentSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_photo.png"] forSegmentAtIndex:0];
        [self.photoAssessmentSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_ruler.png"] forSegmentAtIndex:1];
        [self.photoAssessmentSegmentedControl setImage:[UIImage imageNamed:@"ui_segmented_assessment.png"] forSegmentAtIndex:2];
        self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
        [self.photoAssessmentSegmentedControl addTarget:self
                                                 action:@selector(photoAssessmentSegmentedControlValueChangedAction:)
                                       forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *photoAssessmentBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.photoAssessmentSegmentedControl];
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:
                                 [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_trash.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(deletePhotoAction:)],
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                                 photoAssessmentBarButtonItem,
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                                 [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_grid.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(installGridViewController)],
                                 nil];
        if (self.woundPhoto.measurementGroup.isClosed) {
            [items removeObjectAtIndex:0];
        }
        _toolbarItemsForZoom = items;
        _photoAssessmentBarButtonItem = photoAssessmentBarButtonItem;
    }
    return _toolbarItemsForZoom;
}

- (NSArray *)cachedSortedWoundPhotos
{
    if (nil == _cachedSortedWoundPhotos) {
        _cachedSortedWoundPhotos = self.wound.sortedWoundPhotoIDs;
    }
    return _cachedSortedWoundPhotos;
}

- (WMPhotoGridViewController *)photoGridViewController
{
    if (nil == _photoGridViewController) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _photoGridViewController = [[WMPhotoGridViewController alloc] initWithCollectionViewLayout:layout];
        _photoGridViewController.delegate = self;
    }
    return _photoGridViewController;
}

- (UIPageViewController *)photoPageViewController
{
    if (nil == _photoPageViewController) {
        _photoPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll//UIPageViewControllerTransitionStyleScroll, UIPageViewControllerTransitionStylePageCurl
                                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                 options:@{ UIPageViewControllerOptionInterPageSpacingKey : @20.f }];
        _photoPageViewController.delegate = self;
        _photoPageViewController.dataSource = self;
    }
    return _photoPageViewController;
}

- (WMComparePhotosViewController *)compareViewController
{
    if (nil == _compareViewController) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _compareViewController = [[WMComparePhotosViewController alloc] initWithCollectionViewLayout:layout];
        _compareViewController.delegate = self;
    }
    return _compareViewController;
}

- (WMWoundPhotoSlideShowViewController *)slideShowController
{
    WMWoundPhotoSlideShowViewController *slideShowController = [[WMWoundPhotoSlideShowViewController alloc] initWithNibName:@"WMWoundPhotoSlideShowViewController" bundle:nil];
    slideShowController.delegate = self;
    return slideShowController;
}

- (WMPhotoZoomViewController *)photoZoomViewController
{
    if (nil == _photoZoomViewController) {
        _photoZoomViewController = [[WMPhotoZoomViewController alloc] initWithNibName:@"WMPhotoZoomViewController" bundle:nil];
    }
    return _photoZoomViewController;
}

- (WMWoundMeasurementGroupViewController *)measurementGroupViewController
{
    WMWoundMeasurementGroupViewController *measurementGroupViewController = [[WMWoundMeasurementGroupViewController alloc] initWithNibName:@"WMWoundMeasurementGroupViewController" bundle:nil];
    measurementGroupViewController.delegate = self;
    return measurementGroupViewController;
}

- (WMWoundMeasurementSummaryViewController *)woundMeasurementSummaryViewController
{
    return [[WMWoundMeasurementSummaryViewController alloc] initWithNibName:@"WMWoundMeasurementSummaryViewController" bundle:nil];
}

- (void)removeCurrentChildViewControllerFromParentViewController
{
    if (nil == self.currentChildViewController) {
        return;
    }
    // else
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self.currentChildViewController.view removeFromSuperview];
    [self.currentChildViewController removeFromParentViewController];
    self.currentChildViewController = nil;
}

- (BOOL)showingMeasurementsViewController
{
    for (id childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[WMWoundMeasurementGroupViewController class]]) {
            return YES;
        }
    }
    // else
    return NO;
}

#pragma mark - BaseViewController

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (void)registerForNotifications
{
    // respond to woundPhoto delete
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kWoundPhotoWillDeleteNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    NSManagedObjectID *objectID = [notification object];
                                                                    DLog(@"wound photo delete received for %@", objectID);
                                                                    // update image to show tiling completed - don't need to do anything
                                                                }];
    [self.opaqueNotificationObservers addObject:observer];
}

- (void)unregisterForNotifications
{
    // stop listening
    for (id observer in self.opaqueNotificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [self.opaqueNotificationObservers removeAllObjects];
}

- (void)handleWoundPhotoWillDelete:(WMWoundPhoto *)woundPhoto
{
    if (_woundPhotoDate1 == woundPhoto) {
        _woundPhotoDate1 = nil;
        _woundPhoto1ObjectID = nil;
    }
    if (_woundPhotoDate2 == woundPhoto) {
        _woundPhotoDate2 = nil;
        _woundPhoto2ObjectID = nil;
    }
    [self invalidateWoundPhotoCache];
    [self performSelector:@selector(installGridViewController) withObject:nil afterDelay:0.0];
}

#pragma mark - Actions

- (IBAction)gridScrollSegmentedControlValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (segmentedControl.selectedSegmentIndex == 0) {
        // Grid
        [self installGridViewController];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        // Scroll
        [self installPageViewController];
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        // Date
        [self installCompareDateViewController];
    } else if (segmentedControl.selectedSegmentIndex == 3) {
        // Play
        [self installSlideShowController];
    }
}

- (IBAction)photoAssessmentSegmentedControlValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            // zoom - nothing to do - already in view
            break;
        }
        case 1: {
            // measure photo
            if (self.woundPhoto.measurementGroup.isClosed) {
                self.previousState = self.state;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Record Closed"
                                                                    message:@"The wound photo editing period has expired per policy settings."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                alertView.tag = kMeasureActionClosedAlertTag;
                [alertView show];
                return;
            }
            // else
            [self.appDelegate.navigationCoordinator viewController:self beginMeasurementsForWoundPhoto:self.woundPhoto addingPhoto:NO];
            self.shouldResetPhotoAssessmentSegmentedControlOnViewDidAppear = YES;
            break;
        }
        case 2: {
            // assessment (WMWoundMeasurementGroupViewController)
            [self presentMeasurementGroupViewController];
            self.shouldResetPhotoAssessmentSegmentedControlOnViewDidAppear = YES;
            break;
        }
    }
}

- (IBAction)deletePhotoAction:(id)sender
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Deleting a photo can not be undone. Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:(isPad ? nil:@"Cancel")
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kDeletePhotoActionSheetTag;
    if (isPad) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (IBAction)doneAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          // nothing
                                                      }];
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    // hide/show
    if (UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
        // now landscape - don't hide toolbar for measurements controller
        if (!self.showingMeasurementsViewController) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
    } else {
        // now portrait
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self updateToolbar];
    }
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kWaitingForTilingToFinishAlertTag: {
            // nothing
            break;
        }
        case kMeasureActionClosedAlertTag: {
            self.photoAssessmentSegmentedControl.selectedSegmentIndex = 0;
            break;
        }
    }
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeletePhotoActionSheetTag) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            ffm.processDeletesOnNSManagedObjectContextObjectsDidChangeNotification = YES;
            NSManagedObjectContext *managedObjectContext = [self.woundPhoto managedObjectContext];
            [self.appDelegate.navigationCoordinator deleteWoundPhoto:self.woundPhoto];
            [managedObjectContext processPendingChanges];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            ffm.processDeletesOnNSManagedObjectContextObjectsDidChangeNotification = NO;
            [self invalidateWoundPhotoCache];
            [self installGridViewController];
        }
    }
}

#pragma mark - WoundPhotoCache

- (void)invalidateWoundPhotoCache
{
    _cachedSortedWoundPhotos = nil;
}

- (NSInteger)woundPhotoCount
{
    return [self.cachedSortedWoundPhotos count];
}

- (WMWoundPhoto *)lastCachedWoundPhoto
{
    id object = [self.cachedSortedWoundPhotos lastObject];
    if (nil != object) {
        if ([object isKindOfClass:[WMWoundPhoto class]]) {
            return object;
        }
        // else
        if ([object isKindOfClass:[NSManagedObjectID class]]) {
            return (WMWoundPhoto *)[self.managedObjectContext objectWithID:object];
        }
    }
    // else
    return nil;
}

- (NSManagedObjectID *)woundPhotoObjectIDAtIndex:(NSInteger)index
{
    return [self.cachedSortedWoundPhotos objectAtIndex:index];
}

- (WMWoundPhoto *)woundPhotoAtIndex:(NSInteger)index
{
    NSParameterAssert(index != NSNotFound);
    id object = [self.cachedSortedWoundPhotos objectAtIndex:index];
    if ([object isKindOfClass:[WMWoundPhoto class]]) {
        return object;
    }
    // else
    if ([object isKindOfClass:[NSManagedObjectID class]]) {
        return (WMWoundPhoto *)[self.managedObjectContext objectWithID:object];
    }
    // else
    return nil;
}

- (WMWoundPhoto *)woundPhotoDate1
{
    if (nil != _woundPhotoDate1) {
        return _woundPhotoDate1;
    }
    // else
    if (nil == _woundPhoto1ObjectID) {
        NSManagedObjectID *objectID = nil;
        if (self.woundPhotoCount > 0) {
            if (self.woundPhotoCount > 1) {
                objectID = [self woundPhotoObjectIDAtIndex:(self.woundPhotoCount - 2)];
            } else {
                objectID = [self woundPhotoObjectIDAtIndex:(self.woundPhotoCount - 1)];
            }
            self.woundPhotoDate1 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:objectID];
        }
    } else {
        self.woundPhotoDate1 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:_woundPhoto1ObjectID];
    }
    return _woundPhotoDate1;
}

- (void)setWoundPhotoDate1:(WMWoundPhoto *)woundPhotoDate1
{
    if (_woundPhotoDate1 == woundPhotoDate1) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundPhotoDate1"];
    _woundPhotoDate1 = woundPhotoDate1;
    _woundPhoto1ObjectID = [woundPhotoDate1 objectID];
    [self didChangeValueForKey:@"woundPhotoDate1"];
}

- (WMWoundPhoto *)woundPhotoDate2
{
    if (nil != _woundPhotoDate2) {
        return _woundPhotoDate2;
    }
    // else
    if (nil == _woundPhoto2ObjectID) {
        NSManagedObjectID *objectID = nil;
        if (self.woundPhotoCount > 1) {
            objectID = [self woundPhotoObjectIDAtIndex:(self.woundPhotoCount - 1)];
            self.woundPhotoDate2 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:objectID];
        }
    } else {
        self.woundPhotoDate2 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:_woundPhoto2ObjectID];
    }
    return _woundPhotoDate2;
}

- (void)setWoundPhotoDate2:(WMWoundPhoto *)woundPhotoDate2
{
    if (_woundPhotoDate2 == woundPhotoDate2) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundPhotoDate2"];
    _woundPhotoDate2 = woundPhotoDate2;
    _woundPhoto2ObjectID = [woundPhotoDate2 objectID];
    [self didChangeValueForKey:@"woundPhotoDate2"];
}

- (void)handleWoundPhotoObjectIDSelection:(NSManagedObjectID *)woundPhotoObjectID atFrame:(CGRect)aFrame
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMWoundPhoto *woundPhoto = (WMWoundPhoto *)[managedObjectContext objectWithID:woundPhotoObjectID];
    if (self.isStateDateCompare) {
        // take no action if iPhone and landscape
        if (!isPad && UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            return;
        }
        // else TODO figure out how to keep WMSelectWoundPhotoForDateController as ivar for better memory management
        NSAssert3([woundPhotoObjectID isEqual:self.woundPhoto1ObjectID] || [woundPhotoObjectID isEqual:self.woundPhoto2ObjectID], @"No match: %@,%@ for %@", self.woundPhoto1ObjectID, self.woundPhoto2ObjectID, woundPhotoObjectID);
        self.selectingWoundPhotoForDate1 = (woundPhotoObjectID == self.woundPhoto1ObjectID ? YES:NO);
        KalDelegate *kalDelegate = (woundPhotoObjectID == self.woundPhoto1ObjectID ? self.compareViewController.leftKalDelegate:self.compareViewController.rightKalDelegate);
        WMSelectWoundPhotoForDateController *viewController = [[WMSelectWoundPhotoForDateController alloc] initWithSelectedDate:woundPhoto.createdAt
                                                                                                                   delegate:kalDelegate
                                                                                                                 dataSource:kalDelegate
                                                                                                                      frame:self.view.bounds];
        viewController.cacheDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        if (isPad) {
            self.selectWoundPhotoByDatePopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            self.selectWoundPhotoByDatePopoverController.delegate = self;
            [self.selectWoundPhotoByDatePopoverController presentPopoverFromRect:aFrame
                                                                          inView:self.view
                                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                        animated:YES];
        } else {
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        return;
    }
    // else make sure we have photo data
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    WMErrorCallback errorCallback2 = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        weakSelf.appDelegate.navigationCoordinator.woundPhoto = woundPhoto;
        weakSelf.photoZoomViewController.initialFrame = aFrame; // aFrame is in window coordinates
        weakSelf.gridScrollSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        [weakSelf installPhotoZoomViewController:NO];
    };
    WMErrorCallback errorCallback = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        // get the latest measurement group
        WMWoundMeasurementGroup *measurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:woundPhoto create:NO];
        if (measurementGroup) {
            // get values from back end
            [ffm updateGrabBags:@[WMWoundMeasurementGroupRelationships.values]
                     aggregator:measurementGroup
                             ff:ff
              completionHandler:errorCallback2];
        } else {
            errorCallback2(nil);
        }
    };
    dispatch_block_t block = ^{
        // make sure we have measurement groups
        [ffm updateGrabBags:@[WMWoundPhotoRelationships.measurementGroups]
                 aggregator:woundPhoto
                         ff:ff
          completionHandler:errorCallback];
    };
    WMPhoto *photo = woundPhoto.photo;
    if (nil == photo.photo) {
        [MBProgressHUD showHUDAddedTo:self.view animated:NO].labelText = @"Downloading photo";
        [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", photo.ffUrl, WMPhotoAttributes.photo]] executeAsyncWithBlock:^(FFReadResponse *response) {
            NSData *photoData = [response rawResponseData];
            if (response.httpResponse.statusCode > 300) {
                DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
            } else {
                photo.photo = [[UIImage alloc] initWithData:photoData];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                block();
            }
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        }];
    } else {
        block();
    }
}

// aFrame is in window coordinates
- (void)handleWoundPhotoSelection:(WMWoundPhoto *)woundPhoto atFrame:(CGRect)aFrame
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (self.isStateDateCompare) {
        // take no action if iPhone and landscape
        if (!isPad && UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            return;
        }
        // else TODO figure out how to keep WMSelectWoundPhotoForDateController as ivar for better memory management
        self.selectingWoundPhotoForDate1 = (woundPhoto == self.woundPhotoDate1 ? YES:NO);
        KalDelegate *kalDelegate = (woundPhoto == self.woundPhotoDate1 ? self.compareViewController.leftKalDelegate:self.compareViewController.rightKalDelegate);
        WMSelectWoundPhotoForDateController *viewController = [[WMSelectWoundPhotoForDateController alloc] initWithSelectedDate:woundPhoto.createdAt
                                                                                                                   delegate:kalDelegate
                                                                                                                 dataSource:kalDelegate
                                                                                                                      frame:self.view.bounds];
        viewController.cacheDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        if (isPad) {
            self.selectWoundPhotoByDatePopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            self.selectWoundPhotoByDatePopoverController.delegate = self;
            [self.selectWoundPhotoByDatePopoverController presentPopoverFromRect:aFrame
                                                                          inView:self.view
                                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                        animated:YES];
        } else {
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        return;
    }
    // else
    self.appDelegate.navigationCoordinator.woundPhoto = woundPhoto;
    self.photoZoomViewController.initialFrame = aFrame;
    self.gridScrollSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    [self installPhotoZoomViewController:NO];
}

- (void)dismissSelectWoundPhotoByDateController
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (isPad) {
        [self.selectWoundPhotoByDatePopoverController dismissPopoverAnimated:YES];
        self.selectWoundPhotoByDatePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [self performSelector:@selector(updateImageViewAtIndexPath:)
               withObject:(self.selectingWoundPhotoForDate1 ? [NSIndexPath indexPathForRow:0 inSection:0]:[NSIndexPath indexPathForRow:1 inSection:0])
               afterDelay:0.0];
}

- (void)transitionToGridController
{
    [self installGridViewController];
}

- (void)updateToolbarItems:(NSArray *)toolbarItems
{
    self.toolbarItems = toolbarItems;
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundPhotoSlideShowViewControllerDelegate

- (void)woundPhotoSlideShowViewControllerDidFinish:(WMWoundPhotoSlideShowViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self installGridViewController];
    }];
}

#pragma mark - UIPopoverControllerDelegate

// Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _selectWoundPhotoByDatePopoverController = nil;
}

#pragma mark - UIPageViewControllerDelegate

// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    //    DLog(@"pageViewController:%@ willTransitionToViewControllers:%@", pageViewController, pendingViewControllers);
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished,
// while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
}

#pragma mark - UIPageViewControllerDataSource

// In terms of navigation direction. For example, for 'UIPageViewControllerNavigationOrientationHorizontal',
// view controllers coming 'before' would be to the left of the argument view controller, those coming 'after' would be to the right.
// Return 'nil' to indicate that no more progress can be made in the given direction.
// For gesture-initiated transitions, the page view controller obtains view controllers via these methods, so use of setViewControllers:direction:animated:completion: is not required.
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    WMWoundPhotoViewController *myController = (WMWoundPhotoViewController *)viewController;
    NSArray *objectIDs = self.cachedSortedWoundPhotos;
    NSInteger index = [objectIDs indexOfObject:myController.woundPhotoObjectID];
    if (index != NSNotFound && index > 0) {
        return [self woundPhotoViewControllerForWoundPhotoObjectID:[objectIDs objectAtIndex:(index - 1)]];
    }
    // else
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    WMWoundPhotoViewController *myController = (WMWoundPhotoViewController *)viewController;
    NSArray *objectIDs = self.cachedSortedWoundPhotos;
    NSInteger index = [objectIDs indexOfObject:myController.woundPhotoObjectID];
    if (index != NSNotFound && index < ([objectIDs count] - 1)) {
        return [self woundPhotoViewControllerForWoundPhotoObjectID:[objectIDs objectAtIndex:(index + 1)]];
    }
    // else
    return nil;
}

@end
