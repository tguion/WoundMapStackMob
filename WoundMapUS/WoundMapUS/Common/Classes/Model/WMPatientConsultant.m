#import "WMPatientConsultant.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "User.h"
#import "WMUtilities.h"
#import "StackMob.h"

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
    [patientConsultant setValue:[patientConsultant assignObjectId] forKey:[patientConsultant primaryKeyField]];
	return patientConsultant;
}

+ (WMPatientConsultant *)patientConsultantForPatient:(WMPatient *)patient
                                          consultant:(User *)consultant
                                         participant:(WMParticipant *)participant
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPatientConsultant" inManagedObjectContext:managedObjectContext]];
    NSMutableArray *predicates = [NSMutableArray array];
    if (nil != patient) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    }
    if (nil != consultant) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"consultant == %@", consultant]];
    }
    if (nil != participant) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"participant == %@", participant]];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMPatientConsultant *patientConsultant = [array lastObject];
    if (create && nil == patientConsultant) {
        patientConsultant = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        patientConsultant.consultant = consultant;
        patientConsultant.participant = participant;
        patientConsultant.patient = patient;
    }
    return patientConsultant;
}

- (NSString *)consultingDescription
{
    NSString *string = nil;
    if (self.acquiredFlagValue) {
        string = [NSString stringWithFormat:@"Referred by %@ acquired by %@", self.patient.sm_owner, self.participant.lastNameFirstName];
    } else {
        string = [NSString stringWithFormat:@"Referred by %@", self.patient.sm_owner];
    }
    return string;
}

@end
