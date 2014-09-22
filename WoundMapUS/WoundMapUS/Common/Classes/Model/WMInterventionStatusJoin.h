#import "_WMInterventionStatusJoin.h"
#import "WMFFManagedObject.h"

@interface WMInterventionStatusJoin : _WMInterventionStatusJoin <WMFFManagedObject> {}

+ (WMInterventionStatusJoin *)interventionStatusJoinFromStatus:(WMInterventionStatus *)fromStatus
                                                      toStatus:(WMInterventionStatus *)toStatus
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
