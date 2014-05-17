//
//  WMBarScanViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBarScanViewController.h"
#import "NSObject+performBlockAfterDelay.h"
#import <AVFoundation/AVFoundation.h>

@interface WMBarScanViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
}

@property (strong, nonatomic) NSTimer *barCodeReaderTimer;
@property (strong, nonatomic) NSMutableSet *barCodeValues;
@property (nonatomic) BOOL scannerDidReturnValues;

@end

@implementation WMBarScanViewController

- (void)dealloc
{
    if (_barCodeReaderTimer) {
        [_barCodeReaderTimer invalidate];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBarCodeScan)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self presentBarCodeReader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSMutableSet *)barCodeValues
{
    if (nil == _barCodeValues) {
        _barCodeValues = [NSMutableSet set];
    }
    return _barCodeValues;
}

- (void)presentBarCodeReader
{
    // make sure we pull down the interface
    _barCodeReaderTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                           target:self
                                                         selector:@selector(handleBarCodeTimeoutAction:)
                                                         userInfo:nil
                                                          repeats:NO];
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
}

- (void)handleBarCodeTimeoutAction:(NSTimer *)timer
{
    [self cancelBarCodeScan];
}

- (void)cancelBarCodeScan
{
    [_barCodeReaderTimer invalidate];
    _barCodeReaderTimer = nil;
    [self dismissBarCodeInterface];
    [self.delegate barScanViewControllerDidCancel:self];
}

- (void)dismissBarCodeInterface
{
    [_session stopRunning];
    _session = nil;
    [_prevLayer removeFromSuperlayer];
    _prevLayer = nil;
    [_highlightView removeFromSuperview];
    _highlightView = nil;
    [_label removeFromSuperview];
    _label = nil;
}

#pragma mark - Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _prevLayer.frame = self.view.bounds;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (_scannerDidReturnValues) {
        return;
    }
    // else
    _scannerDidReturnValues = YES;
    [_barCodeReaderTimer invalidate];
    _barCodeReaderTimer = nil;
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    NSString *detectionString = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString) {
            [self.barCodeValues addObject:detectionString];
            detectionString = nil;
        }

        if ([self.barCodeValues count]) {
            _label.text = [[self.barCodeValues allObjects] componentsJoinedByString:@","];
        } else {
            _label.text = @"(none)";
        }
    }
    
    _highlightView.frame = highlightViewRect;
    
    if ([self.barCodeValues count]) {
        __weak __typeof(&*self)weakSelf = self;
        [self performBlock:^{
            [weakSelf dismissBarCodeInterface];
            [weakSelf.delegate barScanViewController:weakSelf didCaptureBarScan:[[self.barCodeValues allObjects] componentsJoinedByString:@","]];
        } afterDelay:1.0];
    } else {
        [self dismissBarCodeInterface];
        [self.delegate barScanViewControllerDidCancel:self];
    }
}

@end
