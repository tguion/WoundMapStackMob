// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundMeasurementValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *revisedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMWoundMeasurementValueAttributes;

extern const struct WMWoundMeasurementValueRelationships {
	__unsafe_unretained NSString *amountQualifier;
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *odor;
	__unsafe_unretained NSString *woundMeasurement;
} WMWoundMeasurementValueRelationships;

extern const struct WMWoundMeasurementValueFetchedProperties {
} WMWoundMeasurementValueFetchedProperties;

@class WMAmountQualifier;
@class WMWoundMeasurementGroup;
@class WMWoundOdor;
@class WMWoundMeasurement;










@interface WMWoundMeasurementValueID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* revisedFlag;



@property BOOL revisedFlagValue;
- (BOOL)revisedFlagValue;
- (void)setRevisedFlagValue:(BOOL)value_;

//- (BOOL)validateRevisedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMAmountQualifier *amountQualifier;

//- (BOOL)validateAmountQualifier:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundMeasurementGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundOdor *odor;

//- (BOOL)validateOdor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundMeasurement *woundMeasurement;

//- (BOOL)validateWoundMeasurement:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundMeasurementValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveRevisedFlag;
- (void)setPrimitiveRevisedFlag:(NSNumber*)value;

- (BOOL)primitiveRevisedFlagValue;
- (void)setPrimitiveRevisedFlagValue:(BOOL)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (WMAmountQualifier*)primitiveAmountQualifier;
- (void)setPrimitiveAmountQualifier:(WMAmountQualifier*)value;



- (WMWoundMeasurementGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMWoundMeasurementGroup*)value;



- (WMWoundOdor*)primitiveOdor;
- (void)setPrimitiveOdor:(WMWoundOdor*)value;



- (WMWoundMeasurement*)primitiveWoundMeasurement;
- (void)setPrimitiveWoundMeasurement:(WMWoundMeasurement*)value;


@end
