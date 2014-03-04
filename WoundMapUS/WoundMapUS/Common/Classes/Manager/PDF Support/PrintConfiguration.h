//
//  PrintConfiguration.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/25/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMPDFPrintManager.h"

typedef enum {
    SelectWoundAndActionShareOption_Print,
    SelectWoundAndActionShareOption_Email,
    SelectWoundAndActionShareOption_EMR,
    SelectWoundAndActionShareOption_iCloud
} SelectWoundAndActionShareOption;

@class WMWound;

@interface PrintConfiguration : NSObject

@property (nonatomic) PrintTemplate printTemplate;
@property (strong, nonatomic) NSMutableDictionary *selectedWoundPhotosMap;  // map [wound objectID] -> NSMutableSet of WCWoundPhotos
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext; // to resolve core data
@property (strong, nonatomic) NSString *password;                           // password to encrypt PDF email attachment
@property (nonatomic) BOOL printRiskAssessment;                             // YES if have and choose to draw Risk Assessment (Braden always drawn)
@property (nonatomic) BOOL printSkinAssessment;                             // YES if have and choose to draw Skin Assessment
@property (nonatomic) BOOL printCarePlan;                                   // YES if have and choose to draw Care Plan

@property (strong, nonatomic) NSArray *sortedWounds;

- (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound;

@end
