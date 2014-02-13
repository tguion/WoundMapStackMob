// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatient.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientAttributes {
	__unsafe_unretained NSString *archivedFlag;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *patientStatusMessages;
	__unsafe_unretained NSString *thumbnail;
	__unsafe_unretained NSString *wmpatient_id;
} WMPatientAttributes;

extern const struct WMPatientRelationships {
	__unsafe_unretained NSString *ids;
	__unsafe_unretained NSString *person;
} WMPatientRelationships;

extern const struct WMPatientFetchedProperties {
} WMPatientFetchedProperties;

@class WMId;
@class WMPerson;











@interface WMPatientID : NSManagedObjectID {}
@end

@interface _WMPatient : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPatientID*)objectID;





@property (nonatomic, strong) NSNumber* archivedFlag;



@property BOOL archivedFlagValue;
- (BOOL)archivedFlagValue;
- (void)setArchivedFlagValue:(BOOL)value_;

//- (BOOL)validateArchivedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* gender;



//- (BOOL)validateGender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* patientStatusMessages;



//- (BOOL)validatePatientStatusMessages:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnail;



//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmpatient_id;



//- (BOOL)validateWmpatient_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *ids;

- (NSMutableSet*)idsSet;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPatient (CoreDataGeneratedAccessors)

- (void)addIds:(NSSet*)value_;
- (void)removeIds:(NSSet*)value_;
- (void)addIdsObject:(WMId*)value_;
- (void)removeIdsObject:(WMId*)value_;

@end

@interface _WMPatient (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveArchivedFlag;
- (void)setPrimitiveArchivedFlag:(NSNumber*)value;

- (BOOL)primitiveArchivedFlagValue;
- (void)setPrimitiveArchivedFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveGender;
- (void)setPrimitiveGender:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitivePatientStatusMessages;
- (void)setPrimitivePatientStatusMessages:(NSString*)value;




- (NSString*)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(NSString*)value;




- (NSString*)primitiveWmpatient_id;
- (void)setPrimitiveWmpatient_id:(NSString*)value;





- (NSMutableSet*)primitiveIds;
- (void)setPrimitiveIds:(NSMutableSet*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;


@end
