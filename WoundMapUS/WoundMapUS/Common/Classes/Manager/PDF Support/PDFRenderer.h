//
//  PDFRenderer.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/26/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CorePlot-CocoaTouch.h"
#import "WoundCareProtocols.h"

#define kPDFBorderInset            20.0
#define kPDFBorderWidth            1.0
#define kPDFMarginInset            10.0
#define kPDFLineWidth              0.5

@class WCPatient, WCWound, WCWoundPhoto;
@class WCAppDelegate, UserDefaultsManager, PrintConfiguration;
@class WCWoundTreatmentGroup, WCWoundTreatment, WCMedicationGroup, WCDeviceGroup, WCPsychoSocialGroup, WCSkinAssessmentGroup, WCCarePlanGroup, WCCarePlanCategory, WCWoundMeasurementGroup;

@interface PDFRenderer : NSObject

@property (nonatomic) CGFloat defaultFontSize;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) UserDefaultsManager *userDefaultsManager;
@property (nonatomic) CGRect pageRect;
@property (nonatomic) CGSize pageSize;
@property (readonly, nonatomic) NSDictionary *pageInfoDictionary;       // dictionary with password and other pageInfo (see CGPDFContext Reference)

@property (readonly, nonatomic) NSArray *keyColors;                     // colors for each key
@property (readonly, nonatomic) NSArray *keySymbols;                    // symbols for each key

@property (strong, nonatomic) WCPatient *patient;                       // patient whos data is being rendered
@property (strong, nonatomic) WCWound *wound;                           // current patient wound data is being rendered
@property (strong, nonatomic) PrintConfiguration *printConfiguration;   // print configuration set for this rendering

@property (readonly, nonatomic) NSArray *templateNibNames;              // nibs used to help layout pdf
@property (strong, nonatomic) NSArray *templateNibObjects;              // nibs read

@property (weak, nonatomic) IBOutlet UIView *patientHeaderView;         // placeholder view container for patient text and graph
@property (weak, nonatomic) IBOutlet UIView *patientDataSummaryView;    // placeholder view to draw patient data (BradenScale)
@property (weak, nonatomic) IBOutlet UIView *bradenScaleGraphView;      // placeholder view to draw BradenScale graph

@property (weak, nonatomic) IBOutlet UIView *rootView;                  // outer view - the page
@property (weak, nonatomic) IBOutlet UIView *contentView;               // inner view accounting for margins
@property (weak, nonatomic) IBOutlet UIView *pageHeaderView;            // page header
@property (weak, nonatomic) IBOutlet UIView *pageFooterView;            // page footer
@property (readonly, nonatomic) NSInteger woundPhotosPerPage;           // number of photos rendered per page
@property (nonatomic) NSInteger lastPageNumber;                         // last page

// Dimensions, Tissue in Wound, ..., add Braden Scale
@property (strong, nonatomic) NSArray *graphableMeasurementTitles;
@property (strong, nonatomic) CPTGraphHostingView *hostingView;         // view hosting current graph
@property (strong, nonatomic) NSString *woundStatusMeasurementTitle;    // title of current plot data source, e.g. Margins/Edges with key Irregular
@property (readonly, nonatomic) NSArray *graphableMeasurementTitlesWithSufficientData;
// all graphable data for current patient/woundPhoto - map for WCWoundMeasurement.title to map of key -> WoundStatusMeasurementRollup instances
@property (strong, nonatomic) NSMutableDictionary *wountStatusMeasurementTitle2RollupByKeyMapMap;

+ (CGRect)aspectFittedRect:(CGRect)inRect max:(CGRect)maxRect;

- (void)drawToURL:(NSURL *)url;

- (void)drawBorder;
- (void)drawLineAtYOffset:(CGFloat)yOffset color:(UIColor *)color;
- (CGFloat)drawPatientHeaderInRect:(CGRect)rect;                        // return maxY (if negative, needed less vertical space to draw)
- (CGFloat)drawPatientWoundHeader:(WCWound *)wound inRect:(CGRect)rect draw:(BOOL)draw;
- (CGFloat)drawWoundSummaryForWound:(WCWound *)wound inRect:(CGRect)rect draw:(BOOL)draw;
- (CGFloat)drawWoundPhoto:(WCWoundPhoto *)woundPhoto inRect:(CGRect)rect;

- (NSMutableAttributedString *)attributedStringForCoreTextDataSource:(id<WCCoreTextDataSource>)coreTextDataSource
                                                            rectLeft:(CGRect)frameLeft
                                                          rectMiddle:(CGRect)frameMiddle
                                                           rectRight:(CGRect)frameRight;
- (CGFloat)drawAttributedStringForDataSource:(id<WCCoreTextDataSource>)coreTextDataSource
                                    rectLeft:(CGRect)frameLeft
                                  rectMiddle:(CGRect)frameMiddle
                                   rectRight:(CGRect)frameRight;
- (CGFloat)drawAttributedString:(NSMutableAttributedString *)attributedString
                       rectLeft:(CGRect)frameLeft
                     rectMiddle:(CGRect)frameMiddle
                      rectRight:(CGRect)frameRight;

- (CGFloat)drawWoundTreatmentForWound:(WCWound *)wound inRect:(CGRect)rect draw:(BOOL)draw;
- (CGFloat)drawWoundTreatment:(WCWoundTreatmentGroup *)woundTreatmentGroup inRect:(CGRect)aFrame draw:(BOOL)draw;
- (void)drawPageHeader:(NSInteger)pageNumber;
- (void)drawPageFooter:(NSInteger)pageNumber;

- (void)drawLineString:(NSString *)string inFrame:(CGRect)rect fontSize:(CGFloat)fontSize bold:(BOOL)bold;
- (void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect fontSize:(CGFloat)fontSize bold:(BOOL)bold centered:(BOOL)centered;
- (void)adjustPlaceholdersBelow:(CGFloat)y byAmount:(CGFloat)deltaY;

- (void)drawBradenScalePlotForFrame:(CGRect)frame;
- (void)drawPlotForMeasurementTitle:(NSString *)woundStatusMeasurementTitle frame:(CGRect)frame;
- (void)prepareForPlot;

@end
