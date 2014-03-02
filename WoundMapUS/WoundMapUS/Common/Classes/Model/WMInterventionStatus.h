#import "_WMInterventionStatus.h"

extern NSString * const kInterventionStatusPlanned;
extern NSString * const kInterventionStatusInProcess;
extern NSString * const kInterventionStatusCompleted;
extern NSString * const kInterventionStatusCancelled;
extern NSString * const kInterventionStatusDiscontinue;
extern NSString * const kInterventionStatusNotAdopted;

@interface WMInterventionStatus : _WMInterventionStatus {}

@property (readonly, nonatomic) BOOL isActive;
@property (readonly, nonatomic) BOOL isInProcess;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMInterventionStatus *)initialInterventionStatus:(NSManagedObjectContext *)managedObjectContext;
+ (WMInterventionStatus *)completedInterventionStatus:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionStatus *)interventionStatusForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store;

- (BOOL)canUpdateToStatus:(WMInterventionStatus *)interventionStatus;

@end
