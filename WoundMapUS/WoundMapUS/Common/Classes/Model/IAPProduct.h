#import "_IAPProduct.h"
#import <StoreKit/StoreKit.h>

@interface IAPProduct : _IAPProduct {}

@property (nonatomic) BOOL aggregatorFlag;

- (void)updateIAProductWithSkProduct:(SKProduct *)skProduct;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (NSInteger)productCount:(NSManagedObjectContext *)managedObjectContext;

+ (IAPProduct *)productForIdentifier:(NSString *)identifier
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
