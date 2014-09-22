#import "_WMWoundLocationPositionJoin.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundPosition, WMWoundLocation;

@interface WMWoundLocationPositionJoin : _WMWoundLocationPositionJoin <AssessmentGroup, WMFFManagedObject> {}

@property (readonly, nonatomic) NSArray *sortedPositions;

+ (WMWoundLocationPositionJoin *)joinForLocation:(WMWoundLocation *)location
                                       positions:(NSSet *)positions
                                          create:(BOOL)create;

- (NSArray *)sortedPositions;
- (WMWoundPosition *)positionAtIndex:(NSInteger)index;

@end
