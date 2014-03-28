// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundLocationValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *updatedAt;
} WMWoundLocationValueAttributes;

extern const struct WMWoundLocationValueRelationships {
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *wound;
} WMWoundLocationValueRelationships;

extern const struct WMWoundLocationValueFetchedProperties {
} WMWoundLocationValueFetchedProperties;

@class WMWoundLocation;
@class WMWound;







@interface WMWoundLocationValueID : NSManagedObjectID {}
@end

@interface _WMWoundLocationValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundLocationValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundLocation *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundLocationValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundLocationValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMWoundLocation*)primitiveLocation;
- (void)setPrimitiveLocation:(WMWoundLocation*)value;



- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;


@end
