#import "WMFFMetadata.h"


@interface WMFFMetadata ()

// Private interface goes here.

@end


@implementation WMFFMetadata

// Custom logic goes here.

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}

- (BOOL)requireUpdatesFromCloud
{
    return NO;
}

@end
