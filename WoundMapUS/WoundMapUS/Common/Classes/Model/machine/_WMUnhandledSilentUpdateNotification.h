// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMUnhandledSilentUpdateNotification.h instead.

#import <CoreData/CoreData.h>


extern const struct WMUnhandledSilentUpdateNotificationAttributes {
	__unsafe_unretained NSString *notification;
	__unsafe_unretained NSString *userNamme;
} WMUnhandledSilentUpdateNotificationAttributes;

extern const struct WMUnhandledSilentUpdateNotificationRelationships {
} WMUnhandledSilentUpdateNotificationRelationships;

extern const struct WMUnhandledSilentUpdateNotificationFetchedProperties {
} WMUnhandledSilentUpdateNotificationFetchedProperties;


@class NSObject;


@interface WMUnhandledSilentUpdateNotificationID : NSManagedObjectID {}
@end

@interface _WMUnhandledSilentUpdateNotification : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMUnhandledSilentUpdateNotificationID*)objectID;





@property (nonatomic, strong) id notification;



//- (BOOL)validateNotification:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userNamme;



//- (BOOL)validateUserNamme:(id*)value_ error:(NSError**)error_;






@end

@interface _WMUnhandledSilentUpdateNotification (CoreDataGeneratedAccessors)

@end

@interface _WMUnhandledSilentUpdateNotification (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveNotification;
- (void)setPrimitiveNotification:(id)value;




- (NSString*)primitiveUserNamme;
- (void)setPrimitiveUserNamme:(NSString*)value;




@end
