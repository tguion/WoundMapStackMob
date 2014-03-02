// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationPositionJoin.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundLocationPositionJoinAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *wmwoundlocationpositionjoin_id;
} WMWoundLocationPositionJoinAttributes;

extern const struct WMWoundLocationPositionJoinRelationships {
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *positions;
} WMWoundLocationPositionJoinRelationships;

extern const struct WMWoundLocationPositionJoinFetchedProperties {
} WMWoundLocationPositionJoinFetchedProperties;

@class WMWoundLocation;
@class WMWoundPosition;






@interface WMWoundLocationPositionJoinID : NSManagedObjectID {}
@end

@interface _WMWoundLocationPositionJoin : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundLocationPositionJoinID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundlocationpositionjoin_id;



//- (BOOL)validateWmwoundlocationpositionjoin_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundLocation *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *positions;

- (NSMutableSet*)positionsSet;





@end

@interface _WMWoundLocationPositionJoin (CoreDataGeneratedAccessors)

- (void)addPositions:(NSSet*)value_;
- (void)removePositions:(NSSet*)value_;
- (void)addPositionsObject:(WMWoundPosition*)value_;
- (void)removePositionsObject:(WMWoundPosition*)value_;

@end

@interface _WMWoundLocationPositionJoin (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveWmwoundlocationpositionjoin_id;
- (void)setPrimitiveWmwoundlocationpositionjoin_id:(NSString*)value;





- (WMWoundLocation*)primitiveLocation;
- (void)setPrimitiveLocation:(WMWoundLocation*)value;



- (NSMutableSet*)primitivePositions;
- (void)setPrimitivePositions:(NSMutableSet*)value;


@end
