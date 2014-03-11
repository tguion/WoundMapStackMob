// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMSkinAssessmentValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
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





@property (nonatomic, strong) WMSkinAssessmentGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMSkinAssessment *skinAssessment;

//- (BOOL)validateSkinAssessment:(id*)value_ error:(NSError**)error_;





@end

@interface _WMSkinAssessmentValue (CoreDataGeneratedAccessors)

@end

@interface _WMSkinAssessmentValue (CoreDataGeneratedPrimitiveAccessors)


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





- (WMSkinAssessmentGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMSkinAssessmentGroup*)value;



- (WMSkinAssessment*)primitiveSkinAssessment;
- (void)setPrimitiveSkinAssessment:(WMSkinAssessment*)value;


@end
