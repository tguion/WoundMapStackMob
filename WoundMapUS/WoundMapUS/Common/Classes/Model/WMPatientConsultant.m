#import "WMPatientConsultant.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMPatientConsultant ()

// Private interface goes here.

@end


@implementation WMPatientConsultant

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
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

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.patient;
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"acquiredFlagValue",
                                                            @"flagsValue",
                                                            @"pdf",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPatientConsultant attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPatientConsultant relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPatientConsultant relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
