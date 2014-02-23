#import "_WMPatient.h"
#import "WoundCareProtocols.h"

@interface WMPatient : _WMPatient <idSource> {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) NSInteger genderIndex;
@property (readonly, nonatomic) UIImage *missingThumbnailImage;
@property (readonly, nonatomic) WMWound *lastActiveWound;
@property (readonly, nonatomic) WMPatientConsultant *patientConsultantSubmittedSource;
@property (readonly, nonatomic) WMPatientConsultant *patientConsultantSubmittedTarget;

+ (WMPatient *)patientForPatientId:(NSString *)patientId
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext
                         persistentStore:(NSPersistentStore *)store;

@end
