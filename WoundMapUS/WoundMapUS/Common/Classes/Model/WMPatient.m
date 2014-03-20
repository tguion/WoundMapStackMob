#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMId.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

typedef enum {
    PatientFlagsFaceDetectionFailed         = 0,
    
} PatientFlags;

@interface WMPatient ()

// Private interface goes here.

@end


@implementation WMPatient

@synthesize participantGroup=_participantGroup, consultantGroup=_consultantGroup;
@dynamic managedObjectContext, objectID;

+ (NSArray *)toManyRelationshipNames
{
    return @[WMPatientRelationships.bradenScales, WMPatientRelationships.carePlanGroups, WMPatientRelationships.deviceGroups, WMPatientRelationships.ids, WMPatientRelationships.medicationGroups, WMPatientRelationships.patientConsultants, WMPatientRelationships.psychosocialGroups, WMPatientRelationships.skinAssessmentGroups, WMPatientRelationships.wounds];
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl] inContext:managedObjectContext];
}

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"archivedFlag == NO"]
                                       sortedBy:@"updatedAt"
                                      ascending:NO
                                      inContext:managedObjectContext];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

/**
 Call this method when a patient is created
 */
- (void)updateParticipantGroupWithParticipants:(NSArray *)participants
{
    FFUserGroup *participantGroup = self.participantGroup;
    NSError *error = nil;
    NSMutableArray *currentParticipants = [[participantGroup getUsersWithError:&error] mutableCopy];
    for (id<FFUserProtocol>participant in participants) {
        if (![currentParticipants containsObject:participant]) {
            [participantGroup addUser:participant error:&error];
            if (error) {
                [WMUtilities logError:error];
            }
            [currentParticipants removeObjectIdenticalTo:participant];
        }
    }
    // remove remaining users
    for (id<FFUserProtocol>participant in currentParticipants) {
        [participantGroup removeUser:participant error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
}

- (void)addParticipant:(id<FFUserProtocol>)participant
{
    NSError *error = nil;
    [self.participantGroup addUser:participant error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (void)addConsultant:(id<FFUserProtocol>)consultant
{
    NSError *error = nil;
    [self.consultantGroup addUser:consultant error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (void)removeParticipant:(id<FFUserProtocol>)participant
{
    NSError *error = nil;
    [self.participantGroup removeUser:participant error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (void)removeConsultant:(id<FFUserProtocol>)consultant
{
    NSError *error = nil;
    [self.consultantGroup removeUser:consultant error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (FFUserGroup *)participantGroup
{
    if (nil == _participantGroup) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        _participantGroup = [[FFUserGroup alloc] initWithFF:ff];
    }
    return _participantGroup;
}

- (FFUserGroup *)consultantGroup
{
    if (nil == _consultantGroup) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        _consultantGroup = [[FFUserGroup alloc] initWithFF:ff];
    }
    return _consultantGroup;
}

- (NSString *)lastNameFirstName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0 && [self.ids count] > 0) {
        [array addObject:[[self.ids valueForKeyPath:@"extension"] componentsJoinedByString:@","]];
    }
    if ([array count] == 0) {
        [array addObject:@"New Patient"];
    }
    return [array componentsJoinedByString:@", "];
}

- (NSString *)lastNameFirstNameOrAnonymous
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0) {
        [array addObject:@"Anonymous"];
    }
    return [array componentsJoinedByString:@", "];
}

- (NSInteger)genderIndex
{
    NSInteger genderIndex = UISegmentedControlNoSegment;
    if ([@"M" isEqualToString:self.gender]) {
        genderIndex = 0;
    } else if ([@"F" isEqualToString:self.gender]) {
        genderIndex = 1;
    } else if ([@"U" isEqualToString:self.gender]) {
        genderIndex = 2;
    }
    return genderIndex;
}

+ (UIImage *)missingThumbnailImage
{
    NSString *avitarFileName = @"user_";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPad"];
    } else {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPhone"];
    }
    return [UIImage imageNamed:avitarFileName];
}

- (WMWound *)lastActiveWound
{
    return [self.sortedWounds firstObject];
}

- (NSArray *)sortedWounds
{
    return [[self.wounds allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

- (NSInteger)woundCount
{
    return [WMWound MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", self] inContext:[self managedObjectContext]];
}

- (BOOL)hasMultipleWounds
{
    return [self.wounds count] > 1;
}

- (NSInteger)photosCount
{
    return [WMWoundPhoto MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound.patient == %@", self] inContext:[self managedObjectContext]];
}

- (BOOL)faceDetectionFailed
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:PatientFlagsFaceDetectionFailed];
}

- (void)setFaceDetectionFailed:(BOOL)faceDetectionFailed
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:PatientFlagsFaceDetectionFailed to:faceDetectionFailed]);
}

- (BOOL)dayOrMoreSinceCreated
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    return [[NSDate date] compare:[calendar dateByAddingComponents:components toDate:self.createdAt options:0]] == NSOrderedDescending;
}

@end
