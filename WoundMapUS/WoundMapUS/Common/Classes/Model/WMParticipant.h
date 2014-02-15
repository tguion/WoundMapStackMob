#import "_WMParticipant.h"

@interface WMParticipant : _WMParticipant {}

+ (NSInteger)participantCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)bestMatchingParticipantFetchRequestForUserName:(NSString *)name
                                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      persistentStore:(NSPersistentStore *)store;

+ (WMParticipant *)duplicateParticipant:(WMParticipant *)participant
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store;

@end
