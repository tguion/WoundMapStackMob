// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionEvent.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionEventAttributes {
	__unsafe_unretained NSString *changeType;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateEvent;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *valueFrom;
	__unsafe_unretained NSString *valueTo;
} WMInterventionEventAttributes;

extern const struct WMInterventionEventRelationships {
	__unsafe_unretained NSString *carePlanGroup;
	__unsafe_unretained NSString *deviceGroup;
	__unsafe_unretained NSString *eventType;
	__unsafe_unretained NSString *medicationGroup;
	__unsafe_unretained NSString *participant;
	__unsafe_unretained NSString *psychoSocialGroup;
	__unsafe_unretained NSString *skinAssessmentGroup;
	__unsafe_unretained NSString *woundMeasurementGroup;
	__unsafe_unretained NSString *woundTreatmentGroup;
} WMInterventionEventRelationships;

extern const struct WMInterventionEventFetchedProperties {
} WMInterventionEventFetchedProperties;

@class WMCarePlanGroup;
@class WMDeviceGroup;
@class WMInterventionEventType;
@class WMMedicationGroup;
@class WMParticipant;
@class WMPsychoSocialGroup;
@class WMSkinAssessmentGroup;
@class WMWoundMeasurementGroup;
@class WMWoundTreatmentGroup;












@interface WMInterventionEventID : NSManagedObjectID {}
@end

@interface _WMInterventionEvent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInterventionEventID*)objectID;





@property (nonatomic, strong) NSNumber* changeType;



@property int16_t changeTypeValue;
- (int16_t)changeTypeValue;
- (void)setChangeTypeValue:(int16_t)value_;

//- (BOOL)validateChangeType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateEvent;



//- (BOOL)validateDateEvent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* path;



//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* valueFrom;



//- (BOOL)validateValueFrom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* valueTo;



//- (BOOL)validateValueTo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMCarePlanGroup *carePlanGroup;

//- (BOOL)validateCarePlanGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMDeviceGroup *deviceGroup;

//- (BOOL)validateDeviceGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionEventType *eventType;

//- (BOOL)validateEventType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMMedicationGroup *medicationGroup;

//- (BOOL)validateMedicationGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipant *participant;

//- (BOOL)validateParticipant:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPsychoSocialGroup *psychoSocialGroup;

//- (BOOL)validatePsychoSocialGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMSkinAssessmentGroup *skinAssessmentGroup;

//- (BOOL)validateSkinAssessmentGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundMeasurementGroup *woundMeasurementGroup;

//- (BOOL)validateWoundMeasurementGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundTreatmentGroup *woundTreatmentGroup;

//- (BOOL)validateWoundTreatmentGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveChangeType;
- (void)setPrimitiveChangeType:(NSNumber*)value;

- (int16_t)primitiveChangeTypeValue;
- (void)setPrimitiveChangeTypeValue:(int16_t)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateEvent;
- (void)setPrimitiveDateEvent:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValueFrom;
- (void)setPrimitiveValueFrom:(NSString*)value;




- (NSString*)primitiveValueTo;
- (void)setPrimitiveValueTo:(NSString*)value;





- (WMCarePlanGroup*)primitiveCarePlanGroup;
- (void)setPrimitiveCarePlanGroup:(WMCarePlanGroup*)value;



- (WMDeviceGroup*)primitiveDeviceGroup;
- (void)setPrimitiveDeviceGroup:(WMDeviceGroup*)value;



- (WMInterventionEventType*)primitiveEventType;
- (void)setPrimitiveEventType:(WMInterventionEventType*)value;



- (WMMedicationGroup*)primitiveMedicationGroup;
- (void)setPrimitiveMedicationGroup:(WMMedicationGroup*)value;



- (WMParticipant*)primitiveParticipant;
- (void)setPrimitiveParticipant:(WMParticipant*)value;



- (WMPsychoSocialGroup*)primitivePsychoSocialGroup;
- (void)setPrimitivePsychoSocialGroup:(WMPsychoSocialGroup*)value;



- (WMSkinAssessmentGroup*)primitiveSkinAssessmentGroup;
- (void)setPrimitiveSkinAssessmentGroup:(WMSkinAssessmentGroup*)value;



- (WMWoundMeasurementGroup*)primitiveWoundMeasurementGroup;
- (void)setPrimitiveWoundMeasurementGroup:(WMWoundMeasurementGroup*)value;



- (WMWoundTreatmentGroup*)primitiveWoundTreatmentGroup;
- (void)setPrimitiveWoundTreatmentGroup:(WMWoundTreatmentGroup*)value;


@end
