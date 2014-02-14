#import "_WMNavigationTrack.h"

@interface WMNavigationTrack : _WMNavigationTrack {}

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end
