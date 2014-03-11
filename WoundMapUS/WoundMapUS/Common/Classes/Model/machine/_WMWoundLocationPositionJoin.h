// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationPositionJoin.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundLocationPositionJoinAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *updatedAt;
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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





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


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMWoundLocation*)primitiveLocation;
- (void)setPrimitiveLocation:(WMWoundLocation*)value;



- (NSMutableSet*)primitivePositions;
- (void)setPrimitivePositions:(NSMutableSet*)value;


@end
