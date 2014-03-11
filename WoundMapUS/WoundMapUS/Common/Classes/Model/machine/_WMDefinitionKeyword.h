// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDefinitionKeyword.h instead.

#import <CoreData/CoreData.h>


extern const struct WMDefinitionKeywordAttributes {
	__unsafe_unretained NSString *keyword;
	__unsafe_unretained NSString *scope;
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





@property (nonatomic, strong) NSString* keyword;



//- (BOOL)validateKeyword:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scope;



@property int16_t scopeValue;
- (int16_t)scopeValue;
- (void)setScopeValue:(int16_t)value_;

//- (BOOL)validateScope:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMDefinition *definition;

//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@end

@interface _WMDefinitionKeyword (CoreDataGeneratedAccessors)

@end

@interface _WMDefinitionKeyword (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveKeyword;
- (void)setPrimitiveKeyword:(NSString*)value;




- (NSNumber*)primitiveScope;
- (void)setPrimitiveScope:(NSNumber*)value;

- (int16_t)primitiveScopeValue;
- (void)setPrimitiveScopeValue:(int16_t)value_;





- (WMDefinition*)primitiveDefinition;
- (void)setPrimitiveDefinition:(WMDefinition*)value;


@end
