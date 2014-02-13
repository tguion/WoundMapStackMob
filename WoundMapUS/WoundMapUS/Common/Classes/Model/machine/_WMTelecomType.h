// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTelecomType.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTelecomTypeAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wmtelecomtype_id;
} WMTelecomTypeAttributes;

extern const struct WMTelecomTypeRelationships {
	__unsafe_unretained NSString *telecoms;
} WMTelecomTypeRelationships;

extern const struct WMTelecomTypeFetchedProperties {
} WMTelecomTypeFetchedProperties;

@class WMTelecom;









@interface WMTelecomTypeID : NSManagedObjectID {}
@end

@interface _WMTelecomType : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMTelecomTypeID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* icon;



//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmtelecomtype_id;



//- (BOOL)validateWmtelecomtype_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *telecoms;

- (NSMutableSet*)telecomsSet;





@end

@interface _WMTelecomType (CoreDataGeneratedAccessors)

- (void)addTelecoms:(NSSet*)value_;
- (void)removeTelecoms:(NSSet*)value_;
- (void)addTelecomsObject:(WMTelecom*)value_;
- (void)removeTelecomsObject:(WMTelecom*)value_;

@end

@interface _WMTelecomType (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWmtelecomtype_id;
- (void)setPrimitiveWmtelecomtype_id:(NSString*)value;





- (NSMutableSet*)primitiveTelecoms;
- (void)setPrimitiveTelecoms:(NSMutableSet*)value;


@end
