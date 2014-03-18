#import "_WMPatient.h"
#import "WoundCareProtocols.h"
#import <FFEF/FatFractal.h>

@class FFUserGroup;

@interface WMPatient : _WMPatient <idSource> {}

@property (strong, nonatomic) FFUserGroup *participantGroup;
@property (strong, nonatomic) FFUserGroup *consultantGroup;

- (void)updateParticipantGroupWithParticipants:(NSArray *)participants;
- (void)addParticipant:(id<FFUserProtocol>)participant;
- (void)addConsultant:(id<FFUserProtocol>)consultant;
- (void)removeParticipant:(id<FFUserProtocol>)participant;
- (void)removeConsultant:(id<FFUserProtocol>)consultant;

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext;

+ (UIImage *)missingThumbnailImage;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) NSInteger genderIndex;
@property (readonly, nonatomic) WMWound *lastActiveWound;

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext;

@end
