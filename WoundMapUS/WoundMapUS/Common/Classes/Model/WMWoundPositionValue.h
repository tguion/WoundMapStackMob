#import "_WMWoundPositionValue.h"
#import "WMFFManagedObject.h"

@class WMWound;

@interface WMWoundPositionValue : _WMWoundPositionValue <WMFFManagedObject> {}

+ (WMWoundPositionValue *)woundPositionValueForWound:(WMWound *)wound;

@end
