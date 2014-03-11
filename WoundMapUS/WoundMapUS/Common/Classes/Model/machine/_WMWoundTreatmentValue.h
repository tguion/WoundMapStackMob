// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundTreatmentValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *revisedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) WMWoundTreatmentGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundTreatment *woundTreatment;

//- (BOOL)validateWoundTreatment:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundTreatmentValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundTreatmentValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




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





- (WMWoundTreatmentGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMWoundTreatmentGroup*)value;



- (WMWoundTreatment*)primitiveWoundTreatment;
- (void)setPrimitiveWoundTreatment:(WMWoundTreatment*)value;


@end
