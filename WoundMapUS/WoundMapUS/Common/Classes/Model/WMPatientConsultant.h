#import "_WMPatientConsultant.h"
#import "WMFFManagedObject.h"

@interface WMPatientConsultant : _WMPatientConsultant <WMFFManagedObject> {}

+ (WMPatientConsultant *)patientConsultantForPatient:(WMPatient *)patient
                                         consultant:(WMParticipant *)consultant
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) NSString *consultingDescription;

@end
