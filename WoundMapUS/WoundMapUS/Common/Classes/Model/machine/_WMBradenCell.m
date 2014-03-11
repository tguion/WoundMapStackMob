// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenCell.m instead.

#import "_WMBradenCell.h"

const struct WMBradenCellAttributes WMBradenCellAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.primaryDescription = @"primaryDescription",
	.secondaryDescription = @"secondaryDescription",
	.selectedFlag = @"selectedFlag",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct WMBradenCellRelationships WMBradenCellRelationships = {
	.section = @"section",
};

const struct WMBradenCellFetchedProperties WMBradenCellFetchedProperties = {
};

@implementation WMBradenCellID
@end

@implementation _WMBradenCell

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMBradenCell" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMBradenCell";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMBradenCell" inManagedObjectContext:moc_];
}

- (WMBradenCellID*)objectID {
	return (WMBradenCellID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"selectedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"selectedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"valueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"value"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic ffUrl;






@dynamic primaryDescription;






@dynamic secondaryDescription;






@dynamic selectedFlag;



- (BOOL)selectedFlagValue {
	NSNumber *result = [self selectedFlag];
	return [result boolValue];
}

- (void)setSelectedFlagValue:(BOOL)value_ {
	[self setSelectedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSelectedFlagValue {
	NSNumber *result = [self primitiveSelectedFlag];
	return [result boolValue];
}

- (void)setPrimitiveSelectedFlagValue:(BOOL)value_ {
	[self setPrimitiveSelectedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic updatedAt;






@dynamic value;



- (int16_t)valueValue {
	NSNumber *result = [self value];
	return [result shortValue];
}

- (void)setValueValue:(int16_t)value_ {
	[self setValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveValueValue {
	NSNumber *result = [self primitiveValue];
	return [result shortValue];
}

- (void)setPrimitiveValueValue:(int16_t)value_ {
	[self setPrimitiveValue:[NSNumber numberWithShort:value_]];
}





@dynamic section;

	






@end
