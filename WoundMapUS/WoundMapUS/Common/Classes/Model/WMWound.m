#import "WMWound.h"
#import "WMWoundType.h"
#import "WMPatient.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWound ()

// Private interface goes here.

@end


@implementation WMWound

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWound *wound = [[WMWound alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWound" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:wound toPersistentStore:store];
	}
    [wound setValue:[wound assignObjectId] forKey:[wound primaryKeyField]];
	return wound;
}

+ (instancetype)instanceWithPatient:(WMPatient *)patient
{
    WMWound *wound = [self instanceWithManagedObjectContext:[patient managedObjectContext] persistentStore:nil];
    wound.patient = patient;
    return wound;
}

+ (NSInteger)woundCountForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWound" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    NSError *error = nil;
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyTryCacheElseNetwork];
    NSInteger count = [managedObjectContext countForFetchRequestAndWait:request options:options error:&error];
    [WMUtilities logError:error];
    return count;
}

+ (WMWound *)woundForPatient:(WMPatient *)patient woundId:(NSString *)woundId
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWound" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND wmwound_id == %@", patient, woundId]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

- (NSInteger)woundPhotosCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWoundPhoto" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

- (NSArray *)woundTypeForDisplay
{
    if (nil == self.woundType) {
        return [NSArray array];
    }
    // else
    NSMutableArray *woundTypes = [[NSMutableArray alloc] initWithCapacity:4];
    WMWoundType *woundType = self.woundType;
    while (nil != woundType) {
        [woundTypes insertObject:woundType.title atIndex:0];
        woundType = woundType.parent;
    }
    return woundTypes;
}

@end
