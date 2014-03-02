// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMWoundTreatmentInterventionEventAttributes {
	__unsafe_unretained NSString *wmwoundtreatmentinterventionevent_id;
} WMWoundTreatmentInterventionEventAttributes;

extern const struct WMWoundTreatmentInterventionEventRelationships {
	__unsafe_unretained NSString *treatmentGroup;
} WMWoundTreatmentInterventionEventRelationships;

extern const struct WMWoundTreatmentInterventionEventFetchedProperties {
} WMWoundTreatmentInterventionEventFetchedProperties;

@class WMWoundTreatmentGroup;



@interface WMWoundTreatmentInterventionEventID : NSManagedObjectID {}
@end

@interface _WMWoundTreatmentInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundTreatmentInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmwoundtreatmentinterventionevent_id;



//- (BOOL)validateWmwoundtreatmentinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundTreatmentGroup *treatmentGroup;

//- (BOOL)validateTreatmentGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundTreatmentInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMWoundTreatmentInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmwoundtreatmentinterventionevent_id;
- (void)setPrimitiveWmwoundtreatmentinterventionevent_id:(NSString*)value;





- (WMWoundTreatmentGroup*)primitiveTreatmentGroup;
- (void)setPrimitiveTreatmentGroup:(WMWoundTreatmentGroup*)value;


@end
