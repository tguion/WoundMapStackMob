// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeamInvitation.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTeamInvitationAttributes {
	__unsafe_unretained NSString *acceptedFlag;
	__unsafe_unretained NSString *addedToTeamFlag;
	__unsafe_unretained NSString *confirmedFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *inviteeUserName;
	__unsafe_unretained NSString *passcode;
	__unsafe_unretained NSString *updatedAt;
} WMTeamInvitationAttributes;

extern const struct WMTeamInvitationRelationships {
	__unsafe_unretained NSString *invitee;
	__unsafe_unretained NSString *team;
} WMTeamInvitationRelationships;

extern const struct WMTeamInvitationFetchedProperties {
} WMTeamInvitationFetchedProperties;

@class WMParticipant;
@class WMTeam;











@interface WMTeamInvitationID : NSManagedObjectID {}
@end

@interface _WMTeamInvitation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMTeamInvitationID*)objectID;





@property (nonatomic, strong) NSNumber* acceptedFlag;



@property BOOL acceptedFlagValue;
- (BOOL)acceptedFlagValue;
- (void)setAcceptedFlagValue:(BOOL)value_;

//- (BOOL)validateAcceptedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* addedToTeamFlag;



@property BOOL addedToTeamFlagValue;
- (BOOL)addedToTeamFlagValue;
- (void)setAddedToTeamFlagValue:(BOOL)value_;

//- (BOOL)validateAddedToTeamFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* confirmedFlag;



@property BOOL confirmedFlagValue;
- (BOOL)confirmedFlagValue;
- (void)setConfirmedFlagValue:(BOOL)value_;

//- (BOOL)validateConfirmedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* inviteeUserName;



//- (BOOL)validateInviteeUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* passcode;



@property int16_t passcodeValue;
- (int16_t)passcodeValue;
- (void)setPasscodeValue:(int16_t)value_;

//- (BOOL)validatePasscode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMParticipant *invitee;

//- (BOOL)validateInvitee:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;





@end

@interface _WMTeamInvitation (CoreDataGeneratedAccessors)

@end

@interface _WMTeamInvitation (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAcceptedFlag;
- (void)setPrimitiveAcceptedFlag:(NSNumber*)value;

- (BOOL)primitiveAcceptedFlagValue;
- (void)setPrimitiveAcceptedFlagValue:(BOOL)value_;




- (NSNumber*)primitiveAddedToTeamFlag;
- (void)setPrimitiveAddedToTeamFlag:(NSNumber*)value;

- (BOOL)primitiveAddedToTeamFlagValue;
- (void)setPrimitiveAddedToTeamFlagValue:(BOOL)value_;




- (NSNumber*)primitiveConfirmedFlag;
- (void)setPrimitiveConfirmedFlag:(NSNumber*)value;

- (BOOL)primitiveConfirmedFlagValue;
- (void)setPrimitiveConfirmedFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveInviteeUserName;
- (void)setPrimitiveInviteeUserName:(NSString*)value;




- (NSNumber*)primitivePasscode;
- (void)setPrimitivePasscode:(NSNumber*)value;

- (int16_t)primitivePasscodeValue;
- (void)setPrimitivePasscodeValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMParticipant*)primitiveInvitee;
- (void)setPrimitiveInvitee:(WMParticipant*)value;



- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;


@end
