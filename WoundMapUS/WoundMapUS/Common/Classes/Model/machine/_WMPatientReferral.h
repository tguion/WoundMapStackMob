// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientReferral.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientReferralAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateAccepted;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *updatedAt;
} WMPatientReferralAttributes;

extern const struct WMPatientReferralRelationships {
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *referree;
	__unsafe_unretained NSString *referrer;
} WMPatientReferralRelationships;

extern const struct WMPatientReferralFetchedProperties {
} WMPatientReferralFetchedProperties;

@class WMPatient;
@class WMParticipant;
@class WMParticipant;








@interface WMPatientReferralID : NSManagedObjectID {}
@end

@interface _WMPatientReferral : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPatientReferralID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAccepted;



//- (BOOL)validateDateAccepted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* message;



//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipant *referree;

//- (BOOL)validateReferree:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipant *referrer;

//- (BOOL)validateReferrer:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPatientReferral (CoreDataGeneratedAccessors)

@end

@interface _WMPatientReferral (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateAccepted;
- (void)setPrimitiveDateAccepted:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (WMParticipant*)primitiveReferree;
- (void)setPrimitiveReferree:(WMParticipant*)value;



- (WMParticipant*)primitiveReferrer;
- (void)setPrimitiveReferrer:(WMParticipant*)value;


@end
