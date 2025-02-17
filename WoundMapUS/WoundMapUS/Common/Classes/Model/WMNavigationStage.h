#import "_WMNavigationStage.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMNavigationTrack;

@interface WMNavigationStage : _WMNavigationStage <WMFFManagedObject> {}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) NSArray *rootNavigationNodes;
@property (readonly, nonatomic) BOOL isInitialStage;

+ (WMNavigationStage *)updateStageFromDictionary:(NSDictionary *)dictionary
                                           track:(WMNavigationTrack *)navigationTrack
                                          create:(BOOL)create;

+ (WMNavigationStage *)initialStageForTrack:(WMNavigationTrack *)navigationTrack;

+ (WMNavigationStage *)followupStageForTrack:(WMNavigationTrack *)navigationTrack;

+ (WMNavigationStage *)dischargeStageForTrack:(WMNavigationTrack *)navigationTrack;

+ (WMNavigationStage *)stageForTitle:(NSString *)title
                               track:(WMNavigationTrack *)navigationTrack
                              create:(BOOL)create;

+ (NSArray *)sortedStagesForTrack:(WMNavigationTrack *)navigationTrack;

@end
