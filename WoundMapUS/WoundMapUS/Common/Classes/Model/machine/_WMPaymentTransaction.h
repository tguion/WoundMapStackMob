// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPaymentTransaction.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPaymentTransactionAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *errorCode;
	__unsafe_unretained NSString *errorMessage;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *originalTransactionIdentifier;
	__unsafe_unretained NSString *productIdentifier;
	__unsafe_unretained NSString *quantity;
	__unsafe_unretained NSString *transactionDate;
	__unsafe_unretained NSString *transactionIdentifier;
	__unsafe_unretained NSString *transactionState;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *username;
} WMPaymentTransactionAttributes;

extern const struct WMPaymentTransactionRelationships {
} WMPaymentTransactionRelationships;

extern const struct WMPaymentTransactionFetchedProperties {
} WMPaymentTransactionFetchedProperties;
















@interface WMPaymentTransactionID : NSManagedObjectID {}
@end

@interface _WMPaymentTransaction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPaymentTransactionID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* errorCode;



@property int32_t errorCodeValue;
- (int32_t)errorCodeValue;
- (void)setErrorCodeValue:(int32_t)value_;

//- (BOOL)validateErrorCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* errorMessage;



//- (BOOL)validateErrorMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* originalTransactionIdentifier;



//- (BOOL)validateOriginalTransactionIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* productIdentifier;



//- (BOOL)validateProductIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* quantity;



@property int16_t quantityValue;
- (int16_t)quantityValue;
- (void)setQuantityValue:(int16_t)value_;

//- (BOOL)validateQuantity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* transactionDate;



//- (BOOL)validateTransactionDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* transactionIdentifier;



//- (BOOL)validateTransactionIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transactionState;



@property int16_t transactionStateValue;
- (int16_t)transactionStateValue;
- (void)setTransactionStateValue:(int16_t)value_;

//- (BOOL)validateTransactionState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;






@end

@interface _WMPaymentTransaction (CoreDataGeneratedAccessors)

@end

@interface _WMPaymentTransaction (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSNumber*)primitiveErrorCode;
- (void)setPrimitiveErrorCode:(NSNumber*)value;

- (int32_t)primitiveErrorCodeValue;
- (void)setPrimitiveErrorCodeValue:(int32_t)value_;




- (NSString*)primitiveErrorMessage;
- (void)setPrimitiveErrorMessage:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveOriginalTransactionIdentifier;
- (void)setPrimitiveOriginalTransactionIdentifier:(NSString*)value;




- (NSString*)primitiveProductIdentifier;
- (void)setPrimitiveProductIdentifier:(NSString*)value;




- (NSNumber*)primitiveQuantity;
- (void)setPrimitiveQuantity:(NSNumber*)value;

- (int16_t)primitiveQuantityValue;
- (void)setPrimitiveQuantityValue:(int16_t)value_;




- (NSDate*)primitiveTransactionDate;
- (void)setPrimitiveTransactionDate:(NSDate*)value;




- (NSString*)primitiveTransactionIdentifier;
- (void)setPrimitiveTransactionIdentifier:(NSString*)value;




- (NSNumber*)primitiveTransactionState;
- (void)setPrimitiveTransactionState:(NSNumber*)value;

- (int16_t)primitiveTransactionStateValue;
- (void)setPrimitiveTransactionStateValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
