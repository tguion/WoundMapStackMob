// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMWoundMeasurementInterventionEventAttributes {
} WMWoundMeasurementInterventionEventAttributes;

extern const struct WMWoundMeasurementInterventionEventRelationships {
	__unsafe_unretained NSString *measurementGroup;
} WMWoundMeasurementInterventionEventRelationships;

extern const struct WMWoundMeasurementInterventionEventFetchedProperties {
} WMWoundMeasurementInterventionEventFetchedProperties;

@class WMWoundMeasurementGroup;


@interface WMWoundMeasurementInterventionEventID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementInterventionEventID*)objectID;





@property (nonatomic, strong) WMWoundMeasurementGroup *measurementGroup;

//- (BOOL)validateMeasurementGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundMeasurementInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementInterventionEvent (CoreDataGeneratedPrimitiveAccessors)



- (WMWoundMeasurementGroup*)primitiveMeasurementGroup;
- (void)setPrimitiveMeasurementGroup:(WMWoundMeasurementGroup*)value;


@end
