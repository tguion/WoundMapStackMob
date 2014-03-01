// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMSkinAssessmentValueAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmskinassessmentvalue_id;
} WMSkinAssessmentValueAttributes;

extern const struct WMSkinAssessmentValueRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *skinAssessment;
} WMSkinAssessmentValueRelationships;

extern const struct WMSkinAssessmentValueFetchedProperties {
} WMSkinAssessmentValueFetchedProperties;

@class WMSkinAssessmentGroup;
@class WMSkinAssessment;










@interface WMSkinAssessmentValueID : NSManagedObjectID {}
@end

@interface _WMSkinAssessmentValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMSkinAssessmentValueID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmskinassessmentvalue_id;



//- (BOOL)validateWmskinassessmentvalue_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMSkinAssessmentGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMSkinAssessment *skinAssessment;

//- (BOOL)validateSkinAssessment:(id*)value_ error:(NSError**)error_;





@end

@interface _WMSkinAssessmentValue (CoreDataGeneratedAccessors)

@end

@interface _WMSkinAssessmentValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveWmskinassessmentvalue_id;
- (void)setPrimitiveWmskinassessmentvalue_id:(NSString*)value;





- (WMSkinAssessmentGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMSkinAssessmentGroup*)value;



- (WMSkinAssessment*)primitiveSkinAssessment;
- (void)setPrimitiveSkinAssessment:(WMSkinAssessment*)value;


@end
