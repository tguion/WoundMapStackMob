#import "WMSkinAssessmentValue.h"

@interface WMSkinAssessmentValue ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentValue

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end
