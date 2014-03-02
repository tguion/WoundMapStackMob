// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDefinition.h instead.

#import <CoreData/CoreData.h>


extern const struct WMDefinitionAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *scope;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *term;
	__unsafe_unretained NSString *wmdefinition_id;
} WMDefinitionAttributes;

extern const struct WMDefinitionRelationships {
	__unsafe_unretained NSString *keywords;
} WMDefinitionRelationships;

extern const struct WMDefinitionFetchedProperties {
} WMDefinitionFetchedProperties;

@class WMDefinitionKeyword;









@interface WMDefinitionID : NSManagedObjectID {}
@end

@interface _WMDefinition : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMDefinitionID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scope;



@property int16_t scopeValue;
- (int16_t)scopeValue;
- (void)setScopeValue:(int16_t)value_;

//- (BOOL)validateScope:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* term;



//- (BOOL)validateTerm:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmdefinition_id;



//- (BOOL)validateWmdefinition_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *keywords;

- (NSMutableSet*)keywordsSet;





@end

@interface _WMDefinition (CoreDataGeneratedAccessors)

- (void)addKeywords:(NSSet*)value_;
- (void)removeKeywords:(NSSet*)value_;
- (void)addKeywordsObject:(WMDefinitionKeyword*)value_;
- (void)removeKeywordsObject:(WMDefinitionKeyword*)value_;

@end

@interface _WMDefinition (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveScope;
- (void)setPrimitiveScope:(NSNumber*)value;

- (int16_t)primitiveScopeValue;
- (void)setPrimitiveScopeValue:(int16_t)value_;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTerm;
- (void)setPrimitiveTerm:(NSString*)value;




- (NSString*)primitiveWmdefinition_id;
- (void)setPrimitiveWmdefinition_id:(NSString*)value;





- (NSMutableSet*)primitiveKeywords;
- (void)setPrimitiveKeywords:(NSMutableSet*)value;


@end
