#import "WMUnhandledSilentUpdateNotification.h"


@interface WMUnhandledSilentUpdateNotification ()

// Private interface goes here.

@end


@implementation WMUnhandledSilentUpdateNotification

+ (NSArray *)silentUpdateNotificationsForUserName:(NSString *)userName managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMUnhandledSilentUpdateNotification MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMUnhandledSilentUpdateNotificationAttributes.userNamme, userName] inContext:managedObjectContext];
}

@end
