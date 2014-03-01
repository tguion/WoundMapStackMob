// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMPsychoSocialInterventionEventAttributes {
	__unsafe_unretained NSString *wmpsychosocialinterventionevent_id;
} WMPsychoSocialInterventionEventAttributes;

extern const struct WMPsychoSocialInterventionEventRelationships {
	__unsafe_unretained NSString *group;
} WMPsychoSocialInterventionEventRelationships;

extern const struct WMPsychoSocialInterventionEventFetchedProperties {
} WMPsychoSocialInterventionEventFetchedProperties;

@class WMPsychoSocialGroup;



@interface WMPsychoSocialInterventionEventID : NSManagedObjectID {}
@end

@interface _WMPsychoSocialInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPsychoSocialInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmpsychosocialinterventionevent_id;



//- (BOOL)validateWmpsychosocialinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPsychoSocialGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPsychoSocialInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMPsychoSocialInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmpsychosocialinterventionevent_id;
- (void)setPrimitiveWmpsychosocialinterventionevent_id:(NSString*)value;





- (WMPsychoSocialGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMPsychoSocialGroup*)value;


@end
