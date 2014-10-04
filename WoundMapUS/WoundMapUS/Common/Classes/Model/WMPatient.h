#import "_WMPatient.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class FFUserGroup;

@interface WMPatient : _WMPatient <idSource, WMFFManagedObject> {}

+ (FFUserGroup *)consultantGroup:(NSString *)guid;

+ (NSArray *)toManyRelationshipNames;
+ (NSSet *)relationshipNamesAffectingCompassStatus;

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
@property (nonatomic) BOOL isDeleting;

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (WMPatientReferral *)patientReferral;
- (WMPatientReferral *)patientReferralForReferree:(WMParticipant *)referee;
- (BOOL)updateNavigationToTeam:(WMTeam *)team patient2StageMap:(NSDictionary *)patient2StageMap;
- (NSString *)updatePatientStatusMessages;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext;

@end
