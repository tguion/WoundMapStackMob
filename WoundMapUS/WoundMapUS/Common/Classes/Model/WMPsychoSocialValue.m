#import "WMPsychoSocialValue.h"
#import "WMPsychoSocialItem.h"

@interface WMPsychoSocialValue ()

// Private interface goes here.

@end


@implementation WMPsychoSocialValue

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSString *)pathToValue
{
    NSMutableArray *path = [[NSMutableArray alloc] initWithCapacity:16];
    WMPsychoSocialItem *psychoSocialItem = self.psychoSocialItem;
    NSString *string = nil;
    while (nil != psychoSocialItem) {
        string = psychoSocialItem.title;
        if (nil != self.value) {
            string = [string stringByAppendingFormat:@": (%@)", self.value];
        }
        [path insertObject:string atIndex:0];
        psychoSocialItem = psychoSocialItem.parentItem;
    }
    return [path componentsJoinedByString:@","];
}

- (NSString *)displayValue
{
    NSString *displayValue = self.value;
    if ([displayValue length] > 0 && [self.psychoSocialItem.options length] > 0) {
        displayValue = [[self.psychoSocialItem.options componentsSeparatedByString:@","] objectAtIndex:[displayValue integerValue]];
    }
    return displayValue;
}

@end
