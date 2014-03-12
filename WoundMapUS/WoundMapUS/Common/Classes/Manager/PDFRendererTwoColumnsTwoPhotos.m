//
//  PDFRendererTwoColumnsTwoPhotos.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/26/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "PDFRendererTwoColumnsTwoPhotos.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMBradenScale.h"
#import "WCBradenSection.h"
#import "WCBradenCell.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "PrintConfiguration.h"
#import "LocalStoreManager.h"

@interface PDFRendererTwoColumnsTwoPhotos ()

@property (weak, nonatomic) IBOutlet UIView *leftColumnView;
@property (weak, nonatomic) IBOutlet UIView *rightColumnView;
@property (weak, nonatomic) IBOutlet UIView *leftWoundSummaryView;
@property (weak, nonatomic) IBOutlet UIView *rightWoundSummaryView;
@property (weak, nonatomic) IBOutlet UIView *leftWoundPhotoView;
@property (weak, nonatomic) IBOutlet UIView *rightWoundPhotoView;
@property (weak, nonatomic) IBOutlet UIView *leftTreatmentView;
@property (weak, nonatomic) IBOutlet UIView *rightTreatmentView;
@property (weak, nonatomic) IBOutlet UIView *leftPlanView;
@property (weak, nonatomic) IBOutlet UIView *rightPlanView;
@property (weak, nonatomic) IBOutlet UIView *leftDataView;
@property (weak, nonatomic) IBOutlet UIView *rightDataView;
@property (strong, nonatomic) NSMutableArray *woundStatusMeasurementTitlesToPlot;

@end

@implementation PDFRendererTwoColumnsTwoPhotos

@synthesize lastPageNumber=_lastPageNumber;
@synthesize pageHeaderView, pageFooterView, leftColumnView=_leftColumnView, rightColumnView=_rightColumnView;
@synthesize leftWoundSummaryView=_leftWoundSummaryView, rightWoundSummaryView=_rightWoundSummaryView, leftWoundPhotoView=_leftWoundPhotoView, rightWoundPhotoView=_rightWoundPhotoView, leftPlanView=_leftPlanView, rightPlanView=_rightPlanView;
@synthesize leftTreatmentView, rightTreatmentView;
@synthesize leftDataView=_leftDataView, rightDataView=_rightDataView;
@synthesize woundStatusMeasurementTitlesToPlot=_woundStatusMeasurementTitlesToPlot;

- (NSMutableArray *)woundStatusMeasurementTitlesToPlot
{
    if (nil == _woundStatusMeasurementTitlesToPlot) {
        _woundStatusMeasurementTitlesToPlot = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _woundStatusMeasurementTitlesToPlot;
}

- (NSInteger)woundPhotosPerPage
{
    return 2;
}

- (NSInteger)lastPageNumber
{
    if (_lastPageNumber == 0) {
        NSArray *wounds = self.printConfiguration.sortedWounds;
        NSInteger count = 0;
        for (WMWound *wound in wounds) {
            count += [[self.printConfiguration sortedWoundPhotosForWound:wound] count];
        }
        _lastPageNumber = count + count/self.woundPhotosPerPage + (count % self.woundPhotosPerPage > 0 ? 1:0);
    }
    return _lastPageNumber;
}

/**
 add password to file: http://stackoverflow.com/questions/9598005/creating-password-protected-pdf-in-objective-c?rq=1
 CFMutableDictionaryRef myDictionary = NULL;
 // This dictionary contains extra options mostly for 'signing' the PDF
 myDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
 CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, CFSTR("userpassword"));
 CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, CFSTR("ownerpassword"));

 pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);

 // Cleanup our mess
 CFRelease(myDictionary);

 */
- (void)drawToURL:(NSURL *)url
{
    [super drawToURL:url];
    // load the nib template
    self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:0] owner:self options:nil];
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(url.path, CGRectZero, self.pageInfoDictionary);
    // mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    // draw page header
    NSInteger pageNumber = 1;
    // draw the patient header
    CGFloat deltaY = 0.0;
    // draw summary pages
    NSArray *wounds = self.printConfiguration.sortedWounds;
    NSInteger index = 0;
    BOOL shouldDrawHeaderFooter = NO;
    for (WMWound *wound in wounds) {
        self.wound = wound;
        // photos
        NSArray *woundPhotos = [self.printConfiguration sortedWoundPhotosForWound:wound];
        for (WMWoundPhoto *woundPhoto in woundPhotos) {
            if (index % 2 == 0) {
                // determine the maximum y expected
                CGRect aFrame = [self.rootView convertRect:self.patientHeaderView.frame fromView:self.patientHeaderView];
                [self drawPatientHeaderInRect:aFrame];
                //DLog(@"%@.drawPatientHeaderInRect deltaY:%f expected:%f", NSStringFromClass([self class]), deltaY, expectedMaxY);
            }
            // mark that the page needs header/footer
            shouldDrawHeaderFooter = YES;
            deltaY = [self drawWoundSummaryForWound:wound atIndex:index];
            // check if rect used to draw exceeds the placeholder rect
            if (deltaY != 0) {
                // doesn't work for two columns
//                UIView *placeHolder = self.leftWoundSummaryView;
//                CGRect aRect = [self.contentView convertRect:placeHolder.frame fromView:placeHolder.superview];
//                CGFloat expectedY = CGRectGetMaxY(aRect);
//                [self adjustPlaceholdersBelow:(expectedY + deltaY) byAmount:deltaY];
            }
            // draw wound photo
            deltaY = [self drawWoundPhoto:woundPhoto atIndex:index];
            // check if rect used to draw exceeds the placeholder rect
            if (deltaY != 0) {
                // no action
            }
            // draw treatment
            deltaY = [self drawWoundTreatmentForWound:wound atIndex:index];
            // check if rect used to draw exceeds the placeholder rect
            if (deltaY != 0) {
                // no action
            }
            // draw plan
//            deltaY = [self drawWoundPlanForWoundPhoto:woundPhoto atIndex:index];
            // check if rect used to draw exceeds the placeholder rect
            if (deltaY != 0) {
                // no action
            }
            ++index;
            // check if we are moving to new page
            if ((index % 2) == 0) {
                // draw the page header
                [self drawPageHeader:pageNumber];
                // draw footer before we go to new page
                [self drawPageFooter:pageNumber];
                // flag
                shouldDrawHeaderFooter = NO;
                // new page
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                ++pageNumber;
            }
        }
    }
    if (shouldDrawHeaderFooter) {
        // draw header/footer before we go to new page
        [self drawPageHeader:pageNumber];
        [self drawPageFooter:pageNumber];
        // draw data pages, first go to new page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
    }
    // load the nib
    self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:1] owner:self options:nil];
    for (WMWound *wound in wounds) {
        self.wound = wound;
        // photos
        NSArray *woundPhotos = [self.printConfiguration sortedWoundPhotosForWound:wound];
        for (WMWoundPhoto *woundPhoto in woundPhotos) {
            [self drawPageHeader:pageNumber];
            [self drawPatientWoundHeader:wound atIndex:index];
            // draw assessment
            [self drawAssessmentForWoundPhoto:woundPhoto atIndex:index];
            [self drawPageFooter:pageNumber];
            // check if we are moving to new page
            if (pageNumber < self.lastPageNumber) {
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                ++pageNumber;
            }
        }
    }
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (NSArray *)templateNibNames
{
    return [NSArray arrayWithObjects:@"TemplateTwoColumnsTwoPhotosSummary", @"TemplateTwoColumnsTwoPhotosData", nil];
}

- (CGFloat)drawWoundSummaryForWound:(WMWound *)wound atIndex:(NSInteger)index
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftWoundSummaryView:self.rightWoundSummaryView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawWoundSummaryForWound:wound inRect:aFrame draw:YES];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    if (deltaY < 0.0) {
        // needed less view space
        
    } else {
        // needed more view space
        
    }
    return deltaY;
}


- (CGFloat)drawWoundPhoto:(WMWoundPhoto *)woundPhoto atIndex:(NSInteger)index
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftWoundPhotoView:self.rightWoundPhotoView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawWoundPhoto:woundPhoto inRect:aFrame];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    return deltaY;
}

- (CGFloat)drawWoundTreatmentForWound:(WMWound *)wound atIndex:(NSInteger)index
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftTreatmentView:self.rightTreatmentView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawWoundTreatmentForWound:wound inRect:aFrame draw:YES];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    if (deltaY < 0.0) {
        // needed less view space
        
    } else {
        // needed more view space
        
    }
    return deltaY;
}

- (CGFloat)drawPatientWoundHeader:(WMWound *)wound atIndex:(NSInteger)index
{
    UIView *placeHolderView = self.patientDataSummaryView;
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawPatientWoundHeader:wound inRect:aFrame draw:YES];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    if (deltaY < 0.0) {
        // needed less view space
        
    } else {
        // needed more view space
        
    }
    return deltaY;
}

#define Plot_Height 120.0
#define Plot_InterstitialY 4.0

- (CGFloat)drawAssessmentForWoundPhoto:(WMWoundPhoto *)woundPhoto atIndex:(NSInteger)index
{
    UIView *placeHolderView = self.leftDataView;
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = 0.0;// abandoned [self drawAssessmentForWoundPhoto:woundPhoto inRect:aFrame compress:NO draw:YES];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    if (deltaY < 0.0) {
        // didn't need all the view space to draw assessment
        
    } else {
        // needed more view space to draw assessment
        
    }
    return deltaY;
}

- (void)drawPlots
{
    // precalculate position for graph
    CGRect rightPlotFrame = [self.rootView convertRect:self.rightDataView.frame fromView:self.rightDataView.superview];
    CGFloat minPlotX = CGRectGetMinX(rightPlotFrame);
    CGFloat minPlotY = CGRectGetMinY(rightPlotFrame);
    CGFloat plotWidth = CGRectGetWidth(rightPlotFrame);
    CGFloat height = CGRectGetHeight(rightPlotFrame);
    // determine the initial y location of first plot
    CGFloat heightOfAllPlots = [self.woundStatusMeasurementTitlesToPlot count] * (Plot_Height + Plot_InterstitialY);
    CGRect aFrame = [self.rootView convertRect:self.patientDataSummaryView.frame fromView:self.patientDataSummaryView.superview];
    CGFloat preferredY = CGRectGetMaxY(aFrame);
    CGFloat maxY = CGRectGetMaxY(rightPlotFrame);
    if ((maxY - preferredY) >= heightOfAllPlots) {
        minPlotY = preferredY;
    } else {
        minPlotY = roundf(minPlotY + (height - heightOfAllPlots)/2.0);
    }
    for (NSString *woundStatusMeasurementTitle in self.woundStatusMeasurementTitlesToPlot) {
        CGRect plotFrame = CGRectMake(minPlotX, minPlotY, plotWidth, Plot_Height);
        [self drawPlotForMeasurementTitle:woundStatusMeasurementTitle frame:plotFrame];
        minPlotY += (Plot_Height + Plot_InterstitialY);
    }
}

@end
