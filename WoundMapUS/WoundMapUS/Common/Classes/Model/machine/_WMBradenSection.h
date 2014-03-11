// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenSection.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenSectionAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
} WMBradenSectionAttributes;

extern const struct WMBradenSectionRelationships {
	__unsafe_unretained NSString *bradenScale;
	__unsafe_unretained NSString *cells;
} WMBradenSectionRelationships;

extern const struct WMBradenSectionFetchedProperties {
} WMBradenSectionFetchedProperties;

@class WMBradenScale;
@class WMBradenCell;








@interface WMBradenSectionID : NSManagedObjectID {}
@end

@interface _WMBradenSection : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMBradenSectionID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMBradenScale *bradenScale;

//- (BOOL)validateBradenScale:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *cells;

- (NSMutableSet*)cellsSet;





@end

@interface _WMBradenSection (CoreDataGeneratedAccessors)

- (void)addCells:(NSSet*)value_;
- (void)removeCells:(NSSet*)value_;
- (void)addCellsObject:(WMBradenCell*)value_;
- (void)removeCellsObject:(WMBradenCell*)value_;

@end

@interface _WMBradenSection (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMBradenScale*)primitiveBradenScale;
- (void)setPrimitiveBradenScale:(WMBradenScale*)value;



- (NSMutableSet*)primitiveCells;
- (void)setPrimitiveCells:(NSMutableSet*)value;


@end
