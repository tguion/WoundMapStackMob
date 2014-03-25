#import "_WMPerson.h"
#import "WoundCareProtocols.h"

@interface WMPerson : _WMPerson  <AddressSource, TelecomSource> {}

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (readonly, nonatomic) WMTelecom *defaultEmailTelecom;

@end
