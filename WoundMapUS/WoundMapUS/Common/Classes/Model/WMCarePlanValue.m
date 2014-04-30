#import "WMCarePlanValue.h"
#import "WMCarePlanCategory.h"
#import "WMCarePlanGroup.h"

@interface WMCarePlanValue ()

// Private interface goes here.

@end


@implementation WMCarePlanValue

+ (NSInteger)valueCountForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
{
    if (nil == carePlanGroup) {
        return 0;
    }
    // else
    NSManagedObjectContext *managedObjectContext = [carePlanGroup managedObjectContext];
    return [WMCarePlanValue MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", carePlanGroup] inContext:managedObjectContext];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSArray *)categoryPathToValue
{
    NSMutableArray *path = [[NSMutableArray alloc] initWithCapacity:16];
    WMCarePlanCategory *category = nil;
    NSString *string = nil;
    if (nil != self.category) {
        string = self.category.title;
        if (nil != self.category.snomedCID) {
            string = [string stringByAppendingFormat:@" (%@)", self.category.snomedCID];
        }
        [path addObject:string];
        category = self.category.parent;
    }
    while (nil != category) {
        string = category.title;
        if (nil != category.snomedCID) {
            string = [string stringByAppendingFormat:@" (%@)", category.snomedCID];
        }
        if (nil != self.value) {
            string = [string stringByAppendingFormat:@": (%@)", self.value];
        }
        [path insertObject:string atIndex:0];
        category = category.parent;
    }
    return path;
}

- (NSString *)pathToValue
{
    return [self.categoryPathToValue componentsJoinedByString:@","];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"revisedFlagValue",
                                                            @"categoryPathToValue",
                                                            @"pathToValue"]];
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
    if ([[WMCarePlanValue attributeNamesNotToSerialize] containsObject:propertyName] || [[WMCarePlanValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMCarePlanValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
