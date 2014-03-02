// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundTreatmentValueAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *revisedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmwoundtreatmentvalue_id;
} WMWoundTreatmentValueAttributes;

extern const struct WMWoundTreatmentValueRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *woundTreatment;
} WMWoundTreatmentValueRelationships;

extern const struct WMWoundTreatmentValueFetchedProperties {
} WMWoundTreatmentValueFetchedProperties;

@class WMWoundTreatmentGroup;
@class WMWoundTreatment;









@interface WMWoundTreatmentValueID : NSManagedObjectID {}
@end

@interface _WMWoundTreatmentValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundTreatmentValueID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* revisedFlag;



@property BOOL revisedFlagValue;
- (BOOL)revisedFlagValue;
- (void)setRevisedFlagValue:(BOOL)value_;

//- (BOOL)validateRevisedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundtreatmentvalue_id;



//- (BOOL)validateWmwoundtreatmentvalue_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundTreatmentGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundTreatment *woundTreatment;

//- (BOOL)validateWoundTreatment:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundTreatmentValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundTreatmentValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveRevisedFlag;
- (void)setPrimitiveRevisedFlag:(NSNumber*)value;

- (BOOL)primitiveRevisedFlagValue;
- (void)setPrimitiveRevisedFlagValue:(BOOL)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveWmwoundtreatmentvalue_id;
- (void)setPrimitiveWmwoundtreatmentvalue_id:(NSString*)value;





- (WMWoundTreatmentGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMWoundTreatmentGroup*)value;



- (WMWoundTreatment*)primitiveWoundTreatment;
- (void)setPrimitiveWoundTreatment:(WMWoundTreatment*)value;


@end
