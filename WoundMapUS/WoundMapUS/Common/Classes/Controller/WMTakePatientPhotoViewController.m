//
//  WMTakePatientPhotoViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTakePatientPhotoViewController.h"
#import "WMPatientPhotoImageView.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMFatFractal.h"
#import "WMPhotoManager.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMTakePatientPhotoViewController () <OverlayViewControllerDelegate>

@property (readonly, nonatomic) WMPatient *patient;

@property (weak, nonatomic) IBOutlet WMPatientPhotoImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *deletePhotoButton;
@property (nonatomic) BOOL photoAcquisitionInProgress;

- (void)updateForPatient;
- (IBAction)takePhotoAction:(id)sender;
- (IBAction)deletePhotoAction:(id)sender;

@end

@implementation WMTakePatientPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.preferredContentSize = CGSizeMake(320.0, 520.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Take Patient Photo";
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_photoAcquisitionInProgress) {
        [self updateForPatient];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Core

- (WMPatient *)patient
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.navigationCoordinator.patient;
}

#pragma mark - Actions

- (IBAction)takePhotoAction:(id)sender
{
    WMPhotoManager *photoManager = [WMPhotoManager sharedInstance];
    photoManager.delegate = self;
    _photoAcquisitionInProgress = YES;
    [self presentViewController:photoManager.imagePickerController animated:YES completion:^{
        // nothing
    }];
}

- (IBAction)deletePhotoAction:(id)sender
{
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    patient.thumbnail = nil;
    __weak __typeof(&*self)weakSelf = self;
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [weakSelf updateForPatient];
        // update back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff deleteBlobForObj:patient
                  memberName:WMPatientAttributes.thumbnail
                  onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                      // nothing
                  } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                      // nothing
                  }];
    }];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate takePatientPhotoViewControllerDidFinish:self];
}

#pragma mark - Core

- (void)updateForPatient
{
    [_photoImageView updateForPatient:self.patient];
    if (nil == self.patient.thumbnail) {
        [_takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
        _deletePhotoButton.enabled = NO;
    } else {
        [_takePhotoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
        _deletePhotoButton.enabled = YES;
    }
}

#pragma mark - BaseViewController

#pragma mark - OverlayViewControllerDelegate

- (void)photoManager:(WMPhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    DLog(@"image %@", NSStringFromCGSize(image.size));
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = @"Processing Photo";
    NSManagedObjectID *objectID = [self.patient objectID];
    __weak __typeof(&*self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMPatient *patient = (WMPatient *)[managedObjectContext objectWithID:objectID];
            patient.thumbnail = image;
            patient.facePhotoTaken = YES;
            BOOL success = NO;
            patient.thumbnail = [photoManager scaleAndCenterPatientPhoto:image rect:CGRectMake(0.0, 0.0, 256.0, 256.0) success:&success];
            if (success) {
                weakSelf.patient.faceDetectionFailed = NO;
            } else {
                weakSelf.patient.faceDetectionFailed = YES;
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [_photoImageView updateForPatient:patient];
                NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
                WMPatient *patient = (WMPatient *)[managedObjectContext objectWithID:objectID];
                WMFatFractal *ff = [WMFatFractal sharedInstance];
                [ff updateObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                    [ff updateBlob:UIImagePNGRepresentation(patient.thumbnail)
                      withMimeType:@"image/png"
                            forObj:patient
                        memberName:WMPatientAttributes.thumbnail
                        onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                            [managedObjectContext MR_saveToPersistentStoreAndWait];
                        } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                            [managedObjectContext MR_saveToPersistentStoreAndWait];
                        }];
                }];
            });
        });
    }];
    
}

- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager
{
    _photoAcquisitionInProgress = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

@end
