#import "_WMPatientLocation.h"
#import "WMFFManagedObject.h"

@interface WMPatientLocation : _WMPatientLocation <WMFFManagedObject> {}

@property (readonly, nonatomic) NSString *locationForDisplay;

@end
