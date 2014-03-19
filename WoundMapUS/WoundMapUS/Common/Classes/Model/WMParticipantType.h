#import "_WMParticipantType.h"
#import "WoundCareProtocols.h"

@interface WMParticipantType : _WMParticipantType {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;

+ (NSInteger)participantTypeCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipantType *)participantTypeForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedParticipantTypes:(NSManagedObjectContext *)managedObjectContext;

@end
