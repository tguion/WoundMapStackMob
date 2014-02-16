#import "_WMPatientConsultant.h"

@interface WMPatientConsultant : _WMPatientConsultant {}

+ (WMPatientConsultant *)patientConsultantForPatient:(WMPatient *)patient
                                          consultant:(User *)consultant
                                         participant:(WMParticipant *)participant
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store;

@end
