#import "_WMCarePlanValue.h"

@interface WMCarePlanValue : _WMCarePlanValue {}

@property (readonly, nonatomic) NSArray *categoryPathToValue;
@property (readonly, nonatomic) NSString *pathToValue;

+ (NSInteger)valueCountForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup;

@end
