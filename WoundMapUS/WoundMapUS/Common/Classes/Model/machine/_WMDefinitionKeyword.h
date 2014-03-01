// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDefinitionKeyword.h instead.

#import <CoreData/CoreData.h>


extern const struct WMDefinitionKeywordAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *keyword;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *scope;
	__unsafe_unretained NSString *wmdefinitionkeyword_id;
} WMDefinitionKeywordAttributes;

extern const struct WMDefinitionKeywordRelationships {
	__unsafe_unretained NSString *definition;
} WMDefinitionKeywordRelationships;

extern const struct WMDefinitionKeywordFetchedProperties {
} WMDefinitionKeywordFetchedProperties;

@class WMDefinition;







@interface WMDefinitionKeywordID : NSManagedObjectID {}
@end

@interface _WMDefinitionKeyword : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMDefinitionKeywordID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* keyword;



//- (BOOL)validateKeyword:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scope;



@property int16_t scopeValue;
- (int16_t)scopeValue;
- (void)setScopeValue:(int16_t)value_;

//- (BOOL)validateScope:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmdefinitionkeyword_id;



//- (BOOL)validateWmdefinitionkeyword_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMDefinition *definition;

//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@end

@interface _WMDefinitionKeyword (CoreDataGeneratedAccessors)

@end

@interface _WMDefinitionKeyword (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveKeyword;
- (void)setPrimitiveKeyword:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveScope;
- (void)setPrimitiveScope:(NSNumber*)value;

- (int16_t)primitiveScopeValue;
- (void)setPrimitiveScopeValue:(int16_t)value_;




- (NSString*)primitiveWmdefinitionkeyword_id;
- (void)setPrimitiveWmdefinitionkeyword_id:(NSString*)value;





- (WMDefinition*)primitiveDefinition;
- (void)setPrimitiveDefinition:(WMDefinition*)value;


@end
