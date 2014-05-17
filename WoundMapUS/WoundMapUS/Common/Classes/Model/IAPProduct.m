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

- (BOOL)descHTMLIsFile
{
    return [self.descHTML hasSuffix:@".html"];
}

- (NSString *)descHTMLValue
{
    NSString *htmlString = self.descHTML;
    if (self.descHTMLIsFile) {
        NSInteger index = [htmlString rangeOfString:@".html"].location;
        htmlString = [htmlString substringToIndex:index];
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:htmlString withExtension:@"html"];
        NSError *error = nil;
        htmlString = [[NSString alloc] initWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    return htmlString;
}

- (NSAttributedString *)descHTMLAttributedString
{
    NSAttributedString *attributedString = nil;
    NSString *htmlString = self.descHTML;
    NSError *error = nil;
    if (self.descHTMLIsFile) {
        NSInteger index = [htmlString rangeOfString:@".html"].location;
        htmlString = [htmlString substringToIndex:index];
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:htmlString withExtension:@"html"];
        attributedString = [[NSAttributedString alloc] initWithFileURL:htmlURL
                                                               options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                    documentAttributes:nil
                                                                 error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    } else {
        attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                 documentAttributes:NULL
                                                              error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    return attributedString;
}

- (NSAttributedString *)descHTMLAttributedStringUpdatedWithSKProduct:(SKProduct *)product
{
    // first get the string
    NSString *string = self.descHTML;
    NSError *error = nil;
    if (self.descHTMLIsFile) {
        NSInteger index = [string rangeOfString:@".html"].location;
        string = [string substringToIndex:index];
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:string withExtension:@"html"];
        string = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    // now look for price in string
    NSInteger stringLength = [string length];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSRange range0 = NSMakeRange(0, stringLength);
    NSMutableArray *substrings = [NSMutableArray array];
    NSRange range1 = [string rangeOfString:@"|" options:0 range:range0];
    if (range1.location != NSNotFound) {
        NSRange substringRange = NSMakeRange(range0.location, range1.location - range0.location);
        [substrings addObject:[string substringWithRange:substringRange]];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        [substrings addObject:formattedPrice];
        range0.location = range1.location + 1;
        range0.length = (stringLength - range0.location);
        range1 = [string rangeOfString:@"|" options:0 range:range0];
        range0.location = range1.location + 1;
        range0.length = (stringLength - range0.location);
        // append remaining part of string
        [substrings addObject:[string substringWithRange:range0]];
    }
    string = [substrings componentsJoinedByString:@" "];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                 documentAttributes:NULL
                                                                              error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    return attributedString;
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
