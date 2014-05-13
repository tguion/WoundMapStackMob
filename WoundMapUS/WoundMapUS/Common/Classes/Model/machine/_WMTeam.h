// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeam.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTeamAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *iapTeamMemberSuccessCount;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updatedAt;
} WMTeamAttributes;

extern const struct WMTeamRelationships {
	__unsafe_unretained NSString *consultingGroup;
	__unsafe_unretained NSString *invitations;
	__unsafe_unretained NSString *navigationTracks;
	__unsafe_unretained NSString *participants;
	__unsafe_unretained NSString *patients;
	__unsafe_unretained NSString *teamPolicy;
} WMTeamRelationships;

extern const struct WMTeamFetchedProperties {
} WMTeamFetchedProperties;

@class WMConsultingGroup;
@class WMTeamInvitation;
@class WMNavigationTrack;
@class WMParticipant;
@class WMPatient;
@class WMTeamPolicy;








@interface WMTeamID : NSManagedObjectID {}
@end

@interface _WMTeam : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMTeamID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* iapTeamMemberSuccessCount;



@property int16_t iapTeamMemberSuccessCountValue;
- (int16_t)iapTeamMemberSuccessCountValue;
- (void)setIapTeamMemberSuccessCountValue:(int16_t)value_;

//- (BOOL)validateIapTeamMemberSuccessCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMConsultingGroup *consultingGroup;

//- (BOOL)validateConsultingGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *invitations;

- (NSMutableSet*)invitationsSet;




@property (nonatomic, strong) NSSet *navigationTracks;

- (NSMutableSet*)navigationTracksSet;




@property (nonatomic, strong) NSSet *participants;

- (NSMutableSet*)participantsSet;




@property (nonatomic, strong) NSSet *patients;

- (NSMutableSet*)patientsSet;




@property (nonatomic, strong) WMTeamPolicy *teamPolicy;

//- (BOOL)validateTeamPolicy:(id*)value_ error:(NSError**)error_;





@end

@interface _WMTeam (CoreDataGeneratedAccessors)

- (void)addInvitations:(NSSet*)value_;
- (void)removeInvitations:(NSSet*)value_;
- (void)addInvitationsObject:(WMTeamInvitation*)value_;
- (void)removeInvitationsObject:(WMTeamInvitation*)value_;

- (void)addNavigationTracks:(NSSet*)value_;
- (void)removeNavigationTracks:(NSSet*)value_;
- (void)addNavigationTracksObject:(WMNavigationTrack*)value_;
- (void)removeNavigationTracksObject:(WMNavigationTrack*)value_;

- (void)addParticipants:(NSSet*)value_;
- (void)removeParticipants:(NSSet*)value_;
- (void)addParticipantsObject:(WMParticipant*)value_;
- (void)removeParticipantsObject:(WMParticipant*)value_;

- (void)addPatients:(NSSet*)value_;
- (void)removePatients:(NSSet*)value_;
- (void)addPatientsObject:(WMPatient*)value_;
- (void)removePatientsObject:(WMPatient*)value_;

@end

@interface _WMTeam (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveIapTeamMemberSuccessCount;
- (void)setPrimitiveIapTeamMemberSuccessCount:(NSNumber*)value;

- (int16_t)primitiveIapTeamMemberSuccessCountValue;
- (void)setPrimitiveIapTeamMemberSuccessCountValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMConsultingGroup*)primitiveConsultingGroup;
- (void)setPrimitiveConsultingGroup:(WMConsultingGroup*)value;



- (NSMutableSet*)primitiveInvitations;
- (void)setPrimitiveInvitations:(NSMutableSet*)value;



- (NSMutableSet*)primitiveNavigationTracks;
- (void)setPrimitiveNavigationTracks:(NSMutableSet*)value;



- (NSMutableSet*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSMutableSet*)value;



- (NSMutableSet*)primitivePatients;
- (void)setPrimitivePatients:(NSMutableSet*)value;



- (WMTeamPolicy*)primitiveTeamPolicy;
- (void)setPrimitiveTeamPolicy:(WMTeamPolicy*)value;


@end
