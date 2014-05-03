#import "_WMPatientReferral.h"

@interface WMPatientReferral : _WMPatientReferral {}

@property (readonly, nonatomic) NSArray *messageHistory;                    // @[participent name (date): message, ...]
@property (readonly, nonatomic) NSArray *attributedStringMessageHistory;    // @[participent name (date): message, ...]

- (void)prependMessage:(NSString *)message from:(WMParticipant *)participant;

@end
