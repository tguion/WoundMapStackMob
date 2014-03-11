// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IAPProduct.h instead.

#import <CoreData/CoreData.h>


extern const struct IAPProductAttributes {
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *descHTML;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *iapproduct_id;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *price;
	__unsafe_unretained NSString *proposition;
	__unsafe_unretained NSString *purchasedFlag;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *tokenCount;
	__unsafe_unretained NSString *viewTitle;
} IAPProductAttributes;

extern const struct IAPProductRelationships {
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *woundType;
} IAPProductRelationships;

extern const struct IAPProductFetchedProperties {
} IAPProductFetchedProperties;

@class IAPProduct;
@class IAPProduct;
@class WMWoundType;














@interface IAPProductID : NSManagedObjectID {}
@end

@interface _IAPProduct : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IAPProductID*)objectID;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* descHTML;



//- (BOOL)validateDescHTML:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iapproduct_id;



//- (BOOL)validateIapproduct_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* price;



//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* proposition;



//- (BOOL)validateProposition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* purchasedFlag;



@property BOOL purchasedFlagValue;
- (BOOL)purchasedFlagValue;
- (void)setPurchasedFlagValue:(BOOL)value_;

//- (BOOL)validatePurchasedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* tokenCount;



@property int16_t tokenCountValue;
- (int16_t)tokenCountValue;
- (void)setTokenCountValue:(int16_t)value_;

//- (BOOL)validateTokenCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewTitle;



//- (BOOL)validateViewTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;




@property (nonatomic, strong) IAPProduct *parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundType *woundType;

//- (BOOL)validateWoundType:(id*)value_ error:(NSError**)error_;





@end

@interface _IAPProduct (CoreDataGeneratedAccessors)

- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(IAPProduct*)value_;
- (void)removeOptionsObject:(IAPProduct*)value_;

@end

@interface _IAPProduct (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSString*)primitiveDescHTML;
- (void)setPrimitiveDescHTML:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveIapproduct_id;
- (void)setPrimitiveIapproduct_id:(NSString*)value;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSDecimalNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSDecimalNumber*)value;




- (NSString*)primitiveProposition;
- (void)setPrimitiveProposition:(NSString*)value;




- (NSNumber*)primitivePurchasedFlag;
- (void)setPrimitivePurchasedFlag:(NSNumber*)value;

- (BOOL)primitivePurchasedFlagValue;
- (void)setPrimitivePurchasedFlagValue:(BOOL)value_;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveTokenCount;
- (void)setPrimitiveTokenCount:(NSNumber*)value;

- (int16_t)primitiveTokenCountValue;
- (void)setPrimitiveTokenCountValue:(int16_t)value_;




- (NSString*)primitiveViewTitle;
- (void)setPrimitiveViewTitle:(NSString*)value;





- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;



- (IAPProduct*)primitiveParent;
- (void)setPrimitiveParent:(IAPProduct*)value;



- (WMWoundType*)primitiveWoundType;
- (void)setPrimitiveWoundType:(WMWoundType*)value;


@end
