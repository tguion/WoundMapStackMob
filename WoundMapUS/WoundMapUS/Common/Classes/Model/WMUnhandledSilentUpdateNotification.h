#import "_WMUnhandledSilentUpdateNotification.h"

@interface WMUnhandledSilentUpdateNotification : _WMUnhandledSilentUpdateNotification {}

+ (NSArray *)silentUpdateNotificationsForUserName:(NSString *)userName managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
