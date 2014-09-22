#import "_WMCarePlanValue.h"
#import "WMFFManagedObject.h"

@interface WMCarePlanValue : _WMCarePlanValue <WMFFManagedObject> {}

@property (readonly, nonatomic) NSArray *categoryPathToValue;
@property (readonly, nonatomic) NSString *pathToValue;

+ (NSInteger)valueCountForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup;

@end
