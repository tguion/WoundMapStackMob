#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundPhoto.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kDimensionsWoundMeasurementTitle = @"Dimensions";
NSString * const kDimensionWidthWoundMeasurementTitle = @"Width";
NSString * const kDimensionLengthWoundMeasurementTitle = @"Length";
NSString * const kDimensionDepthWoundMeasurementTitle = @"Depth";
NSString * const kDimensionUndermineTunnelMeasurementTitle = @"Undermining & Tunneling";

@interface WMWoundMeasurementGroup ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementGroup

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementGroup *woundMeasurementGroup = [[WMWoundMeasurementGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementGroup toPersistentStore:store];
	}
    [woundMeasurementGroup setValue:[woundMeasurementGroup assignObjectId] forKey:[woundMeasurementGroup primaryKeyField]];
	return woundMeasurementGroup;
}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    return [self woundMeasurementGroupForWoundPhoto:woundPhoto create:YES];
}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto create:(BOOL)create
{
    // check for existing group
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@", woundPhoto]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError __autoreleasing *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundMeasurementGroup *woundMeasurementGroup = [array lastObject];
    if (create && nil == woundMeasurementGroup) {
        woundMeasurementGroup = [self instanceWithManagedObjectContext:[woundPhoto managedObjectContext] persistentStore:nil];
        woundMeasurementGroup.woundPhoto = woundPhoto;
        NSAssert(nil != woundPhoto.wound, @"woundPhoto must be associated with a wound");
        woundMeasurementGroup.wound = woundPhoto.wound;
    }
    return woundMeasurementGroup;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
    // initial status
//    self.status = [WCInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (WMWoundMeasurementValue *)measurementValueWidth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionWidthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil
                                     managedObjectContext:[self managedObjectContext]];
}

- (WMWoundMeasurementValue *)measurementValueLength
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionLengthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil
                                     managedObjectContext:[self managedObjectContext]];
}

- (WMWoundMeasurementValue *)measurementValueDepth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionDepthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil
                                     managedObjectContext:[self managedObjectContext]];
}

- (WMWoundMeasurementValue *)woundMeasurementValueForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
                                                               create:(BOOL)create
                                                                value:(id)value
                                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([woundMeasurement managedObjectContext] == managedObjectContext);
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"value == %@", value]]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
	// else
    WMWoundMeasurementValue *woundMeasurementValue = [array lastObject];
    if (create && nil == woundMeasurementValue) {
        woundMeasurementValue = [WMWoundMeasurementValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        woundMeasurementValue.woundMeasurement = woundMeasurement;
        woundMeasurementValue.value = value;
        woundMeasurementValue.title = woundMeasurement.title;
        [self addValuesObject:woundMeasurementValue];
    }
    return woundMeasurementValue;
}

@end
