#import "_WMWoundLocationPositionJoin.h"
#import "WoundCareProtocols.h"

@class WMWoundPosition, WMWoundLocation;

@interface WMWoundLocationPositionJoin : _WMWoundLocationPositionJoin <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *sortedPositions;

+ (WMWoundLocationPositionJoin *)joinForLocation:(WMWoundLocation *)location
                                       positions:(NSSet *)positions
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

- (NSArray *)sortedPositions;
- (WMWoundPosition *)positionAtIndex:(NSInteger)index;

@end
