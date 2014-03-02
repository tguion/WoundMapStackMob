// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicationInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMMedicationInterventionEventAttributes {
	__unsafe_unretained NSString *wmmedicationinterventionevent_id;
} WMMedicationInterventionEventAttributes;

extern const struct WMMedicationInterventionEventRelationships {
	__unsafe_unretained NSString *medicationGroup;
} WMMedicationInterventionEventRelationships;

extern const struct WMMedicationInterventionEventFetchedProperties {
} WMMedicationInterventionEventFetchedProperties;

@class WMMedicationGroup;



@interface WMMedicationInterventionEventID : NSManagedObjectID {}
@end

@interface _WMMedicationInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMMedicationInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmmedicationinterventionevent_id;



//- (BOOL)validateWmmedicationinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMMedicationGroup *medicationGroup;

//- (BOOL)validateMedicationGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMMedicationInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMMedicationInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmmedicationinterventionevent_id;
- (void)setPrimitiveWmmedicationinterventionevent_id:(NSString*)value;





- (WMMedicationGroup*)primitiveMedicationGroup;
- (void)setPrimitiveMedicationGroup:(WMMedicationGroup*)value;


@end
