#import "_WMOrganization.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMOrganization : _WMOrganization <AddressSource, idSource, WMFFManagedObject> {}

@end
