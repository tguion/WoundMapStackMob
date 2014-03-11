// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenCell.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenCellAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *primaryDescription;
	__unsafe_unretained NSString *secondaryDescription;
	__unsafe_unretained NSString *selectedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMBradenCellAttributes;

extern const struct WMBradenCellRelationships {
	__unsafe_unretained NSString *section;
} WMBradenCellRelationships;

extern const struct WMBradenCellFetchedProperties {
} WMBradenCellFetchedProperties;

@class WMBradenSection;










@interface WMBradenCellID : NSManagedObjectID {}
@end

@interface _WMBradenCell : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMBradenCellID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* primaryDescription;



//- (BOOL)validatePrimaryDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* secondaryDescription;



//- (BOOL)validateSecondaryDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* selectedFlag;



@property BOOL selectedFlagValue;
- (BOOL)selectedFlagValue;
- (void)setSelectedFlagValue:(BOOL)value_;

//- (BOOL)validateSelectedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* value;



@property int16_t valueValue;
- (int16_t)valueValue;
- (void)setValueValue:(int16_t)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMBradenSection *section;

//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;





@end

@interface _WMBradenCell (CoreDataGeneratedAccessors)

@end

@interface _WMBradenCell (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSString*)primitivePrimaryDescription;
- (void)setPrimitivePrimaryDescription:(NSString*)value;




- (NSString*)primitiveSecondaryDescription;
- (void)setPrimitiveSecondaryDescription:(NSString*)value;




- (NSNumber*)primitiveSelectedFlag;
- (void)setPrimitiveSelectedFlag:(NSNumber*)value;

- (BOOL)primitiveSelectedFlagValue;
- (void)setPrimitiveSelectedFlagValue:(BOOL)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (int16_t)primitiveValueValue;
- (void)setPrimitiveValueValue:(int16_t)value_;





- (WMBradenSection*)primitiveSection;
- (void)setPrimitiveSection:(WMBradenSection*)value;


@end
