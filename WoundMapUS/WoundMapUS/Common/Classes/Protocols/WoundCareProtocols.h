//
//  WoundCareProtocols.h
//  WoundCare
//
//  Created by Todd Guion on 7/29/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#ifndef WoundCare_WoundCareProtocols_h
#define WoundCare_WoundCareProtocols_h



#endif

typedef void (^WMProcessCallback)(NSError *error, NSArray *objectIDs, NSString *collection);
typedef void (^WMProcessCallbackWithCallback)(NSError *error, NSArray *objectIDs, NSString *collection, dispatch_block_t callBack);

@protocol NavigationItemTitleViewSource <NSObject>
- (UIView *)editorTitleView:(id)object;
@end

typedef enum {
    GroupValueTypeCodeSelect                    = 0,    // simple select
    GroupValueTypeCodeValue1Select              = 1,    // simple select, shows value as UITableViewCellStyleValue1
    GroupValueTypeCodeInlineTextField           = 2,    // enter text inline
    GroupValueTypeCodeInlineExtendsTextField    = 12,   // enter text inline prefix "Extends out _ cm
    GroupValueTypeCodeInlineOptions             = 3,    // segmented control inline
    GroupValueTypeCodeInlineNoImageOptions      = 11,   // segmented control inline, centered, w/o selection image
    GroupValueTypeCodeDefaultNavigateToOptions  = 4,    // navigate to multiple selections, shows value as UITableViewCellStyleDefault
    GroupValueTypeCodeValue1NavigateToOptions   = 5,    // navigate to multiple selections, shows value as UITableViewCellStyleValue1
    GroupValueTypeCodeValue1NavigateToAmounts   = 13,   // navigate to WCAmountQualifer, shows value as UITableViewCellStyleValue1
    GroupValueTypeCodeValue1NavigateToOdors     = 14,   // navigate to WCWoundOdor, shows value as UITableViewCellStyleValue1
    GroupValueTypeCodeSubtitleNavigateToOptions = 6,    // navigate to multiple selections, shows value as UITableViewCellStyleSubtitle
    GroupValueTypeCodeInlineSwitch              = 7,    // YES/NO switch inline
    GroupValueTypeCodeNoImageInlineSwitch       = 8,    // YES/NO switch inline w/out selection image
    GroupValueTypeCodeInlineSlider              = 9,    // slider inline
    GroupValueTypeCodeInlineSliderPercentage    = 10,   // slider inline percentage with supporting text field
    GroupValueTypeCodeUndermineTunnel           = 15,   // navigate to U&T
    GroupValueTypeCodeNavigateToNote            = 16,   // navigate to Note
    GroupValueTypeCodeQuestionWithOptions       = 17,   // multiline text label, subtitle, with segmented answers under question
    GroupValueTypeCodeQuestionNavigateOptions   = 18,   // multiline text label, value1, navigate to subitems
} GroupValueTypeCode;

typedef enum {
    kInitialStageNode   = 5,
    kFollowupStageNode  = 6,
    kDischargeStageNode = 7,
    kSelectPatientNode  = 10,
    kEditPatientNode    = 20,
    kAddPatientNode     = 30,
    kSelectWoundNode    = 40,
    kEditWoundNode      = 50,
    kAddWoundNode       = 60,
    kWoundsNode         = 65,
    kSelectStageNode    = 70,
    kRiskAssessmentNode = 80,
    kBradenScaleNode    = 81,
    kMedicationsNode    = 82,
    kDevicesNode        = 83,
    kPsycoSocialNode    = 84,
    kNutritionNode      = 85,
    kSkinAssessmentNode = 90,
    kPhotoNode          = 100,
    kTakePhotoNode      = 101,
    kMeasurePhotoNode   = 102,
    kWoundAssessmentNode= 103,
    kWoundTreatmentNode = 110,
    kCarePlanNode       = 120,
    kBrowsePhotosNode   = 200,
    kViewGraphsNode     = 210,
    kPatientSummaryNode = 212,
    kShareNode          = 220,
    kEmailReportNode    = 221,
    kPrintReportNode    = 222,
    kPushEMRNode        = 223,
} NavigationNodeIdentifier;

@protocol AssessmentGroup <NSObject>

@property (readonly, nonatomic) GroupValueTypeCode groupValueTypeCode;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSString *placeHolder;
@property (strong, nonatomic) NSString *unit;
@property (readonly, nonatomic) NSArray *optionsArray;
@property (readonly, nonatomic) NSArray *secondaryOptionsArray;

@end

@protocol WCCoreTextDataSource <NSObject>

@property (readonly, nonatomic) NSManagedObjectID *objectID;

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize;

@end

@class WMAddress;

@protocol AddressSource <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) NSSet *addresses;

- (NSSet *)addressesWithRefreshHandler:(dispatch_block_t)handler;

- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(WMAddress*)value_;
- (void)removeAddressesObject:(WMAddress*)value_;

@end

@class WMTelecom;

@protocol TelecomSource <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) NSSet *telecoms;

- (NSSet *)telecomsWithRefreshHandler:(dispatch_block_t)handler;

- (void)addTelecoms:(NSSet*)value_;
- (void)removeTelecoms:(NSSet*)value_;
- (void)addTelecomsObject:(WMTelecom*)value_;
- (void)removeTelecomsObject:(WMTelecom*)value_;

@end

@class WMId;

@protocol idSource <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) NSSet *ids;

- (void)addIds:(NSSet*)value_;
- (void)removeIds:(NSSet*)value_;
- (void)addIdsObject:(WMId*)value_;
- (void)removeIdsObject:(WMId*)value_;

@end

