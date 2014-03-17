#import "_WMPatientConsultant.h"

@interface WMPatientConsultant : _WMPatientConsultant {}

+ (WMPatientConsultant *)patientConsultantForPatient:(WMPatient *)patient
                                         consultant:(WMParticipant *)consultant
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) NSString *consultingDescription;

@end
