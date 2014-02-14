#import "_WMPatient.h"

@interface WMPatient : _WMPatient {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) NSInteger genderIndex;

+ (WMPatient *)patientForPatientId:(NSString *)patientId
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store;

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext
                         persistentStore:(NSPersistentStore *)store;

@end
