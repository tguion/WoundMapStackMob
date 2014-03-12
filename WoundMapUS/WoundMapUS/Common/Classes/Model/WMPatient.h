#import "_WMPatient.h"
#import "WoundCareProtocols.h"
#import <FFEF/FatFractal.h>

@class FFUserGroup;

@interface WMPatient : _WMPatient <idSource> {}

@property (strong, nonatomic) FFUserGroup *participantGroup;
@property (strong, nonatomic) FFUserGroup *consultantGroup;

- (void)updateParticipantGroupWithParticipants:(NSArray *)participants;
- (void)updateParticipantGroupWithConsultants:(NSArray *)consultants;
- (void)addParticipant:(id<FFUserProtocol>)participant;
- (void)addConsultant:(id<FFUserProtocol>)consultant;
- (void)removeParticipant:(id<FFUserProtocol>)participant;
- (void)removeConsultant:(id<FFUserProtocol>)consultant;

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext;

+ (UIImage *)missingThumbnailImage;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) NSInteger genderIndex;
@property (readonly, nonatomic) WMWound *lastActiveWound;
@property (readonly, nonatomic) WMPatientConsultant *patientConsultantSubmittedSource;
@property (readonly, nonatomic) WMPatientConsultant *patientConsultantSubmittedTarget;

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext;

@end
