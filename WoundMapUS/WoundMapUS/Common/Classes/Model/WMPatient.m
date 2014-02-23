#import "WMPatient.h"
#import "WMPerson.h"
#import "WMId.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMPatient ()

// Private interface goes here.

@end


@implementation WMPatient

@dynamic managedObjectContext, objectID;

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMPatient *patient = [[WMPatient alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:patient toPersistentStore:store];
	}
    [patient setValue:[patient assignObjectId] forKey:[patient primaryKeyField]];
	return patient;
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyTryCacheElseNetwork];
    NSInteger count = [managedObjectContext countForFetchRequestAndWait:request options:options error:&error];
    [WMUtilities logError:error];
    return count;
}

+ (WMPatient *)patientForPatientId:(NSString *)patientId managedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wmpatient_id == %@", patientId]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return [array lastObject];
}

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext
                         persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"archivedFlag == NO"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return [array lastObject];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
}

- (NSString *)lastNameFirstName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0 && [self.ids count] > 0) {
        [array addObject:[[self.ids valueForKeyPath:@"extension"] componentsJoinedByString:@","]];
    }
    if ([array count] == 0) {
        [array addObject:@"New Patient"];
    }
    return [array componentsJoinedByString:@", "];
}

- (NSInteger)genderIndex
{
    NSInteger genderIndex = UISegmentedControlNoSegment;
    if ([@"M" isEqualToString:self.gender]) {
        genderIndex = 0;
    } else if ([@"F" isEqualToString:self.gender]) {
        genderIndex = 1;
    } else if ([@"U" isEqualToString:self.gender]) {
        genderIndex = 2;
    }
    return genderIndex;
}

- (UIImage *)missingThumbnailImage
{
    NSString *avitarFileName = @"user_";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPad"];
    } else {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPhone"];
    }
    return [UIImage imageNamed:avitarFileName];
}

- (WMWound *)lastActiveWound
{
    return [self.sortedWounds firstObject];
}

- (NSArray *)sortedWounds
{
    return [[self.wounds allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
}

- (WMPatientConsultant *)patientConsultantSubmittedSource
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sm_owner == %@", self.sm_owner];
    NSArray *patientConsultants = [self.patientConsultants.allObjects filteredArrayUsingPredicate:predicate];
    NSAssert1([patientConsultants count] < 2, @"Expected only one WMPatientConsultant, but got %d", [patientConsultants count]);
    return [patientConsultants lastObject];
}

- (WMPatientConsultant *)patientConsultantSubmittedTarget
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sm_owner != %@", self.sm_owner];
    NSArray *patientConsultants = [self.patientConsultants.allObjects filteredArrayUsingPredicate:predicate];
    NSAssert1([patientConsultants count] < 2, @"Expected only one WMPatientConsultant, but got %d", [patientConsultants count]);
    return [patientConsultants lastObject];
}

@end
