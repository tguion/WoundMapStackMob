#import "_WMMedicationGroup.h"
#import "WoundCareProtocols.h"

@interface WMMedicationGroup : _WMMedicationGroup  <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *sortedMedications;
@property (readonly, nonatomic) NSArray *medicationsInGroup;
@property (readonly, nonatomic) BOOL isClosed;

+ (WMMedicationGroup *)medicationGroupByRevising:(WMMedicationGroup *)medicationGroup
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicationGroup *)activeMedicationGroup:(NSManagedObjectContext *)managedObjectContext;
+ (WMMedicationGroup *)mostRecentOrActiveMedicationGroup:(NSManagedObjectContext *)managedObjectContext;
+ (NSDate *)mostRecentOrActiveMedicationGroupDateModified:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)closeMedicationGroupsCreatedBefore:(NSDate *)date
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                persistentStore:(NSPersistentStore *)store;

+ (BOOL)medicalGroupsHaveHistory:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)medicalGroupsCount:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedMedicationGroups:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

- (BOOL)removeExcludesOtherValues;
- (void)incrementContinueCount;

@end
