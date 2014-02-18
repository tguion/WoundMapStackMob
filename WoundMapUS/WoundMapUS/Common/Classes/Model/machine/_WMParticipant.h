// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMParticipant.h instead.

#import <CoreData/CoreData.h>


extern const struct WMParticipantAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateLastSignin;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *permissions;
	__unsafe_unretained NSString *wmparticipant_id;
} WMParticipantAttributes;

extern const struct WMParticipantRelationships {
	__unsafe_unretained NSString *acquiredConsults;
	__unsafe_unretained NSString *participantType;
	__unsafe_unretained NSString *person;
} WMParticipantRelationships;

extern const struct WMParticipantFetchedProperties {
} WMParticipantFetchedProperties;

@class WMPatientConsultant;
@class WMParticipantType;
@class WMPerson;











@interface WMParticipantID : NSManagedObjectID {}
@end

@interface _WMParticipant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMParticipantID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateLastSignin;



//- (BOOL)validateDateLastSignin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* permissions;



@property int32_t permissionsValue;
- (int32_t)permissionsValue;
- (void)setPermissionsValue:(int32_t)value_;

//- (BOOL)validatePermissions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmparticipant_id;



//- (BOOL)validateWmparticipant_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *acquiredConsults;

- (NSMutableSet*)acquiredConsultsSet;




@property (nonatomic, strong) WMParticipantType *participantType;

//- (BOOL)validateParticipantType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;





@end

@interface _WMParticipant (CoreDataGeneratedAccessors)

- (void)addAcquiredConsults:(NSSet*)value_;
- (void)removeAcquiredConsults:(NSSet*)value_;
- (void)addAcquiredConsultsObject:(WMPatientConsultant*)value_;
- (void)removeAcquiredConsultsObject:(WMPatientConsultant*)value_;

@end

@interface _WMParticipant (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateLastSignin;
- (void)setPrimitiveDateLastSignin:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePermissions;
- (void)setPrimitivePermissions:(NSNumber*)value;

- (int32_t)primitivePermissionsValue;
- (void)setPrimitivePermissionsValue:(int32_t)value_;




- (NSString*)primitiveWmparticipant_id;
- (void)setPrimitiveWmparticipant_id:(NSString*)value;





- (NSMutableSet*)primitiveAcquiredConsults;
- (void)setPrimitiveAcquiredConsults:(NSMutableSet*)value;



- (WMParticipantType*)primitiveParticipantType;
- (void)setPrimitiveParticipantType:(WMParticipantType*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;


@end
