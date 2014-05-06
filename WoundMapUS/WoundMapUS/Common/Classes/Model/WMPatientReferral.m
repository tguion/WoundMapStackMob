#import "WMPatientReferral.h"
#import "WMParticipant.h"

NSString *const kPatientReferralMessageDelimiter = @"^^^^";

@interface WMPatientReferral ()

@property (readonly, nonatomic) NSDictionary *sourceAttributes;
@property (readonly, nonatomic) NSDictionary *dateAttributes;
@property (readonly, nonatomic) NSDictionary *messageAttributes;

@end


@implementation WMPatientReferral

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (NSArray *)patientReferrals:(BOOL)openFlag managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (openFlag) {
        return [WMPatientReferral MR_findAllSortedBy:WMPatientReferralAttributes.updatedAt
                                           ascending:NO
                                       withPredicate:[NSPredicate predicateWithFormat:@"%K = nil", WMPatientReferralAttributes.dateAccepted]
                                           inContext:managedObjectContext];
    }
    // else
    return [WMPatientReferral MR_findAllSortedBy:WMPatientReferralAttributes.updatedAt ascending:NO inContext:managedObjectContext];
}

- (NSArray *)messageHistory
{
    NSString *message = self.message;
    if ([message length] == 0) {
        return [NSArray array];
    }
    // else
    return [message componentsSeparatedByString:kPatientReferralMessageDelimiter];
}

- (NSArray *)attributedStringMessageHistory
{
    NSArray *messageHistory = self.messageHistory;
    
    NSMutableArray *attributedStringMessageHistory = [[NSMutableArray alloc] init];
    for (NSString *message in messageHistory) {
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        // participant name
        NSRange aRange = [message rangeOfString:@"("];
        NSInteger dateLocation = aRange.location + 1;
        NSString *string = [message substringToIndex:dateLocation];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:self.sourceAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        aRange = [message rangeOfString:@")"];
        NSInteger messageLocation = aRange.location + 1;
        string = [message substringWithRange:NSMakeRange(dateLocation, aRange.location - dateLocation)];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:self.dateAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        string = [message substringWithRange:NSMakeRange(messageLocation - 1, 1)];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:self.sourceAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        string = [message substringFromIndex:messageLocation];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:self.messageAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        [attributedStringMessageHistory addObject:mutableAttributedString];
    }
    return attributedStringMessageHistory;
}

- (void)prependMessage:(NSString *)message from:(WMParticipant *)participant
{
    NSString *prefixToMessage = [NSString stringWithFormat:@"%@ (%@): ", participant.name, [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    NSString *m = self.message;
    if ([m length] == 0) {
        self.message = [prefixToMessage stringByAppendingString:message];
        return;
    }
    // else
    self.message = [NSString stringWithFormat:@"%@%@%@%@", prefixToMessage, message, kPatientReferralMessageDelimiter, m];
}

#pragma mark - NSAttributedString

- (NSDictionary *)sourceAttributes
{
    static NSDictionary *SourceAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 3.0;
        SourceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIColor blackColor], NSForegroundColorAttributeName,
                            [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName,
                            nil];
    });
    return SourceAttributes;
}

- (NSDictionary *)dateAttributes
{
    static NSDictionary *DateAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 3.0;
        DateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIColor grayColor], NSForegroundColorAttributeName,
                            [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName,
                            nil];
    });
    return DateAttributes;
}

- (NSDictionary *)messageAttributes
{
    static NSDictionary *DateAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 3.0;
        DateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor blackColor], NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:9.0], NSFontAttributeName,
                          paragraphStyle, NSParagraphStyleAttributeName,
                          nil];
    });
    return DateAttributes;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"messageHistory",
                                                            @"attributedStringMessageHistory",
                                                            @"sourceAttributes",
                                                            @"dateAttributes",
                                                            @"messageAttributes"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPatientReferral attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPatientReferral relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPatientReferral relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
