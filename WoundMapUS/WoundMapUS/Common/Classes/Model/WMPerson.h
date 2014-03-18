#import "_WMPerson.h"
#import "WoundCareProtocols.h"

@interface WMPerson : _WMPerson  <AddressSource> {}

@property (readonly, nonatomic) NSString *lastNameFirstName;

@end
