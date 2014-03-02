// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatus.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionStatusAttributes {
	__unsafe_unretained NSString *activeFlag;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wminterventionstatus_id;
} WMInterventionStatusAttributes;

extern const struct WMInterventionStatusRelationships {
	__unsafe_unretained NSString *carePlanGroups;
	__unsafe_unretained NSString *deviceGroups;
	__unsafe_unretained NSString *fromStatusJoins;
	__unsafe_unretained NSString *measurementGroups;
	__unsafe_unretained NSString *medicationGroups;
	__unsafe_unretained NSString *psychoSocialGroups;
	__unsafe_unretained NSString *skinAssessmentGroups;
	__unsafe_unretained NSString *toStatusJoins;
	__unsafe_unretained NSString *treatmentGroups;
} WMInterventionStatusRelationships;

extern const struct WMInterventionStatusFetchedProperties {
} WMInterventionStatusFetchedProperties;

@class WMCarePlanGroup;
@class WMDeviceGroup;
@class WMInterventionStatusJoin;
@class WMWoundMeasurementGroup;
@class WMMedicationGroup;
@class WMPsychoSocialGroup;
@class WMSkinAssessmentGroup;
@class WMInterventionStatusJoin;
@class WMWoundTreatmentGroup;













@interface WMInterventionStatusID : NSManagedObjectID {}
@end

@interface _WMInterventionStatus : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInterventionStatusID*)objectID;





@property (nonatomic, strong) NSNumber* activeFlag;



@property BOOL activeFlagValue;
- (BOOL)activeFlagValue;
- (void)setActiveFlagValue:(BOOL)value_;

//- (BOOL)validateActiveFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* loincCode;



//- (BOOL)validateLoincCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* snomedCID;



@property int64_t snomedCIDValue;
- (int64_t)snomedCIDValue;
- (void)setSnomedCIDValue:(int64_t)value_;

//- (BOOL)validateSnomedCID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* snomedFSN;



//- (BOOL)validateSnomedFSN:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wminterventionstatus_id;



//- (BOOL)validateWminterventionstatus_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *carePlanGroups;

- (NSMutableSet*)carePlanGroupsSet;




@property (nonatomic, strong) NSSet *deviceGroups;

- (NSMutableSet*)deviceGroupsSet;




@property (nonatomic, strong) NSSet *fromStatusJoins;

- (NSMutableSet*)fromStatusJoinsSet;




@property (nonatomic, strong) NSSet *measurementGroups;

- (NSMutableSet*)measurementGroupsSet;




@property (nonatomic, strong) NSSet *medicationGroups;

- (NSMutableSet*)medicationGroupsSet;




@property (nonatomic, strong) NSSet *psychoSocialGroups;

- (NSMutableSet*)psychoSocialGroupsSet;




@property (nonatomic, strong) NSSet *skinAssessmentGroups;

- (NSMutableSet*)skinAssessmentGroupsSet;




@property (nonatomic, strong) NSSet *toStatusJoins;

- (NSMutableSet*)toStatusJoinsSet;




@property (nonatomic, strong) NSSet *treatmentGroups;

- (NSMutableSet*)treatmentGroupsSet;





@end

@interface _WMInterventionStatus (CoreDataGeneratedAccessors)

- (void)addCarePlanGroups:(NSSet*)value_;
- (void)removeCarePlanGroups:(NSSet*)value_;
- (void)addCarePlanGroupsObject:(WMCarePlanGroup*)value_;
- (void)removeCarePlanGroupsObject:(WMCarePlanGroup*)value_;

- (void)addDeviceGroups:(NSSet*)value_;
- (void)removeDeviceGroups:(NSSet*)value_;
- (void)addDeviceGroupsObject:(WMDeviceGroup*)value_;
- (void)removeDeviceGroupsObject:(WMDeviceGroup*)value_;

- (void)addFromStatusJoins:(NSSet*)value_;
- (void)removeFromStatusJoins:(NSSet*)value_;
- (void)addFromStatusJoinsObject:(WMInterventionStatusJoin*)value_;
- (void)removeFromStatusJoinsObject:(WMInterventionStatusJoin*)value_;

- (void)addMeasurementGroups:(NSSet*)value_;
- (void)removeMeasurementGroups:(NSSet*)value_;
- (void)addMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;
- (void)removeMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;

- (void)addMedicationGroups:(NSSet*)value_;
- (void)removeMedicationGroups:(NSSet*)value_;
- (void)addMedicationGroupsObject:(WMMedicationGroup*)value_;
- (void)removeMedicationGroupsObject:(WMMedicationGroup*)value_;

- (void)addPsychoSocialGroups:(NSSet*)value_;
- (void)removePsychoSocialGroups:(NSSet*)value_;
- (void)addPsychoSocialGroupsObject:(WMPsychoSocialGroup*)value_;
- (void)removePsychoSocialGroupsObject:(WMPsychoSocialGroup*)value_;

- (void)addSkinAssessmentGroups:(NSSet*)value_;
- (void)removeSkinAssessmentGroups:(NSSet*)value_;
- (void)addSkinAssessmentGroupsObject:(WMSkinAssessmentGroup*)value_;
- (void)removeSkinAssessmentGroupsObject:(WMSkinAssessmentGroup*)value_;

- (void)addToStatusJoins:(NSSet*)value_;
- (void)removeToStatusJoins:(NSSet*)value_;
- (void)addToStatusJoinsObject:(WMInterventionStatusJoin*)value_;
- (void)removeToStatusJoinsObject:(WMInterventionStatusJoin*)value_;

- (void)addTreatmentGroups:(NSSet*)value_;
- (void)removeTreatmentGroups:(NSSet*)value_;
- (void)addTreatmentGroupsObject:(WMWoundTreatmentGroup*)value_;
- (void)removeTreatmentGroupsObject:(WMWoundTreatmentGroup*)value_;

@end

@interface _WMInterventionStatus (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActiveFlag;
- (void)setPrimitiveActiveFlag:(NSNumber*)value;

- (BOOL)primitiveActiveFlagValue;
- (void)setPrimitiveActiveFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveLoincCode;
- (void)setPrimitiveLoincCode:(NSString*)value;




- (NSNumber*)primitiveSnomedCID;
- (void)setPrimitiveSnomedCID:(NSNumber*)value;

- (int64_t)primitiveSnomedCIDValue;
- (void)setPrimitiveSnomedCIDValue:(int64_t)value_;




- (NSString*)primitiveSnomedFSN;
- (void)setPrimitiveSnomedFSN:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWminterventionstatus_id;
- (void)setPrimitiveWminterventionstatus_id:(NSString*)value;





- (NSMutableSet*)primitiveCarePlanGroups;
- (void)setPrimitiveCarePlanGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDeviceGroups;
- (void)setPrimitiveDeviceGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveFromStatusJoins;
- (void)setPrimitiveFromStatusJoins:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMeasurementGroups;
- (void)setPrimitiveMeasurementGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMedicationGroups;
- (void)setPrimitiveMedicationGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitivePsychoSocialGroups;
- (void)setPrimitivePsychoSocialGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSkinAssessmentGroups;
- (void)setPrimitiveSkinAssessmentGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveToStatusJoins;
- (void)setPrimitiveToStatusJoins:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTreatmentGroups;
- (void)setPrimitiveTreatmentGroups:(NSMutableSet*)value;


@end
