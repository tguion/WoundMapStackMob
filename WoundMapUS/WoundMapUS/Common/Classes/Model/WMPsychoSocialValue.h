#import "_WMPsychoSocialValue.h"
#import "WMFFManagedObject.h"

@interface WMPsychoSocialValue : _WMPsychoSocialValue <WMFFManagedObject> {}

@property (readonly, nonatomic) NSString *pathToValue;
@property (readonly, nonatomic) NSString *displayValue;

@end
