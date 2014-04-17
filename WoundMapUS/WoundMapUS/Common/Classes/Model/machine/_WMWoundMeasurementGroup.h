// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundMeasurementGroupAttributes {
	__unsafe_unretained NSString *closedFlag;
	__unsafe_unretained NSString *continueCount;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
} WMWoundMeasurementGroupAttributes;

extern const struct WMWoundMeasurementGroupRelationships {
	__unsafe_unretained NSString *interventionEvents;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *values;
	__unsafe_unretained NSString *wound;
	__unsafe_unretained NSString *woundPhoto;
} WMWoundMeasurementGroupRelationships;

extern const struct WMWoundMeasurementGroupFetchedProperties {
} WMWoundMeasurementGroupFetchedProperties;

@class WMInterventionEvent;
@class WMInterventionStatus;
@class WMWoundMeasurementValue;
@class WMWound;
@class WMWoundPhoto;









@interface WMWoundMeasurementGroupID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementGroupID*)objectID;





@property (nonatomic, strong) NSNumber* closedFlag;



@property BOOL closedFlagValue;
- (BOOL)closedFlagValue;
- (void)setClosedFlagValue:(BOOL)value_;

//- (BOOL)validateClosedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* continueCount;



@property int16_t continueCountValue;
- (int16_t)continueCountValue;
- (void)setContinueCountValue:(int16_t)value_;

//- (BOOL)validateContinueCount:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *interventionEvents;

- (NSMutableSet*)interventionEventsSet;




@property (nonatomic, strong) WMInterventionStatus *status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;




@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundPhoto *woundPhoto;

//- (BOOL)validateWoundPhoto:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundMeasurementGroup (CoreDataGeneratedAccessors)

- (void)addInterventionEvents:(NSSet*)value_;
- (void)removeInterventionEvents:(NSSet*)value_;
- (void)addInterventionEventsObject:(WMInterventionEvent*)value_;
- (void)removeInterventionEventsObject:(WMInterventionEvent*)value_;

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMWoundMeasurementValue*)value_;
- (void)removeValuesObject:(WMWoundMeasurementValue*)value_;

@end

@interface _WMWoundMeasurementGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClosedFlag;
- (void)setPrimitiveClosedFlag:(NSNumber*)value;

- (BOOL)primitiveClosedFlagValue;
- (void)setPrimitiveClosedFlagValue:(BOOL)value_;




- (NSNumber*)primitiveContinueCount;
- (void)setPrimitiveContinueCount:(NSNumber*)value;

- (int16_t)primitiveContinueCountValue;
- (void)setPrimitiveContinueCountValue:(int16_t)value_;




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




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveInterventionEvents;
- (void)setPrimitiveInterventionEvents:(NSMutableSet*)value;



- (WMInterventionStatus*)primitiveStatus;
- (void)setPrimitiveStatus:(WMInterventionStatus*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;



- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;



- (WMWoundPhoto*)primitiveWoundPhoto;
- (void)setPrimitiveWoundPhoto:(WMWoundPhoto*)value;


@end
