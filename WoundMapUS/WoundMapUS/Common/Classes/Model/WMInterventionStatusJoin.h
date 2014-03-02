#import "_WMInterventionStatusJoin.h"

@interface WMInterventionStatusJoin : _WMInterventionStatusJoin {}

+ (WMInterventionStatusJoin *)interventionStatusJoinFromStatus:(WMInterventionStatus *)fromStatus
                                                      toStatus:(WMInterventionStatus *)toStatus
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
