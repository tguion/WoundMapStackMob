// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundLocationValueAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *wmwoundlocationvalue_id;
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





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundlocationvalue_id;



//- (BOOL)validateWmwoundlocationvalue_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundLocation *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundLocationValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundLocationValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveWmwoundlocationvalue_id;
- (void)setPrimitiveWmwoundlocationvalue_id:(NSString*)value;





- (WMWoundLocation*)primitiveLocation;
- (void)setPrimitiveLocation:(WMWoundLocation*)value;



- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;


@end
