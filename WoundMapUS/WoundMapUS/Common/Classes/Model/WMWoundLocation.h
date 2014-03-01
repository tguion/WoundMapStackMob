#import "_WMWoundLocation.h"
#import "WoundCareProtocols.h"

@interface WMWoundLocation : _WMWoundLocation <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL isOther;
@property (readonly, nonatomic) NSArray *sortedWoundPositionJoins;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMWoundLocation *)woundLocationForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                           persistentStore:(NSPersistentStore *)store;

+ (WMWoundLocation *)otherWoundLocation:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store;

@end
