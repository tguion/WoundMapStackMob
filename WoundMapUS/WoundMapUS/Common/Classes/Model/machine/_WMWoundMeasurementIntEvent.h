// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementIntEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMWoundMeasurementIntEventAttributes {
	__unsafe_unretained NSString *wmwoundmeasurementinterventionevent_id;
} WMWoundMeasurementIntEventAttributes;

extern const struct WMWoundMeasurementIntEventRelationships {
	__unsafe_unretained NSString *measurementGroup;
} WMWoundMeasurementIntEventRelationships;

extern const struct WMWoundMeasurementIntEventFetchedProperties {
} WMWoundMeasurementIntEventFetchedProperties;

@class WMWoundMeasurementGroup;



@interface WMWoundMeasurementIntEventID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementIntEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementIntEventID*)objectID;





@property (nonatomic, strong) NSString* wmwoundmeasurementinterventionevent_id;



//- (BOOL)validateWmwoundmeasurementinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundMeasurementGroup *measurementGroup;

//- (BOOL)validateMeasurementGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundMeasurementIntEvent (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementIntEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmwoundmeasurementinterventionevent_id;
- (void)setPrimitiveWmwoundmeasurementinterventionevent_id:(NSString*)value;





- (WMWoundMeasurementGroup*)primitiveMeasurementGroup;
- (void)setPrimitiveMeasurementGroup:(WMWoundMeasurementGroup*)value;


@end
