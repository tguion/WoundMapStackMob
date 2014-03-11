// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenCare.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenCareAttributes {
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *scoreMaximum;
	__unsafe_unretained NSString *scoreMinimum;
	__unsafe_unretained NSString *sectionTitle;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
} WMBradenCareAttributes;

extern const struct WMBradenCareRelationships {
} WMBradenCareRelationships;

extern const struct WMBradenCareFetchedProperties {
} WMBradenCareFetchedProperties;









@interface WMBradenCareID : NSManagedObjectID {}
@end

@interface _WMBradenCare : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMBradenCareID*)objectID;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scoreMaximum;



@property int16_t scoreMaximumValue;
- (int16_t)scoreMaximumValue;
- (void)setScoreMaximumValue:(int16_t)value_;

//- (BOOL)validateScoreMaximum:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scoreMinimum;



@property int16_t scoreMinimumValue;
- (int16_t)scoreMinimumValue;
- (void)setScoreMinimumValue:(int16_t)value_;

//- (BOOL)validateScoreMinimum:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sectionTitle;



//- (BOOL)validateSectionTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _WMBradenCare (CoreDataGeneratedAccessors)

@end

@interface _WMBradenCare (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSNumber*)primitiveScoreMaximum;
- (void)setPrimitiveScoreMaximum:(NSNumber*)value;

- (int16_t)primitiveScoreMaximumValue;
- (void)setPrimitiveScoreMaximumValue:(int16_t)value_;




- (NSNumber*)primitiveScoreMinimum;
- (void)setPrimitiveScoreMinimum:(NSNumber*)value;

- (int16_t)primitiveScoreMinimumValue;
- (void)setPrimitiveScoreMinimumValue:(int16_t)value_;




- (NSString*)primitiveSectionTitle;
- (void)setPrimitiveSectionTitle:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
