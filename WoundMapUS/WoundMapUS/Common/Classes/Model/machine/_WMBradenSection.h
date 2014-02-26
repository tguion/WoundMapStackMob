// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenSection.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenSectionAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wmbradensection_id;
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





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmbradensection_id;



//- (BOOL)validateWmbradensection_id:(id*)value_ error:(NSError**)error_;





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


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWmbradensection_id;
- (void)setPrimitiveWmbradensection_id:(NSString*)value;





- (WMBradenScale*)primitiveBradenScale;
- (void)setPrimitiveBradenScale:(WMBradenScale*)value;



- (NSMutableSet*)primitiveCells;
- (void)setPrimitiveCells:(NSMutableSet*)value;


@end
