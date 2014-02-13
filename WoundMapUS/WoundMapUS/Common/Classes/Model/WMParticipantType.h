#import "_WMParticipantType.h"

@interface WMParticipantType : _WMParticipantType {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (NSInteger)participantTypeCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMParticipantType *)participantTypeForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store;

+ (NSArray *)sortedParticipantTypes:(NSManagedObjectContext *)managedObjectContext;

@end
