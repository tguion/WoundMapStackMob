// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMParticipant.h instead.

#import <CoreData/CoreData.h>


extern const struct WMParticipantAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateLastSignin;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *guid;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *permissions;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userName;
} WMParticipantAttributes;

extern const struct WMParticipantRelationships {
	__unsafe_unretained NSString *acquiredConsults;
	__unsafe_unretained NSString *interventionEvents;
	__unsafe_unretained NSString *participantType;
	__unsafe_unretained NSString *person;
	__unsafe_unretained NSString *team;
} WMParticipantRelationships;

extern const struct WMParticipantFetchedProperties {
} WMParticipantFetchedProperties;

@class WMPatientConsultant;
@class WMInterventionEvent;
@class WMParticipantType;
@class WMPerson;
@class WMTeam;












@interface WMParticipantID : NSManagedObjectID {}
@end

@interface _WMParticipant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMParticipantID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateLastSignin;



//- (BOOL)validateDateLastSignin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* guid;



//- (BOOL)validateGuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* permissions;



@property int32_t permissionsValue;
- (int32_t)permissionsValue;
- (void)setPermissionsValue:(int32_t)value_;

//- (BOOL)validatePermissions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *acquiredConsults;

- (NSMutableSet*)acquiredConsultsSet;




@property (nonatomic, strong) NSSet *interventionEvents;

- (NSMutableSet*)interventionEventsSet;




@property (nonatomic, strong) WMParticipantType *participantType;

//- (BOOL)validateParticipantType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;





@end

@interface _WMParticipant (CoreDataGeneratedAccessors)

- (void)addAcquiredConsults:(NSSet*)value_;
- (void)removeAcquiredConsults:(NSSet*)value_;
- (void)addAcquiredConsultsObject:(WMPatientConsultant*)value_;
- (void)removeAcquiredConsultsObject:(WMPatientConsultant*)value_;

- (void)addInterventionEvents:(NSSet*)value_;
- (void)removeInterventionEvents:(NSSet*)value_;
- (void)addInterventionEventsObject:(WMInterventionEvent*)value_;
- (void)removeInterventionEventsObject:(WMInterventionEvent*)value_;

@end

@interface _WMParticipant (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateLastSignin;
- (void)setPrimitiveDateLastSignin:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveGuid;
- (void)setPrimitiveGuid:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePermissions;
- (void)setPrimitivePermissions:(NSNumber*)value;

- (int32_t)primitivePermissionsValue;
- (void)setPrimitivePermissionsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;





- (NSMutableSet*)primitiveAcquiredConsults;
- (void)setPrimitiveAcquiredConsults:(NSMutableSet*)value;



- (NSMutableSet*)primitiveInterventionEvents;
- (void)setPrimitiveInterventionEvents:(NSMutableSet*)value;



- (WMParticipantType*)primitiveParticipantType;
- (void)setPrimitiveParticipantType:(WMParticipantType*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;



- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;


@end
