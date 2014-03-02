#import "IAPProduct.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    IAPProductFlagsAggregator             = 0,
} IAPProductFlags;

@interface IAPProduct ()

// Private interface goes here.

@end


@implementation IAPProduct

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    IAPProduct *iapProduct = [[IAPProduct alloc] initWithEntity:[NSEntityDescription entityForName:@"IAPProduct" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:iapProduct toPersistentStore:store];
	}
    [iapProduct setValue:[iapProduct assignObjectId] forKey:[iapProduct primaryKeyField]];
	return iapProduct;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
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
            [self updateProductFromDictionary:dictionary parent:nil managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

+ (void)updateProductFromDictionary:(NSDictionary *)dictionary
                             parent:(IAPProduct *)parent
               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                    persistentStore:(NSPersistentStore *)store
{
    if (0 == [dictionary count]) {
        return;
    }
    // else
    IAPProduct *iapProduct = nil;
    id object = [dictionary objectForKey:@"identifier"];
    if ([object isKindOfClass:[NSString class]]) {
        iapProduct = [self productForIdentifier:object create:YES managedObjectContext:managedObjectContext persistentStore:store];
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
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store] lastObject];
        iapProduct.woundType = woundType;
    }
    object = [dictionary objectForKey:@"options"];
    if ([object isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in object) {
            [self updateProductFromDictionary:d parent:iapProduct managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

+ (NSInteger)productCount:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"IAPProduct" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (IAPProduct *)productForIdentifier:(NSString *)identifier
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"IAPProduct" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    IAPProduct *iapProduct = [array lastObject];
    if (create && nil == iapProduct) {
        iapProduct = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
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
    //    DLog(@"skProduct.productIdentifier is %@ vs self.identifier: %@", skProduct.productIdentifier, self.identifier);
    //    DLog(@"skProduct.localizedTitle is %@ vs self.title: %@", skProduct.localizedTitle, self.title);
    //    DLog(@"skProduct.localizedDescription is %@ vs self.desc: %@", skProduct.localizedDescription, self.desc);
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
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:IAPProductFlagsAggregator to:aggregatorFlag]];
}

@end
