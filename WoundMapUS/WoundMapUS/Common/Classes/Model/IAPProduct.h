#import "_IAPProduct.h"
#import <StoreKit/StoreKit.h>

@interface IAPProduct : _IAPProduct {}

@property (nonatomic) BOOL aggregatorFlag;
@property (readonly, nonatomic) BOOL descHTMLIsFile;
@property (readonly, nonatomic) NSString *descHTMLValue;
@property (readonly, nonatomic) NSAttributedString *descHTMLAttributedString;

- (void)updateIAProductWithSkProduct:(SKProduct *)skProduct;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (NSInteger)productCount:(NSManagedObjectContext *)managedObjectContext;

+ (IAPProduct *)productForIdentifier:(NSString *)identifier
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
