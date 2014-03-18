#import "_WMWoundLocation.h"
#import "WoundCareProtocols.h"

@interface WMWoundLocation : _WMWoundLocation <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL isOther;
@property (readonly, nonatomic) NSArray *sortedWoundPositionJoins;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundLocation *)woundLocationForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundLocation *)otherWoundLocation:(NSManagedObjectContext *)managedObjectContext;

@end
