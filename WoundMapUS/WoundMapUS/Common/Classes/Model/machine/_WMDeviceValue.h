// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDeviceValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMDeviceValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *dateAttach;
	__unsafe_unretained NSString *dateRemove;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *revisedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMDeviceValueAttributes;

extern const struct WMDeviceValueRelationships {
	__unsafe_unretained NSString *device;
	__unsafe_unretained NSString *group;
} WMDeviceValueRelationships;

extern const struct WMDeviceValueFetchedProperties {
} WMDeviceValueFetchedProperties;

@class WMDevice;
@class WMDeviceGroup;











@interface WMDeviceValueID : NSManagedObjectID {}
@end

@interface _WMDeviceValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMDeviceValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAttach;



//- (BOOL)validateDateAttach:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateRemove;



//- (BOOL)validateDateRemove:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) WMDevice *device;

//- (BOOL)validateDevice:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMDeviceGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMDeviceValue (CoreDataGeneratedAccessors)

@end

@interface _WMDeviceValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDateAttach;
- (void)setPrimitiveDateAttach:(NSDate*)value;




- (NSDate*)primitiveDateRemove;
- (void)setPrimitiveDateRemove:(NSDate*)value;




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





- (WMDevice*)primitiveDevice;
- (void)setPrimitiveDevice:(WMDevice*)value;



- (WMDeviceGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMDeviceGroup*)value;


@end
