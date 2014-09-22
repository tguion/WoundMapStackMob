#import "_WMWoundLocationValue.h"
#import "WMFFManagedObject.h"

@class WMWound;

@interface WMWoundLocationValue : _WMWoundLocationValue <WMFFManagedObject> {}

+ (WMWoundLocationValue *)woundLocationValueForWound:(WMWound *)wound;

@end
