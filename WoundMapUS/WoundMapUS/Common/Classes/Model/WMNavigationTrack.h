#import "_WMNavigationTrack.h"

@class WMNavigationStage;

@interface WMNavigationTrack : _WMNavigationTrack {}

@property (nonatomic) BOOL ignoresStagesFlag;
@property (nonatomic) BOOL ignoresSignInFlag;
@property (nonatomic) BOOL limitToSinglePatientFlag;
@property (nonatomic) BOOL skipCarePlanFlag;
@property (nonatomic) BOOL skipPolicyEditor;
@property (readonly, nonatomic) WMNavigationStage *initialStage;

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (void)seedDatabaseSourceManagedObjectContext:(NSManagedObjectContext *)sourceManagedObjectContext
                         sourcePersistentStore:(NSPersistentStore *)sourceStore
                    targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
                        targetPersistenceStore:(NSPersistentStore *)targetStore;

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store;

+ (WMNavigationTrack *)trackForId:(NSString *)navigationTrackId
             managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  persistentStore:(NSPersistentStore *)store;

@end
