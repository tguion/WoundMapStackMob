// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatient.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientAttributes {
	__unsafe_unretained NSString *acquiredByConsultant;
	__unsafe_unretained NSString *archivedFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *createdOnDeviceId;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *lastUpdatedOnDeviceId;
	__unsafe_unretained NSString *patientStatusMessages;
	__unsafe_unretained NSString *relevantMedications;
	__unsafe_unretained NSString *ssn;
	__unsafe_unretained NSString *surgicalHistory;
	__unsafe_unretained NSString *thumbnail;
	__unsafe_unretained NSString *updatedAt;
} WMPatientAttributes;

extern const struct WMPatientRelationships {
	__unsafe_unretained NSString *bradenScales;
	__unsafe_unretained NSString *carePlanGroups;
	__unsafe_unretained NSString *deviceGroups;
	__unsafe_unretained NSString *ids;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *medicalHistoryGroups;
	__unsafe_unretained NSString *medicationGroups;
	__unsafe_unretained NSString *nutritionGroups;
	__unsafe_unretained NSString *participant;
	__unsafe_unretained NSString *patientConsultants;
	__unsafe_unretained NSString *person;
	__unsafe_unretained NSString *psychosocialGroups;
	__unsafe_unretained NSString *referrals;
	__unsafe_unretained NSString *skinAssessmentGroups;
	__unsafe_unretained NSString *stage;
	__unsafe_unretained NSString *team;
	__unsafe_unretained NSString *wounds;
} WMPatientRelationships;

extern const struct WMPatientFetchedProperties {
} WMPatientFetchedProperties;

@class WMBradenScale;
@class WMCarePlanGroup;
@class WMDeviceGroup;
@class WMId;
@class WMPatientLocation;
@class WMMedicalHistoryGroup;
@class WMMedicationGroup;
@class WMNutritionGroup;
@class WMParticipant;
@class WMPatientConsultant;
@class WMPerson;
@class WMPsychoSocialGroup;
@class WMPatientReferral;
@class WMSkinAssessmentGroup;
@class WMNavigationStage;
@class WMTeam;
@class WMWound;














@class NSObject;


@interface WMPatientID : NSManagedObjectID {}
@end

@interface _WMPatient : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPatientID*)objectID;





@property (nonatomic, strong) NSNumber* acquiredByConsultant;



@property BOOL acquiredByConsultantValue;
- (BOOL)acquiredByConsultantValue;
- (void)setAcquiredByConsultantValue:(BOOL)value_;

//- (BOOL)validateAcquiredByConsultant:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* archivedFlag;



@property BOOL archivedFlagValue;
- (BOOL)archivedFlagValue;
- (void)setArchivedFlagValue:(BOOL)value_;

//- (BOOL)validateArchivedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* createdOnDeviceId;



//- (BOOL)validateCreatedOnDeviceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* gender;



//- (BOOL)validateGender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastUpdatedOnDeviceId;



//- (BOOL)validateLastUpdatedOnDeviceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* patientStatusMessages;



//- (BOOL)validatePatientStatusMessages:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* relevantMedications;



//- (BOOL)validateRelevantMedications:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ssn;



//- (BOOL)validateSsn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* surgicalHistory;



//- (BOOL)validateSurgicalHistory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id thumbnail;



//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *bradenScales;

- (NSMutableSet*)bradenScalesSet;




@property (nonatomic, strong) NSSet *carePlanGroups;

- (NSMutableSet*)carePlanGroupsSet;




@property (nonatomic, strong) NSSet *deviceGroups;

- (NSMutableSet*)deviceGroupsSet;




@property (nonatomic, strong) NSSet *ids;

- (NSMutableSet*)idsSet;




@property (nonatomic, strong) WMPatientLocation *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *medicalHistoryGroups;

- (NSMutableSet*)medicalHistoryGroupsSet;




@property (nonatomic, strong) NSSet *medicationGroups;

- (NSMutableSet*)medicationGroupsSet;




@property (nonatomic, strong) NSSet *nutritionGroups;

- (NSMutableSet*)nutritionGroupsSet;




@property (nonatomic, strong) WMParticipant *participant;

//- (BOOL)validateParticipant:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *patientConsultants;

- (NSMutableSet*)patientConsultantsSet;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *psychosocialGroups;

- (NSMutableSet*)psychosocialGroupsSet;




@property (nonatomic, strong) NSSet *referrals;

- (NSMutableSet*)referralsSet;




@property (nonatomic, strong) NSSet *skinAssessmentGroups;

- (NSMutableSet*)skinAssessmentGroupsSet;




@property (nonatomic, strong) WMNavigationStage *stage;

//- (BOOL)validateStage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *wounds;

- (NSMutableSet*)woundsSet;





@end

@interface _WMPatient (CoreDataGeneratedAccessors)

- (void)addBradenScales:(NSSet*)value_;
- (void)removeBradenScales:(NSSet*)value_;
- (void)addBradenScalesObject:(WMBradenScale*)value_;
- (void)removeBradenScalesObject:(WMBradenScale*)value_;

- (void)addCarePlanGroups:(NSSet*)value_;
- (void)removeCarePlanGroups:(NSSet*)value_;
- (void)addCarePlanGroupsObject:(WMCarePlanGroup*)value_;
- (void)removeCarePlanGroupsObject:(WMCarePlanGroup*)value_;

- (void)addDeviceGroups:(NSSet*)value_;
- (void)removeDeviceGroups:(NSSet*)value_;
- (void)addDeviceGroupsObject:(WMDeviceGroup*)value_;
- (void)removeDeviceGroupsObject:(WMDeviceGroup*)value_;

- (void)addIds:(NSSet*)value_;
- (void)removeIds:(NSSet*)value_;
- (void)addIdsObject:(WMId*)value_;
- (void)removeIdsObject:(WMId*)value_;

- (void)addMedicalHistoryGroups:(NSSet*)value_;
- (void)removeMedicalHistoryGroups:(NSSet*)value_;
- (void)addMedicalHistoryGroupsObject:(WMMedicalHistoryGroup*)value_;
- (void)removeMedicalHistoryGroupsObject:(WMMedicalHistoryGroup*)value_;

- (void)addMedicationGroups:(NSSet*)value_;
- (void)removeMedicationGroups:(NSSet*)value_;
- (void)addMedicationGroupsObject:(WMMedicationGroup*)value_;
- (void)removeMedicationGroupsObject:(WMMedicationGroup*)value_;

- (void)addNutritionGroups:(NSSet*)value_;
- (void)removeNutritionGroups:(NSSet*)value_;
- (void)addNutritionGroupsObject:(WMNutritionGroup*)value_;
- (void)removeNutritionGroupsObject:(WMNutritionGroup*)value_;

- (void)addPatientConsultants:(NSSet*)value_;
- (void)removePatientConsultants:(NSSet*)value_;
- (void)addPatientConsultantsObject:(WMPatientConsultant*)value_;
- (void)removePatientConsultantsObject:(WMPatientConsultant*)value_;

- (void)addPsychosocialGroups:(NSSet*)value_;
- (void)removePsychosocialGroups:(NSSet*)value_;
- (void)addPsychosocialGroupsObject:(WMPsychoSocialGroup*)value_;
- (void)removePsychosocialGroupsObject:(WMPsychoSocialGroup*)value_;

- (void)addReferrals:(NSSet*)value_;
- (void)removeReferrals:(NSSet*)value_;
- (void)addReferralsObject:(WMPatientReferral*)value_;
- (void)removeReferralsObject:(WMPatientReferral*)value_;

- (void)addSkinAssessmentGroups:(NSSet*)value_;
- (void)removeSkinAssessmentGroups:(NSSet*)value_;
- (void)addSkinAssessmentGroupsObject:(WMSkinAssessmentGroup*)value_;
- (void)removeSkinAssessmentGroupsObject:(WMSkinAssessmentGroup*)value_;

- (void)addWounds:(NSSet*)value_;
- (void)removeWounds:(NSSet*)value_;
- (void)addWoundsObject:(WMWound*)value_;
- (void)removeWoundsObject:(WMWound*)value_;

@end

@interface _WMPatient (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAcquiredByConsultant;
- (void)setPrimitiveAcquiredByConsultant:(NSNumber*)value;

- (BOOL)primitiveAcquiredByConsultantValue;
- (void)setPrimitiveAcquiredByConsultantValue:(BOOL)value_;




- (NSNumber*)primitiveArchivedFlag;
- (void)setPrimitiveArchivedFlag:(NSNumber*)value;

- (BOOL)primitiveArchivedFlagValue;
- (void)setPrimitiveArchivedFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveCreatedOnDeviceId;
- (void)setPrimitiveCreatedOnDeviceId:(NSString*)value;




- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveGender;
- (void)setPrimitiveGender:(NSString*)value;




- (NSString*)primitiveLastUpdatedOnDeviceId;
- (void)setPrimitiveLastUpdatedOnDeviceId:(NSString*)value;




- (NSString*)primitivePatientStatusMessages;
- (void)setPrimitivePatientStatusMessages:(NSString*)value;




- (NSString*)primitiveRelevantMedications;
- (void)setPrimitiveRelevantMedications:(NSString*)value;




- (NSString*)primitiveSsn;
- (void)setPrimitiveSsn:(NSString*)value;




- (NSString*)primitiveSurgicalHistory;
- (void)setPrimitiveSurgicalHistory:(NSString*)value;




- (id)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(id)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveBradenScales;
- (void)setPrimitiveBradenScales:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCarePlanGroups;
- (void)setPrimitiveCarePlanGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDeviceGroups;
- (void)setPrimitiveDeviceGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIds;
- (void)setPrimitiveIds:(NSMutableSet*)value;



- (WMPatientLocation*)primitiveLocation;
- (void)setPrimitiveLocation:(WMPatientLocation*)value;



- (NSMutableSet*)primitiveMedicalHistoryGroups;
- (void)setPrimitiveMedicalHistoryGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMedicationGroups;
- (void)setPrimitiveMedicationGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveNutritionGroups;
- (void)setPrimitiveNutritionGroups:(NSMutableSet*)value;



- (WMParticipant*)primitiveParticipant;
- (void)setPrimitiveParticipant:(WMParticipant*)value;



- (NSMutableSet*)primitivePatientConsultants;
- (void)setPrimitivePatientConsultants:(NSMutableSet*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;



- (NSMutableSet*)primitivePsychosocialGroups;
- (void)setPrimitivePsychosocialGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReferrals;
- (void)setPrimitiveReferrals:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSkinAssessmentGroups;
- (void)setPrimitiveSkinAssessmentGroups:(NSMutableSet*)value;



- (WMNavigationStage*)primitiveStage;
- (void)setPrimitiveStage:(WMNavigationStage*)value;



- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;



- (NSMutableSet*)primitiveWounds;
- (void)setPrimitiveWounds:(NSMutableSet*)value;


@end
