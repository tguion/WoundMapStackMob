#import "_WMWoundLocation.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMWoundLocation : _WMWoundLocation <AssessmentGroup, WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL isOther;
@property (readonly, nonatomic) NSArray *sortedWoundPositionJoins;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMWoundLocation *)woundLocationForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundLocation *)otherWoundLocation:(NSManagedObjectContext *)managedObjectContext;

@end
