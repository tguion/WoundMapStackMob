// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicalHistoryValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMMedicalHistoryValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMMedicalHistoryValueAttributes;

extern const struct WMMedicalHistoryValueRelationships {
	__unsafe_unretained NSString *medicalHistoryGroup;
	__unsafe_unretained NSString *medicalHistoryItem;
} WMMedicalHistoryValueRelationships;

extern const struct WMMedicalHistoryValueFetchedProperties {
} WMMedicalHistoryValueFetchedProperties;

@class WMMedicalHistoryGroup;
@class WMMedicalHistoryItem;







@interface WMMedicalHistoryValueID : NSManagedObjectID {}
@end

@interface _WMMedicalHistoryValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMMedicalHistoryValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMMedicalHistoryGroup *medicalHistoryGroup;

//- (BOOL)validateMedicalHistoryGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMMedicalHistoryItem *medicalHistoryItem;

//- (BOOL)validateMedicalHistoryItem:(id*)value_ error:(NSError**)error_;





@end

@interface _WMMedicalHistoryValue (CoreDataGeneratedAccessors)

@end

@interface _WMMedicalHistoryValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (WMMedicalHistoryGroup*)primitiveMedicalHistoryGroup;
- (void)setPrimitiveMedicalHistoryGroup:(WMMedicalHistoryGroup*)value;



- (WMMedicalHistoryItem*)primitiveMedicalHistoryItem;
- (void)setPrimitiveMedicalHistoryItem:(WMMedicalHistoryItem*)value;


@end
