// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialIntEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMPsychoSocialIntEventAttributes {
	__unsafe_unretained NSString *wmpsychosocialinterventionevent_id;
} WMPsychoSocialIntEventAttributes;

extern const struct WMPsychoSocialIntEventRelationships {
	__unsafe_unretained NSString *group;
} WMPsychoSocialIntEventRelationships;

extern const struct WMPsychoSocialIntEventFetchedProperties {
} WMPsychoSocialIntEventFetchedProperties;

@class WMPsychoSocialGroup;



@interface WMPsychoSocialIntEventID : NSManagedObjectID {}
@end

@interface _WMPsychoSocialIntEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPsychoSocialIntEventID*)objectID;





@property (nonatomic, strong) NSString* wmpsychosocialinterventionevent_id;



//- (BOOL)validateWmpsychosocialinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPsychoSocialGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPsychoSocialIntEvent (CoreDataGeneratedAccessors)

@end

@interface _WMPsychoSocialIntEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmpsychosocialinterventionevent_id;
- (void)setPrimitiveWmpsychosocialinterventionevent_id:(NSString*)value;





- (WMPsychoSocialGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(WMPsychoSocialGroup*)value;


@end
