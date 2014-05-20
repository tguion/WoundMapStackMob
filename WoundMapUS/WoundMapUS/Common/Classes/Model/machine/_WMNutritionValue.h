// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNutritionValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMNutritionValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMNutritionValueAttributes;

extern const struct WMNutritionValueRelationships {
	__unsafe_unretained NSString *item;
	__unsafe_unretained NSString *nutritionGroup;
} WMNutritionValueRelationships;

extern const struct WMNutritionValueFetchedProperties {
} WMNutritionValueFetchedProperties;

@class WMNutritionItem;
@class WMNutritionGroup;








@interface WMNutritionValueID : NSManagedObjectID {}
@end

@interface _WMNutritionValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMNutritionValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMNutritionItem *item;

//- (BOOL)validateItem:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMNutritionGroup *nutritionGroup;

//- (BOOL)validateNutritionGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMNutritionValue (CoreDataGeneratedAccessors)

@end

@interface _WMNutritionValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (WMNutritionItem*)primitiveItem;
- (void)setPrimitiveItem:(WMNutritionItem*)value;



- (WMNutritionGroup*)primitiveNutritionGroup;
- (void)setPrimitiveNutritionGroup:(WMNutritionGroup*)value;


@end
