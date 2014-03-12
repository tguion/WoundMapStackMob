//
//  PDFRendererTwoColumnsSOAP.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 3/8/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "PDFRendererTwoColumnsSOAP.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementGroup+CoreText.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMWoundPhoto.h"
#import "WMMedicationGroup.h"
#import "WMMedicationGroup+CoreText.h"
#import "WMDeviceGroup.h"
#import "WMDeviceGroup+CoreText.h"
#import "WMPsychoSocialGroup.h"
#import "WMPsychoSocialGroup+CoreText.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentGroup+CoreText.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanGroup+CoreText.h"
#import "PrintConfiguration.h"
#import "WCModelTextKitAtrributes.h"

@interface PDFRendererTwoColumnsSOAP ()
@property (weak, nonatomic) IBOutlet UIView *leftColumnView;
@property (weak, nonatomic) IBOutlet UIView *middleColumnView;
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
@end

@implementation PDFRendererTwoColumnsSOAP

@synthesize leftWoundSummaryView=_leftWoundSummaryView, rightWoundSummaryView=_rightWoundSummaryView;
@synthesize leftWoundPhotoView=_leftWoundPhotoView, rightWoundPhotoView=_rightWoundPhotoView, leftPlanView=_leftPlanView, rightPlanView=_rightPlanView;
@synthesize leftTreatmentView=_leftTreatmentView, rightTreatmentView=_rightTreatmentView;
@synthesize leftDataView=_leftDataView, rightDataView=_rightDataView;

- (NSArray *)templateNibNames
{
    return [NSArray arrayWithObjects:@"TemplateTwoColumnsTwoPhotosAssessment", @"TemplateTwoColumnsTwoPhotosGraphs", @"TemplateTwoColumnsTreatment", @"TemplateTwoColumnsPlan3", nil];
}

- (NSInteger)woundPhotosPerPage
{
    return 2;
}

- (void)drawToURL:(NSURL *)url
{
    [super drawToURL:url];
    // load the nib template
    self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:0] owner:self options:nil];
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(url.path, CGRectZero, self.pageInfoDictionary);
    // mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    // initialize paging and state
    NSInteger pageNumber = 1;
    CGFloat deltaY = 0.0;
    NSInteger indexWoundPhoto = 0;
    NSInteger indexWound = 0;
    // draw summary pages
    NSArray *wounds = self.printConfiguration.sortedWounds;
    // get total number of woundPhotos
    NSInteger woundPhotoCount = 0;
    for (WMWound *wound in wounds) {
        woundPhotoCount += [[self.printConfiguration sortedWoundPhotosForWound:wound] count];
    }
    // photos and assessments
    for (WMWound *wound in wounds) {
        self.wound = wound;
        // photos
        NSArray *woundPhotos = [self.printConfiguration sortedWoundPhotosForWound:wound];
        BOOL woundAssessmentRequiresFullPage = NO;
        for (WMWoundPhoto *woundPhoto in woundPhotos) {
            // check for next woundPhoto
            WMWoundPhoto *nextWoundPhoto = nil;
            if ((indexWoundPhoto + 1) < [woundPhotos count]) {
                nextWoundPhoto = [woundPhotos objectAtIndex:(indexWoundPhoto + 1)];
            } else if ((indexWound + 1) < [wounds count]) {
                // check in next wound
                WMWound *nextWound = [wounds objectAtIndex:(indexWound + 1)];
                NSArray *nextWoundPhotos = [self.printConfiguration sortedWoundPhotosForWound:nextWound];
                if ([nextWoundPhotos count] > 0) {
                    nextWoundPhoto = [nextWoundPhotos objectAtIndex:0];
                }
            }
            // determine if we need the whole page to render the wound assessment for wound/woundPhoto
            if (indexWoundPhoto % 2 == 0) {
                if (nil == nextWoundPhoto || [self woundAssessmentRequiresFullPage:woundPhoto]) {
                    woundAssessmentRequiresFullPage = YES;
                } else {
                    woundAssessmentRequiresFullPage = [self woundAssessmentRequiresFullPage:nextWoundPhoto];
                }
            }
            if (woundAssessmentRequiresFullPage) {
                [self drawWoundPhotoPage:woundPhoto pageNumber:pageNumber];
                ++indexWoundPhoto;
                if (indexWoundPhoto < woundPhotoCount) {
                    // new page
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                    ++pageNumber;
                }
                // continue to next woundPhoto
                continue;
            }
            // else render two photos per page
            if (indexWoundPhoto % 2 == 0) {
                // draw the page header
                [self drawPageHeader:pageNumber];
                // draw footer before we go to new page
                [self drawPageFooter:pageNumber];
                // adjust
                [self adjustPlaceholdersForWoundSummaryWoundPhotoLeft:woundPhoto woundPhotoRight:nextWoundPhoto];
                UIView *placeholderView = self.patientHeaderView;
                CGRect aFrame = [self.rootView convertRect:placeholderView.frame fromView:placeholderView.superview];
                [self drawPatientHeaderInRect:aFrame];
            }
            [self drawWoundSummaryForWound:wound atIndex:indexWoundPhoto draw:YES];
            // draw wound photo
            [self drawWoundPhoto:woundPhoto atIndex:indexWoundPhoto];
            // draw assessment
            [self drawAssessmentForWoundPhoto:woundPhoto atIndex:indexWoundPhoto];
            ++indexWoundPhoto;
            // check if we are moving to new page
            if ((indexWoundPhoto % 2) == 0 && indexWoundPhoto < woundPhotoCount) {
                // new page
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                ++pageNumber;
            }
        }
        ++indexWound;
    }
    // draw the plots - load the nib
    NSArray *graphableMeasurementTitlesWithSufficientData = self.graphableMeasurementTitlesWithSufficientData;
    if ([graphableMeasurementTitlesWithSufficientData count] > 0) {
        // new page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
        // load template
        self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:1] owner:self options:nil];
        indexWound = 0;
        BOOL oneWoundFlag = ([wounds count] == 1);
        for (WMWound *wound in wounds) {
            self.wound = wound;
            // dump our cache
            self.wountStatusMeasurementTitle2RollupByKeyMapMap = nil;
            BOOL drawLeftColumnFlag = (indexWound % 2) == 0;
            UIView *placeHolderView = (drawLeftColumnFlag ? self.leftColumnView:self.rightColumnView);
            CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
            // if only one wound, expand the plot area
            if (oneWoundFlag) {
                placeHolderView = self.rightColumnView;
                CGRect bFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
                aFrame = CGRectUnion(aFrame, bFrame);
            }
            // make adjustments for space needed to draw patient wound header
            WMWound *woundRight = nil;
            if ((indexWound + 1) < [wounds count]) {
                woundRight = [wounds objectAtIndex:(indexWound + 1)];
            }
            [self adjustPlaceholdersForWoundSummaryPlottingWoundLeft:wound woundRight:woundRight];
            // draw summary header
            [self drawPatientWoundHeader:wound atIndex:indexWound];
            // draw plots
            [self drawPlotsForWound:wound inRect:aFrame];
            // draw header/footer
            if ((indexWound % 2) == 0) {
                [self drawPageHeader:pageNumber];
                [self drawPageFooter:pageNumber];
            }
            // check if we are moving to new page
            if ((indexWound % 2) == 1 && (indexWound + 1) < [wounds count]) {
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                ++pageNumber;
            }
            ++indexWound;
        }
    }
    // draw the treatments - load the nib
    self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:2] owner:self options:nil];
    indexWound = 0;
    NSInteger woundTreatmentCount = [WMWound woundTreatmentCountForWounds:wounds];
    if (woundTreatmentCount > 0) {
        // move to next page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
        // draw header/footer
        [self drawPageHeader:pageNumber];
        [self drawPageFooter:pageNumber];
        for (WMWound *wound in wounds) {
            self.wound = wound;
            // check if another wound to render
            WMWound *nextWound = nil;
            if ((indexWound + 1) < [wounds count]) {
                nextWound = [wounds objectAtIndex:(indexWound + 1)];
            }
            // check if we can fit the treatment(s) into single column
            BOOL woundTreatmentRequiresFullPage = NO;
            if (indexWound % 2 == 0) {
                if (nil == nextWound || [self woundTreatmentRequiresFullPage:wound]) {
                    woundTreatmentRequiresFullPage = YES;
                } else {
                    woundTreatmentRequiresFullPage = [self woundTreatmentRequiresFullPage:nextWound];
                }
            }
            if (woundTreatmentRequiresFullPage) {
                [self drawWoundTreatmentPage:wound pageNumber:pageNumber];
                ++indexWound;
                // move to next page
                if (indexWound < [wounds count]) {
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                    ++pageNumber;
                    // draw header/footer
                    [self drawPageHeader:pageNumber];
                    [self drawPageFooter:pageNumber];
                }
                // continue to next woundPhoto
                continue;
            }
            //  else treatment for each wound - make adjustments for space needed to draw patient wound header
            [self adjustPlaceholdersForWoundSummaryPlottingWoundLeft:wound woundRight:nextWound];
            [self drawWoundSummaryForWound:wound atIndex:indexWound draw:YES];
            // draw treatment
            [self drawWoundTreatmentForWound:wound atIndex:indexWound];
            // check if we are moving to new page
            if ((woundTreatmentRequiresFullPage || (indexWound % 2) == 1) && (indexWound + 1) < [wounds count]) {
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                ++pageNumber;
            }
            ++indexWound;
        }
    }
    // draw Risk Assessmemt and Skin Assessment
    self.templateNibObjects = [[NSBundle mainBundle] loadNibNamed:[self.templateNibNames objectAtIndex:3] owner:self options:nil];
    BOOL skinAssessmentWasDrawn = NO;
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    if (self.printConfiguration.printRiskAssessment) {
        // move to next page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
        // draw header/footer
        [self drawPageHeader:pageNumber];
        [self drawPageFooter:pageNumber];
        // gather data into three columns
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
        if (self.printConfiguration.printSkinAssessment) {
            skinAssessmentWasDrawn = YES;
            WMSkinAssessmentGroup *skinAssessmentGroup = [WMSkinAssessmentGroup mostRecentOrActiveSkinAssessmentGroup:self.printConfiguration.managedObjectContext];
            if (nil != skinAssessmentGroup) {
                [mutableAttributedString appendAttributedString:[skinAssessmentGroup descriptionAsMutableAttributedStringWithBaseFontSize:self.defaultFontSize]];
                [mutableAttributedString appendAttributedString:paragraphAttributedString];
            }
        }
        WMMedicationGroup *medicationGroup = [WMMedicationGroup mostRecentOrActiveMedicationGroup:self.printConfiguration.managedObjectContext];
        if (nil != medicationGroup) {
            [mutableAttributedString appendAttributedString:[medicationGroup descriptionAsMutableAttributedStringWithBaseFontSize:self.defaultFontSize]];
        }
        WMDeviceGroup *deviceGroup = [WMDeviceGroup mostRecentOrActiveDeviceGroup:self.printConfiguration.managedObjectContext];
        if (nil != deviceGroup) {
            if ([mutableAttributedString length] > 0) {
                [mutableAttributedString appendAttributedString:paragraphAttributedString];
            }
            [mutableAttributedString appendAttributedString:[deviceGroup descriptionAsMutableAttributedStringWithBaseFontSize:self.defaultFontSize]];
        }
        WMPsychoSocialGroup *psychoSocialGroup = [WMPsychoSocialGroup mostRecentOrActivePsychosocialGroup:self.printConfiguration.managedObjectContext];
        if (nil != psychoSocialGroup) {
            if ([mutableAttributedString length] > 0) {
                [mutableAttributedString appendAttributedString:paragraphAttributedString];
            }
            [mutableAttributedString appendAttributedString:[psychoSocialGroup descriptionAsMutableAttributedStringWithBaseFontSize:self.defaultFontSize]];
        }
        UIView *placeHolderView = self.leftColumnView;
        CGRect frame1 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.middleColumnView;
        CGRect frame2 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.rightColumnView;
        CGRect frame3 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        deltaY = [self drawAttributedString:mutableAttributedString
                                   rectLeft:frame1
                                 rectMiddle:frame2
                                  rectRight:frame3];
    }
    if (!skinAssessmentWasDrawn && self.printConfiguration.printSkinAssessment) {
        // move to next page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
        // draw header/footer
        [self drawPageHeader:pageNumber];
        [self drawPageFooter:pageNumber];
        // gather data
        UIView *placeHolderView = self.leftColumnView;
        CGRect frame1 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.middleColumnView;
        CGRect frame2 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.rightColumnView;
        CGRect frame3 = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        deltaY = [self drawAttributedStringForDataSource:[WMSkinAssessmentGroup mostRecentOrActiveSkinAssessmentGroup:self.printConfiguration.managedObjectContext]
                                   rectLeft:frame1
                                 rectMiddle:frame2
                                  rectRight:frame3];
    }
    if (self.printConfiguration.printCarePlan) {
        // move to next page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        ++pageNumber;
        // draw header/footer
        [self drawPageHeader:pageNumber];
        [self drawPageFooter:pageNumber];
        // draw in leftColumnView, middleColumnView, and rightColumnView
        UIView *placeHolderView = self.leftColumnView;
        CGRect aFrameLeft = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.middleColumnView;
        CGRect aFrameMiddle = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        placeHolderView = self.rightColumnView;
        CGRect aFrameRight = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
        deltaY = [self drawAttributedStringForDataSource:[WMCarePlanGroup mostRecentOrActiveCarePlanGroup:self.printConfiguration.managedObjectContext]
                                                rectLeft:aFrameLeft
                                              rectMiddle:aFrameMiddle
                                               rectRight:aFrameRight];
    }
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (void)drawWoundPhotoPage:(WMWoundPhoto *)woundPhoto pageNumber:(NSInteger)pageNumber
{
    // patient header
    UIView *placeholderView = self.patientHeaderView;
    CGRect aFrame = [self.rootView convertRect:placeholderView.frame fromView:placeholderView.superview];
    [self drawPatientHeaderInRect:aFrame];
    // wound in combined views
    UIView *placeHolderView = self.leftWoundSummaryView;
    aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    placeHolderView = self.rightWoundSummaryView;
    aFrame = CGRectUnion(aFrame, [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview]);
    [self drawWoundSummaryForWound:woundPhoto.wound inRect:aFrame draw:YES];
    // woundPhoto in combine views
    placeHolderView = self.leftWoundPhotoView;
    aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    placeHolderView = self.rightWoundPhotoView;
    aFrame = CGRectUnion(aFrame, [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview]);
    [self drawWoundPhoto:woundPhoto inRect:aFrame];
    // wound assessment (woundMeasurement)
    placeHolderView = self.leftDataView;
    CGRect frameLeft = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    placeHolderView = self.rightDataView;
    CGRect frameRight = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    [self drawAttributedStringForDataSource:[WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:woundPhoto]
                                   rectLeft:frameLeft
                                 rectMiddle:CGRectZero
                                  rectRight:frameRight];
    // draw the page header
    [self drawPageHeader:pageNumber];
    // draw footer before we go to new page
    [self drawPageFooter:pageNumber];
}

- (void)drawWoundTreatmentPage:(WMWound *)wound pageNumber:(NSInteger)pageNumber
{
    // wound in combined views
    UIView *placeHolderView = self.leftWoundSummaryView;
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    placeHolderView = self.rightWoundSummaryView;
    aFrame = CGRectUnion(aFrame, [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview]);
    [self drawWoundSummaryForWound:wound inRect:aFrame draw:YES];
    // wound treatment
    placeHolderView = self.leftColumnView;
    CGRect frameLeft = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    placeHolderView = self.rightColumnView;
    CGRect frameRight = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    [self drawAttributedStringForDataSource:wound.lastWoundTreatmentGroup
                                   rectLeft:frameLeft
                                 rectMiddle:CGRectZero
                                  rectRight:frameRight];
    // draw the page header
    [self drawPageHeader:pageNumber];
    // draw footer before we go to new page
    [self drawPageFooter:pageNumber];
}

- (CGFloat)drawWoundSummaryForWound:(WMWound *)wound atIndex:(NSInteger)index draw:(BOOL)draw
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftWoundSummaryView:self.rightWoundSummaryView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawWoundSummaryForWound:wound inRect:aFrame draw:draw];
    CGFloat deltaY = expectedMaxY - actualMaxY;
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

- (BOOL)woundAssessmentRequiresFullPage:(WMWoundPhoto *)woundPhoto
{
    WMWoundMeasurementGroup *woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:woundPhoto];
    if (nil == woundMeasurementGroup) {
        return NO;
    }
    // else
    CGRect frame = self.leftDataView.frame;
    frame.size.height *= 2.0;
    NSMutableAttributedString *mutableAttributedString = [self attributedStringForCoreTextDataSource:woundMeasurementGroup
                                                                                            rectLeft:self.leftDataView.frame
                                                                                          rectMiddle:CGRectZero
                                                                                           rectRight:CGRectZero];
    return (nil == mutableAttributedString);
}

- (BOOL)woundTreatmentRequiresFullPage:(WMWound *)wound
{
    WMWoundTreatmentGroup *woundTreatmentGroup = wound.lastWoundTreatmentGroup;
    if (nil == woundTreatmentGroup) {
        return NO;
    }
    // else
    CGRect frame = self.leftColumnView.frame;
    frame.size.height *= 2.0;
    NSMutableAttributedString *mutableAttributedString = [self attributedStringForCoreTextDataSource:woundTreatmentGroup
                                                                                            rectLeft:self.leftDataView.frame
                                                                                          rectMiddle:CGRectZero
                                                                                           rectRight:CGRectZero];
    return (nil == mutableAttributedString);
}

- (void)adjustPlaceholdersForWoundSummaryWoundPhotoLeft:(WMWoundPhoto *)woundPhotoLeft woundPhotoRight:(WMWoundPhoto *)woundPhotoRight
{
    UIView *placeHolderView = self.leftWoundSummaryView;//:self.rightWoundSummaryView);
    CGRect aFrame = placeHolderView.frame;
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualLeftMaxY = [self drawWoundSummaryForWound:woundPhotoLeft.wound inRect:aFrame draw:NO];
    CGFloat actualRightMaxY = 0.0;
    if (nil != woundPhotoRight) {
        actualRightMaxY = [self drawWoundSummaryForWound:woundPhotoRight.wound inRect:aFrame draw:NO];
    }
    CGFloat actualMaxY = MAX(actualLeftMaxY, actualRightMaxY);
    CGFloat deltaY = expectedMaxY - actualMaxY;
    if (deltaY < 0.0) {
        // we need to adjust the size of the photo placeholders - note deltaY is negative, so we are downsizing the photo space
        placeHolderView = self.leftWoundPhotoView;
        aFrame = placeHolderView.frame;
        aFrame.origin.y -= deltaY;
        aFrame.size.height += deltaY;
        placeHolderView.frame = aFrame;
        placeHolderView = self.rightWoundPhotoView;
        aFrame = placeHolderView.frame;
        aFrame.origin.y -= deltaY;
        aFrame.size.height += deltaY;
        placeHolderView.frame = aFrame;
    }
}

#define Plot_Height 120.0
#define Plot_InterstitialY 4.0

- (CGFloat)drawAssessmentForWoundPhoto:(WMWoundPhoto *)woundPhoto atIndex:(NSInteger)index
{
    WMWoundMeasurementGroup *woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:woundPhoto];
    UIView *placeHolderView = (index % 2 == 0 ? self.leftDataView:self.rightDataView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    return [self drawAttributedStringForDataSource:woundMeasurementGroup
                                          rectLeft:aFrame
                                        rectMiddle:CGRectZero
                                         rectRight:CGRectZero];
}

- (void)adjustPlaceholdersForWoundSummaryPlottingWoundLeft:(WMWound *)woundLeft woundRight:(WMWound *)woundRight
{
    UIView *placeHolderView = self.leftWoundSummaryView;
    CGRect aFrame = placeHolderView.frame;
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualLeftMaxY = [self drawWoundSummaryForWound:woundLeft inRect:aFrame draw:NO];
    CGFloat actualRightMaxY = 0.0;
    if (nil != woundRight) {
        actualRightMaxY = [self drawWoundSummaryForWound:woundRight inRect:aFrame draw:NO];
    }
    CGFloat actualMaxY = MAX(actualLeftMaxY, actualRightMaxY);
    CGFloat deltaY = (expectedMaxY - actualMaxY);
    if (deltaY < 0) {
        // adjust views below
        placeHolderView = self.leftColumnView;
        aFrame = placeHolderView.frame;
        aFrame.origin.y -= deltaY;
        aFrame.size.height += deltaY;
        self.leftColumnView.frame = aFrame;
        placeHolderView = self.rightColumnView;
        aFrame = placeHolderView.frame;
        aFrame.origin.y -= deltaY;
        aFrame.size.height += deltaY;
        self.rightColumnView.frame = aFrame;
    }
}

- (CGFloat)drawPatientWoundHeader:(WMWound *)wound atIndex:(NSInteger)index
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftWoundSummaryView:self.rightWoundSummaryView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat actualMaxY = [self drawPatientWoundHeader:wound inRect:aFrame draw:YES];
    CGFloat deltaY = expectedMaxY - actualMaxY;
    return deltaY;
}

- (CGFloat)drawWoundTreatmentForWound:(WMWound *)wound atIndex:(NSInteger)index
{
    BOOL drawLeftColumnFlag = (index % 2) == 0;
    UIView *placeHolderView = (drawLeftColumnFlag ? self.leftColumnView:self.rightColumnView);
    CGRect aFrame = [self.rootView convertRect:placeHolderView.frame fromView:placeHolderView.superview];
    CGFloat expectedMaxY = CGRectGetMaxY(aFrame);
    CGFloat preferredHeight = [self drawWoundTreatmentForWound:wound inRect:aFrame draw:YES];
    CGFloat deltaY = CGRectGetMinY(aFrame) + preferredHeight - expectedMaxY;
    return deltaY;
}

#define Plot_InterstitialY 4.0
#define Plot_HorizontalCorrectionMultiplierX 1.0
#define Plot_VerticalCorrectionFudgeY 192.0

- (void)drawPlotsForWound:(WMWound *)wound inRect:(CGRect)aFrame
{
    // determine the number of plots
    NSArray *graphableMeasurementTitlesWithSufficientData = self.graphableMeasurementTitlesWithSufficientData;
    NSInteger numberOfPlots = [graphableMeasurementTitlesWithSufficientData count];
    if (0 == numberOfPlots) {
        return;
    }
    // else
    CGFloat height = CGRectGetHeight(aFrame);
    CGFloat plotHeight = roundf((height - (numberOfPlots - 1) * Plot_InterstitialY)/numberOfPlots);
    plotHeight = MIN(plotHeight, 260.0);
    // precalculate position for graph
    CGFloat minPlotX = Plot_HorizontalCorrectionMultiplierX * CGRectGetMinX(aFrame);
    CGFloat minPlotY = CGRectGetMinY(aFrame) + plotHeight;//Plot_VerticalCorrectionFudgeY;
    CGFloat plotWidth = CGRectGetWidth(aFrame);
    // determine the initial y location of first plot
    for (NSString *woundStatusMeasurementTitle in graphableMeasurementTitlesWithSufficientData) {
        CGRect plotFrame = CGRectMake(minPlotX, minPlotY, plotWidth, plotHeight);
        [self drawPlotForMeasurementTitle:woundStatusMeasurementTitle frame:plotFrame];
        minPlotY += (plotHeight + Plot_InterstitialY);
    }
}


@end
