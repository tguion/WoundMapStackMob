// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMSkinAssessmentGroupAttributes {
	__unsafe_unretained NSString *closedFlag;
	__unsafe_unretained NSString *continueCount;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *wmskinassessmentgroup_id;
} WMSkinAssessmentGroupAttributes;

extern const struct WMSkinAssessmentGroupRelationships {
	__unsafe_unretained NSString *interventionEvents;
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *values;
} WMSkinAssessmentGroupRelationships;

extern const struct WMSkinAssessmentGroupFetchedProperties {
} WMSkinAssessmentGroupFetchedProperties;

@class WMSkinAssessmentIntEvent;
@class WMPatient;
@class WMInterventionStatus;
@class WMSkinAssessmentValue;











@interface WMSkinAssessmentGroupID : NSManagedObjectID {}
@end

@interface _WMSkinAssessmentGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMSkinAssessmentGroupID*)objectID;





@property (nonatomic, strong) NSNumber* closedFlag;



@property BOOL closedFlagValue;
- (BOOL)closedFlagValue;
- (void)setClosedFlagValue:(BOOL)value_;

//- (BOOL)validateClosedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* continueCount;



@property int16_t continueCountValue;
- (int16_t)continueCountValue;
- (void)setContinueCountValue:(int16_t)value_;

//- (BOOL)validateContinueCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmskinassessmentgroup_id;



//- (BOOL)validateWmskinassessmentgroup_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *interventionEvents;

- (NSMutableSet*)interventionEventsSet;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionStatus *status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;





@end

@interface _WMSkinAssessmentGroup (CoreDataGeneratedAccessors)

- (void)addInterventionEvents:(NSSet*)value_;
- (void)removeInterventionEvents:(NSSet*)value_;
- (void)addInterventionEventsObject:(WMSkinAssessmentIntEvent*)value_;
- (void)removeInterventionEventsObject:(WMSkinAssessmentIntEvent*)value_;

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMSkinAssessmentValue*)value_;
- (void)removeValuesObject:(WMSkinAssessmentValue*)value_;

@end

@interface _WMSkinAssessmentGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClosedFlag;
- (void)setPrimitiveClosedFlag:(NSNumber*)value;

- (BOOL)primitiveClosedFlagValue;
- (void)setPrimitiveClosedFlagValue:(BOOL)value_;




- (NSNumber*)primitiveContinueCount;
- (void)setPrimitiveContinueCount:(NSNumber*)value;

- (int16_t)primitiveContinueCountValue;
- (void)setPrimitiveContinueCountValue:(int16_t)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveWmskinassessmentgroup_id;
- (void)setPrimitiveWmskinassessmentgroup_id:(NSString*)value;





- (NSMutableSet*)primitiveInterventionEvents;
- (void)setPrimitiveInterventionEvents:(NSMutableSet*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (WMInterventionStatus*)primitiveStatus;
- (void)setPrimitiveStatus:(WMInterventionStatus*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;


@end
