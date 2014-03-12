#import "_WMParticipantType.h"

@interface WMParticipantType : _WMParticipantType {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (NSInteger)participantTypeCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipantType *)participantTypeForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedParticipantTypes:(NSManagedObjectContext *)managedObjectContext;

@end
