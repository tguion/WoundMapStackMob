#import "_WMTelecom.h"
#import "WMFFManagedObject.h"

@interface WMTelecom : _WMTelecom <WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL isEmail;
@property (readonly, nonatomic) NSString *stringValue;

@end
