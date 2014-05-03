// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMParticipant.h instead.

#import <CoreData/CoreData.h>


extern const struct WMParticipantAttributes {
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateAddedToTeam;
	__unsafe_unretained NSString *dateLastSignin;
	__unsafe_unretained NSString *dateTeamSubscriptionExpires;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *guid;
	__unsafe_unretained NSString *lastTokenCreditPurchaseDate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *permissions;
	__unsafe_unretained NSString *reportTokenCount;
	__unsafe_unretained NSString *thumbnail;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userName;
} WMParticipantAttributes;

extern const struct WMParticipantRelationships {
	__unsafe_unretained NSString *acquiredConsults;
	__unsafe_unretained NSString *interventionEvents;
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *participantType;
	__unsafe_unretained NSString *patients;
	__unsafe_unretained NSString *person;
	__unsafe_unretained NSString *sourceReferrals;
	__unsafe_unretained NSString *targetReferrals;
	__unsafe_unretained NSString *team;
	__unsafe_unretained NSString *teamInvitation;
} WMParticipantRelationships;

extern const struct WMParticipantFetchedProperties {
} WMParticipantFetchedProperties;

@class WMPatientConsultant;
@class WMInterventionEvent;
@class WMOrganization;
@class WMParticipantType;
@class WMPatient;
@class WMPerson;
@class WMPatientReferral;
@class WMPatientReferral;
@class WMTeam;
@class WMTeamInvitation;














@class NSObject;



@interface WMParticipantID : NSManagedObjectID {}
@end

@interface _WMParticipant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMParticipantID*)objectID;





@property (nonatomic, strong) NSString* bio;



//- (BOOL)validateBio:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAddedToTeam;



//- (BOOL)validateDateAddedToTeam:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateLastSignin;



//- (BOOL)validateDateLastSignin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateTeamSubscriptionExpires;



//- (BOOL)validateDateTeamSubscriptionExpires:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSDate* lastTokenCreditPurchaseDate;



//- (BOOL)validateLastTokenCreditPurchaseDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* permissions;



@property int32_t permissionsValue;
- (int32_t)permissionsValue;
- (void)setPermissionsValue:(int32_t)value_;

//- (BOOL)validatePermissions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* reportTokenCount;



@property int16_t reportTokenCountValue;
- (int16_t)reportTokenCountValue;
- (void)setReportTokenCountValue:(int16_t)value_;

//- (BOOL)validateReportTokenCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id thumbnail;



//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *acquiredConsults;

- (NSMutableSet*)acquiredConsultsSet;




@property (nonatomic, strong) NSSet *interventionEvents;

- (NSMutableSet*)interventionEventsSet;




@property (nonatomic, strong) WMOrganization *organization;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipantType *participantType;

//- (BOOL)validateParticipantType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *patients;

- (NSMutableSet*)patientsSet;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *sourceReferrals;

- (NSMutableSet*)sourceReferralsSet;




@property (nonatomic, strong) NSSet *targetReferrals;

- (NSMutableSet*)targetReferralsSet;




@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTeamInvitation *teamInvitation;

//- (BOOL)validateTeamInvitation:(id*)value_ error:(NSError**)error_;





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

- (void)addPatients:(NSSet*)value_;
- (void)removePatients:(NSSet*)value_;
- (void)addPatientsObject:(WMPatient*)value_;
- (void)removePatientsObject:(WMPatient*)value_;

- (void)addSourceReferrals:(NSSet*)value_;
- (void)removeSourceReferrals:(NSSet*)value_;
- (void)addSourceReferralsObject:(WMPatientReferral*)value_;
- (void)removeSourceReferralsObject:(WMPatientReferral*)value_;

- (void)addTargetReferrals:(NSSet*)value_;
- (void)removeTargetReferrals:(NSSet*)value_;
- (void)addTargetReferralsObject:(WMPatientReferral*)value_;
- (void)removeTargetReferralsObject:(WMPatientReferral*)value_;

@end

@interface _WMParticipant (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateAddedToTeam;
- (void)setPrimitiveDateAddedToTeam:(NSDate*)value;




- (NSDate*)primitiveDateLastSignin;
- (void)setPrimitiveDateLastSignin:(NSDate*)value;




- (NSDate*)primitiveDateTeamSubscriptionExpires;
- (void)setPrimitiveDateTeamSubscriptionExpires:(NSDate*)value;




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




- (NSDate*)primitiveLastTokenCreditPurchaseDate;
- (void)setPrimitiveLastTokenCreditPurchaseDate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePermissions;
- (void)setPrimitivePermissions:(NSNumber*)value;

- (int32_t)primitivePermissionsValue;
- (void)setPrimitivePermissionsValue:(int32_t)value_;




- (NSNumber*)primitiveReportTokenCount;
- (void)setPrimitiveReportTokenCount:(NSNumber*)value;

- (int16_t)primitiveReportTokenCountValue;
- (void)setPrimitiveReportTokenCountValue:(int16_t)value_;




- (id)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(id)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;





- (NSMutableSet*)primitiveAcquiredConsults;
- (void)setPrimitiveAcquiredConsults:(NSMutableSet*)value;



- (NSMutableSet*)primitiveInterventionEvents;
- (void)setPrimitiveInterventionEvents:(NSMutableSet*)value;



- (WMOrganization*)primitiveOrganization;
- (void)setPrimitiveOrganization:(WMOrganization*)value;



- (WMParticipantType*)primitiveParticipantType;
- (void)setPrimitiveParticipantType:(WMParticipantType*)value;



- (NSMutableSet*)primitivePatients;
- (void)setPrimitivePatients:(NSMutableSet*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;



- (NSMutableSet*)primitiveSourceReferrals;
- (void)setPrimitiveSourceReferrals:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTargetReferrals;
- (void)setPrimitiveTargetReferrals:(NSMutableSet*)value;



- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;



- (WMTeamInvitation*)primitiveTeamInvitation;
- (void)setPrimitiveTeamInvitation:(WMTeamInvitation*)value;


@end
