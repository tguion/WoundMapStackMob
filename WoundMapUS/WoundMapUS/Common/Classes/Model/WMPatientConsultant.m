#import "WMPatientConsultant.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMPatientConsultant ()

// Private interface goes here.

@end


@implementation WMPatientConsultant

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMPatientConsultant *patientConsultant = [[WMPatientConsultant alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPatientConsultant" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:patientConsultant toPersistentStore:store];
	}
	return patientConsultant;
}

+ (WMPatientConsultant *)patientConsultantForPatient:(WMPatient *)patient
                                          consultant:(WMParticipant *)consultant
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSMutableArray *predicates = [NSMutableArray array];
    if (nil != patient) {
        NSParameterAssert([patient managedObjectContext] == managedObjectContext);
        [predicates addObject:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    }
    if (nil != consultant) {
        NSParameterAssert([consultant managedObjectContext] == managedObjectContext);
        [predicates addObject:[NSPredicate predicateWithFormat:@"consultant == %@", consultant]];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    WMPatientConsultant *patientConsultant = [WMPatientConsultant MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == patientConsultant) {
        patientConsultant = [WMPatientConsultant MR_createInContext:managedObjectContext];
        patientConsultant.consultant = consultant;
        patientConsultant.patient = patient;
    }
    return patientConsultant;
}

- (NSString *)consultingDescription
{
    NSString *string = nil;
    if (self.acquiredFlagValue) {
        string = [NSString stringWithFormat:@"Referred by %@ acquired by %@", self.patient.participant.name, self.consultant.name];
    } else {
        string = [NSString stringWithFormat:@"Referred by %@", self.patient.participant.name];
    }
    return string;
}

@end
