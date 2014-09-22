#import "_WMPatientReferral.h"
#import "WMFFManagedObject.h"

@interface WMPatientReferral : _WMPatientReferral <WMFFManagedObject> {}

@property (readonly, nonatomic) NSArray *messageHistory;                    // @[participent name (date): message, ...]
@property (readonly, nonatomic) NSArray *attributedStringMessageHistory;    // @[participent name (date): message, ...]

+ (NSArray *)patientReferrals:(BOOL)openFlag managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)prependMessage:(NSString *)message from:(WMParticipant *)participant;

@end
