#import "_WMPatient.h"
#import "WoundCareProtocols.h"

extern NSString * const kConsultantGroupName;

@class FFUserGroup;

@interface WMPatient : _WMPatient <idSource> {}

+ (NSArray *)toManyRelationshipNames;

// add FFUsers to this group when a consultant acquires the patient
@property (strong, nonatomic) FFUserGroup *consultantGroup;

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext onDevice:(NSString *)deviceId;

@property (readonly, nonatomic) UIImage *thumbnailImage;
+ (UIImage *)missingThumbnailImage;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) NSString *lastNameFirstNameOrAnonymous;
@property (readonly, nonatomic) NSString *identifierEMR;
@property (nonatomic) BOOL facePhotoTaken;
@property (nonatomic) BOOL faceDetectionFailed;
@property (readonly, nonatomic) NSInteger genderIndex;
@property (readonly, nonatomic) WMWound *lastActiveWound;
@property (readonly, nonatomic) BOOL hasMultipleWounds;
@property (readonly, nonatomic) NSArray *sortedWounds;
@property (readonly, nonatomic) NSInteger woundCount;
@property (readonly, nonatomic) NSInteger photosCount;
@property (readonly, nonatomic) NSInteger photoBlobCount;
@property (readonly, nonatomic) BOOL dayOrMoreSinceCreated;
@property (readonly, nonatomic) WMMedicalHistoryGroup *lastActiveMedicalHistoryGroup;
@property (readonly, nonatomic) BOOL hasPatientDetails;

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (WMPatientReferral *)patientReferralForReferree:(WMParticipant *)referee;
- (BOOL)updateNavigationToTeam:(WMTeam *)team;
- (NSString *)updatePatientStatusMessages;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext;

@end
