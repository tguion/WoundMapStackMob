// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientConsultant.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientConsultantAttributes {
	__unsafe_unretained NSString *acquiredFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateAquired;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
} WMPatientConsultantAttributes;

extern const struct WMPatientConsultantRelationships {
	__unsafe_unretained NSString *consultant;
	__unsafe_unretained NSString *patient;
} WMPatientConsultantRelationships;

extern const struct WMPatientConsultantFetchedProperties {
} WMPatientConsultantFetchedProperties;

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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAquired;



//- (BOOL)validateDateAquired:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMParticipant *consultant;

//- (BOOL)validateConsultant:(id*)value_ error:(NSError**)error_;




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




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateAquired;
- (void)setPrimitiveDateAquired:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMParticipant*)primitiveConsultant;
- (void)setPrimitiveConsultant:(WMParticipant*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;


@end
