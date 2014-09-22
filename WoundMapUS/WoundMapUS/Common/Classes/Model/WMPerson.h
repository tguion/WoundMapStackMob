#import "_WMPerson.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMPerson : _WMPerson  <AddressSource, TelecomSource, WMFFManagedObject> {}

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) WMTelecom *defaultEmailTelecom;

@end
