#import "_WMAddress.h"
#import "WMFFManagedObject.h"

@interface WMAddress : _WMAddress <WMFFManagedObject> {}

@property (readonly, nonatomic) NSString *stringValue;

@end
