#import "_WMNavigationTrack.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMNavigationStage;

@interface WMNavigationTrack : _WMNavigationTrack <WMFFManagedObject> {}

+ (NSSet *)attributeNamesNotToSerialize;
+ (NSSet *)relationshipNamesNotToSerialize;

@property (nonatomic) BOOL ignoresStagesFlag;
@property (nonatomic) BOOL ignoresSignInFlag;
@property (nonatomic) BOOL limitToSinglePatientFlag;
@property (nonatomic) BOOL skipCarePlanFlag;
@property (nonatomic) BOOL skipPolicyEditor;
@property (readonly, nonatomic) WMNavigationStage *initialStage;

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;
+ (void)seedDatabaseForTeam:(WMTeam *)team completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)sortedTracksForTeam:(WMTeam *)team;

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                                team:(WMTeam *)team
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMNavigationTrack *)trackForFFURL:(NSString *)ffUrl
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
