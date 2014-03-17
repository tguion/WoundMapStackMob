#import "IAPProduct.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

typedef enum {
    IAPProductFlagsAggregator             = 0,
} IAPProductFlags;

@interface IAPProduct ()

// Private interface goes here.

@end


@implementation IAPProduct

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"IAPProducts" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"IAPProducts.plist file not found");
		return;
	}
    // check if already loaded
    if ([IAPProduct productCount:managedObjectContext] > 0) {
        return;
    }
    // else
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateProductFromDictionary:dictionary parent:nil managedObjectContext:managedObjectContext];
        }
    }
}

+ (void)updateProductFromDictionary:(NSDictionary *)dictionary
                             parent:(IAPProduct *)parent
               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (0 == [dictionary count]) {
        return;
    }
    // else
    IAPProduct *iapProduct = nil;
    id object = [dictionary objectForKey:@"identifier"];
    if ([object isKindOfClass:[NSString class]]) {
        iapProduct = [self productForIdentifier:object create:YES managedObjectContext:managedObjectContext];
    }
    iapProduct.parent = parent;
    object = [dictionary objectForKey:@"title"];
    iapProduct.title = object;
    object = [dictionary objectForKey:@"viewTitle"];
    iapProduct.viewTitle = object;
    object = [dictionary objectForKey:@"proposition"];
    iapProduct.proposition = object;
    object = [dictionary objectForKey:@"description"];
    iapProduct.desc = object;
    object = [dictionary objectForKey:@"descHTML"];
    iapProduct.descHTML = object;
    object = [dictionary objectForKey:@"sortRank"];
    iapProduct.sortRank = object;
    object = [dictionary objectForKey:@"aggregatorFlag"];
    iapProduct.aggregatorFlag = [object boolValue];
    // IAP: associate wound type from plist
    object = [dictionary objectForKey:@"woundTypeCode"];
    if ([object isKindOfClass:[NSNumber class]]) {
        WMWoundType *woundType = [[WMWoundType woundTypesForWoundTypeCode:[object integerValue]
                                                     managedObjectContext:managedObjectContext] lastObject];
        iapProduct.woundType = woundType;
    }
    object = [dictionary objectForKey:@"options"];
    if ([object isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in object) {
            [self updateProductFromDictionary:d parent:iapProduct managedObjectContext:managedObjectContext];
        }
    }
}

+ (NSInteger)productCount:(NSManagedObjectContext *)managedObjectContext
{
    return [IAPProduct MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (IAPProduct *)productForIdentifier:(NSString *)identifier
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    IAPProduct *iapProduct = [IAPProduct MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier] inContext:managedObjectContext];
    if (create && nil == iapProduct) {
        iapProduct = [IAPProduct MR_createInContext:managedObjectContext];
        iapProduct.identifier = identifier;
    }
    return iapProduct;
}

- (void)updateIAProductWithSkProduct:(SKProduct *)skProduct
{
    if (nil == skProduct) {
        return;
    }
    // else update our attributes
    NSAssert2([skProduct.productIdentifier isEqualToString:self.identifier], @"IAP product identifier mismatch: %@, %@", skProduct.productIdentifier, self.identifier);
    self.title = skProduct.localizedTitle;
    self.desc = skProduct.localizedDescription;
    self.price = skProduct.price;
}

- (BOOL)aggregatorFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:IAPProductFlagsAggregator];
}

- (void)setAggregatorFlag:(BOOL)aggregatorFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:IAPProductFlagsAggregator to:aggregatorFlag]);
}

@end
