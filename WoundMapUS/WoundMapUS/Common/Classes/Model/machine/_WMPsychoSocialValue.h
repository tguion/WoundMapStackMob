// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPsychoSocialValueAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *revisedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmpsychosocialvalue_id;
} WMPsychoSocialValueAttributes;

extern const struct WMPsychoSocialValueRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *psychoSocialItem;
} WMPsychoSocialValueRelationships;

extern const struct WMPsychoSocialValueFetchedProperties {
} WMPsychoSocialValueFetchedProperties;

@class WMPsychoSocialGroup;
@class WMPsychoSocialItem;












@interface WMPsychoSocialValueID : NSManagedObjectID {}
@end

@interface _WMPsychoSocialValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPsychoSocialValueID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* wmpsychosocialvalue_id;



//- (BOOL)validateWmpsychosocialvalue_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPsychoSocialGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPsychoSocialItem *psychoSocialItem;

//- (BOOL)validatePsychoSocialItem:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPsychoSocialValue (CoreDataGeneratedAccessors)

@end

@interface _WMPsychoSocialValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




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




- (NSString*)primitiveWmpsychosocialvalue_id;
- (void)setPrimitiveWmpsychosocialvalue_id:(NSString*)value;





- (WMPsychoSocialGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMPsychoSocialGroup*)value;



- (WMPsychoSocialItem*)primitivePsychoSocialItem;
- (void)setPrimitivePsychoSocialItem:(WMPsychoSocialItem*)value;


@end
