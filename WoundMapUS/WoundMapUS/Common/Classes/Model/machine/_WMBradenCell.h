// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenCell.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenCellAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *primaryDescription;
	__unsafe_unretained NSString *secondaryDescription;
	__unsafe_unretained NSString *selectedFlag;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmbradencell_id;
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





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* value;



@property int16_t valueValue;
- (int16_t)valueValue;
- (void)setValueValue:(int16_t)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmbradencell_id;



//- (BOOL)validateWmbradencell_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMBradenSection *section;

//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;





@end

@interface _WMBradenCell (CoreDataGeneratedAccessors)

@end

@interface _WMBradenCell (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




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




- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (int16_t)primitiveValueValue;
- (void)setPrimitiveValueValue:(int16_t)value_;




- (NSString*)primitiveWmbradencell_id;
- (void)setPrimitiveWmbradencell_id:(NSString*)value;





- (WMBradenSection*)primitiveSection;
- (void)setPrimitiveSection:(WMBradenSection*)value;


@end
