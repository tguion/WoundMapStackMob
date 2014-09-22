#import "_WMInterventionStatus.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

extern NSString * const kInterventionStatusPlanned;
extern NSString * const kInterventionStatusInProcess;
extern NSString * const kInterventionStatusCompleted;
extern NSString * const kInterventionStatusCancelled;
extern NSString * const kInterventionStatusDiscontinue;
extern NSString * const kInterventionStatusNotAdopted;

@interface WMInterventionStatus : _WMInterventionStatus <WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL isActive;
@property (readonly, nonatomic) BOOL isInProcess;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMInterventionStatus *)initialInterventionStatus:(NSManagedObjectContext *)managedObjectContext;
+ (WMInterventionStatus *)completedInterventionStatus:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionStatus *)interventionStatusForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)canUpdateToStatus:(WMInterventionStatus *)interventionStatus;

@end
