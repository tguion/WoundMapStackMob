#import "_WMParticipant.h"

@interface WMParticipant : _WMParticipant {}

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      persistentStore:(NSPersistentStore *)store;

+ (WMParticipant *)duplicateParticipant:(WMParticipant *)participant
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store;

@end
