// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMIAPTransaction.h instead.

#import <CoreData/CoreData.h>


extern const struct WMIAPTransactionAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *credits;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *startupCredits;
	__unsafe_unretained NSString *txnDate;
	__unsafe_unretained NSString *txnId;
	__unsafe_unretained NSString *wmiaptransaction_id;
} WMIAPTransactionAttributes;

extern const struct WMIAPTransactionRelationships {
} WMIAPTransactionRelationships;

extern const struct WMIAPTransactionFetchedProperties {
} WMIAPTransactionFetchedProperties;











@interface WMIAPTransactionID : NSManagedObjectID {}
@end

@interface _WMIAPTransaction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMIAPTransactionID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* credits;



@property int32_t creditsValue;
- (int32_t)creditsValue;
- (void)setCreditsValue:(int32_t)value_;

//- (BOOL)validateCredits:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startupCredits;



@property BOOL startupCreditsValue;
- (BOOL)startupCreditsValue;
- (void)setStartupCreditsValue:(BOOL)value_;

//- (BOOL)validateStartupCredits:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* txnDate;



//- (BOOL)validateTxnDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* txnId;



//- (BOOL)validateTxnId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmiaptransaction_id;



//- (BOOL)validateWmiaptransaction_id:(id*)value_ error:(NSError**)error_;






@end

@interface _WMIAPTransaction (CoreDataGeneratedAccessors)

@end

@interface _WMIAPTransaction (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSNumber*)primitiveCredits;
- (void)setPrimitiveCredits:(NSNumber*)value;

- (int32_t)primitiveCreditsValue;
- (void)setPrimitiveCreditsValue:(int32_t)value_;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveStartupCredits;
- (void)setPrimitiveStartupCredits:(NSNumber*)value;

- (BOOL)primitiveStartupCreditsValue;
- (void)setPrimitiveStartupCreditsValue:(BOOL)value_;




- (NSDate*)primitiveTxnDate;
- (void)setPrimitiveTxnDate:(NSDate*)value;




- (NSString*)primitiveTxnId;
- (void)setPrimitiveTxnId:(NSString*)value;




- (NSString*)primitiveWmiaptransaction_id;
- (void)setPrimitiveWmiaptransaction_id:(NSString*)value;




@end
