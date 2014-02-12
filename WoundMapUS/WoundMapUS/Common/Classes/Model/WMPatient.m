#import "WMPatient.h"
#import "WMPerson.h"
#import "StackMob.h"

@interface WMPatient ()

// Private interface goes here.

@end


@implementation WMPatient

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMPatient *patient = [[WMPatient alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:patient toPersistentStore:store];
	}
    [patient setValue:[patient assignObjectId] forKey:[patient primaryKeyField]];
    patient.person = [WMPerson instanceWithManagedObjectContext:managedObjectContext
                                                persistentStore:store];
	return patient;
}

@end
