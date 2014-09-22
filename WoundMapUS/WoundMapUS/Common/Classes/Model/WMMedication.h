#import "_WMMedication.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundType;

@interface WMMedication : _WMMedication <AssessmentGroup, WMFFManagedObject> {}

@property (nonatomic) BOOL exludesOtherValues;

+ (WMMedication *)medicationForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedication *)updateMedicationFromDictionary:(NSDictionary *)dictionary
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end
