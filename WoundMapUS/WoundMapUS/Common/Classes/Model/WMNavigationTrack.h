#import "_WMNavigationTrack.h"
#import "WoundCareProtocols.h"

@class WMNavigationStage;

@interface WMNavigationTrack : _WMNavigationTrack {}

+ (NSSet *)attributeNamesNotToSerialize;
+ (NSSet *)relationshipNamesNotToSerialize;

@property (nonatomic) BOOL ignoresStagesFlag;
@property (nonatomic) BOOL ignoresSignInFlag;
@property (nonatomic) BOOL limitToSinglePatientFlag;
@property (nonatomic) BOOL skipCarePlanFlag;
@property (nonatomic) BOOL skipPolicyEditor;
@property (readonly, nonatomic) WMNavigationStage *initialStage;

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;
+ (void)seedDatabaseForTeam:(WMTeam *)team completionHandler:(WMProcessCallback)completionHandler;

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext;

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMNavigationTrack *)trackForFFURL:(NSString *)ffUrl
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
