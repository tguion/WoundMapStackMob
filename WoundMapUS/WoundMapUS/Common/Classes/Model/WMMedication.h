#import "_WMMedication.h"
#import "WoundCareProtocols.h"

@class WMWoundType;

@interface WMMedication : _WMMedication <AssessmentGroup> {}

@property (nonatomic) BOOL exludesOtherValues;

+ (WMMedication *)medicationForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedication *)updateMedicationFromDictionary:(NSDictionary *)dictionary
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end
