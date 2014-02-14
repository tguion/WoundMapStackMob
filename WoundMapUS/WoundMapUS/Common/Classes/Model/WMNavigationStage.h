#import "_WMNavigationStage.h"

@class WMNavigationTrack;

@interface WMNavigationStage : _WMNavigationStage {}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSArray *rootNavigationNodes;
@property (readonly, nonatomic) BOOL isInitialStage;

- (void)updateFromNavigationStage:(WMNavigationStage *)navigationStage
       targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
           targetPersistenceStore:(NSPersistentStore *)targetStore;

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

+ (WMNavigationStage *)updateStageFromDictionary:(NSDictionary *)dictionary
                                           track:(WMNavigationTrack *)navigationTrack
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (WMNavigationStage *)initialStageForTrack:(WMNavigationTrack *)navigationTrack
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store;

+ (WMNavigationStage *)followupStageForTrack:(WMNavigationTrack *)navigationTrack
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store;

+ (WMNavigationStage *)dischargeStageForTrack:(WMNavigationTrack *)navigationTrack
                         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                              persistentStore:(NSPersistentStore *)store;

+ (WMNavigationStage *)stageForTitle:(NSString *)title
                               track:(WMNavigationTrack *)navigationTrack
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store;

+ (NSArray *)sortedStagesForTrack:(WMNavigationTrack *)navigationTrack;

@end
