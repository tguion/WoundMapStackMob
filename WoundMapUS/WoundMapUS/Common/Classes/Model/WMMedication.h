#import "_WMMedication.h"
#import "WoundCareProtocols.h"

@class WMWoundType;

@interface WMMedication : _WMMedication <AssessmentGroup> {}

@property (nonatomic) BOOL exludesOtherValues;

+ (WMMedication *)medicationForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store;

+ (WMMedication *)updateMedicationFromDictionary:(NSDictionary *)dictionary
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end
