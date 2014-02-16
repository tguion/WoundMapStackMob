// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientConsultant.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientConsultantAttributes {
	__unsafe_unretained NSString *acquiredFlag;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateAquired;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *wmpatientconsultant_id;
} WMPatientConsultantAttributes;

extern const struct WMPatientConsultantRelationships {
	__unsafe_unretained NSString *consultant;
	__unsafe_unretained NSString *participant;
	__unsafe_unretained NSString *patient;
} WMPatientConsultantRelationships;

extern const struct WMPatientConsultantFetchedProperties {
} WMPatientConsultantFetchedProperties;

@class User;
@class WMParticipant;
@class WMPatient;








@interface WMPatientConsultantID : NSManagedObjectID {}
@end

@interface _WMPatientConsultant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPatientConsultantID*)objectID;





@property (nonatomic, strong) NSNumber* acquiredFlag;



@property BOOL acquiredFlagValue;
- (BOOL)acquiredFlagValue;
- (void)setAcquiredFlagValue:(BOOL)value_;

//- (BOOL)validateAcquiredFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAquired;



//- (BOOL)validateDateAquired:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmpatientconsultant_id;



//- (BOOL)validateWmpatientconsultant_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *consultant;

//- (BOOL)validateConsultant:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipant *participant;

//- (BOOL)validateParticipant:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPatientConsultant (CoreDataGeneratedAccessors)

@end

@interface _WMPatientConsultant (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAcquiredFlag;
- (void)setPrimitiveAcquiredFlag:(NSNumber*)value;

- (BOOL)primitiveAcquiredFlagValue;
- (void)setPrimitiveAcquiredFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateAquired;
- (void)setPrimitiveDateAquired:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveWmpatientconsultant_id;
- (void)setPrimitiveWmpatientconsultant_id:(NSString*)value;





- (User*)primitiveConsultant;
- (void)setPrimitiveConsultant:(User*)value;



- (WMParticipant*)primitiveParticipant;
- (void)setPrimitiveParticipant:(WMParticipant*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;


@end
