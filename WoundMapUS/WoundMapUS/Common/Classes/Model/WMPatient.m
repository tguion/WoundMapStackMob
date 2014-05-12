#import "WMPatient.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMMedicalHistoryGroup.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMId.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPatientReferral.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"

NSString * const kConsultantGroupName = @"consultantGroup";

typedef enum {
    PatientFlagsFaceDetectionFailed         = 0,
    PatientFlagsFacePhotoTaken              = 1,
} PatientFlags;

@interface WMPatient ()

// Private interface goes here.

@end


@implementation WMPatient

@synthesize consultantGroup=_consultantGroup;
@dynamic managedObjectContext, objectID;

+ (NSArray *)toManyRelationshipNames
{
    return @[WMPatientRelationships.bradenScales,
             WMPatientRelationships.carePlanGroups,
             WMPatientRelationships.deviceGroups,
             WMPatientRelationships.ids,
             WMPatientRelationships.medicationGroups,
             WMPatientRelationships.patientConsultants,
             WMPatientRelationships.psychosocialGroups,
             WMPatientRelationships.skinAssessmentGroups,
             WMPatientRelationships.wounds];
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext onDevice:(NSString *)deviceId
{
    return [WMPatient MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMPatientAttributes.createdOnDeviceId, deviceId] inContext:managedObjectContext];
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

- (FFUserGroup *)consultantGroup
{
    if (nil == _consultantGroup) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        _consultantGroup = [[FFUserGroup alloc] initWithFF:ff];
        [_consultantGroup setGroupName:kConsultantGroupName];
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
        [array addObject:[[[self.ids valueForKeyPath:@"extension"] allObjects] componentsJoinedByString:@","]];
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

- (NSString *)identifierEMR
{
    return [[[self valueForKeyPath:@"ids.extension"] allObjects] componentsJoinedByString:@","];
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

- (UIImage *)thumbnailImage
{
    if (nil != self.thumbnail) {
        return self.thumbnail;
    }
    // else
    return [WMPatient missingThumbnailImage];
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

- (WMMedicalHistoryGroup *)lastActiveMedicalHistoryGroup
{
    return [WMMedicalHistoryGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", self]
                                                   sortedBy:WMMedicalHistoryGroupAttributes.updatedAt
                                                  ascending:NO
                                                  inContext:[self managedObjectContext]];
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

- (BOOL)facePhotoTaken
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:PatientFlagsFacePhotoTaken];
}

- (void)setFacePhotoTaken:(BOOL)facePhotoTaken
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:PatientFlagsFacePhotoTaken to:facePhotoTaken]);
}

- (BOOL)dayOrMoreSinceCreated
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    return [[NSDate date] compare:[calendar dateByAddingComponents:components toDate:self.createdAt options:0]] == NSOrderedDescending;
}

- (BOOL)hasPatientDetails
{
    return ([self.person.addresses count] || [self.person.telecoms count] || [self.medicalHistoryGroups count] || self.surgicalHistory || self.relevantMedications);
}

- (WMPatientReferral *)patientReferralForReferree:(WMParticipant *)referee
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    return [WMPatientReferral MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND %K = nil", WMPatientReferralRelationships.patient, self, WMPatientReferralRelationships.referree, referee, WMPatientReferralAttributes.dateAccepted]
                                               sortedBy:WMPatientReferralAttributes.createdAt
                                              ascending:NO
                                              inContext:managedObjectContext];
}

- (BOOL)updateNavigationToTeam:(WMTeam *)team
{
    NSParameterAssert(team);
    NSParameterAssert(self.stage);
    if (nil == self.stage.track.team) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        WMNavigationTrack *track = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"team == %@ AND title == %@", team, self.stage.track.title] inContext:managedObjectContext];
        NSParameterAssert(track);
        WMNavigationStage *stage = [WMNavigationStage MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"track == %@ AND title == %@", track, self.stage.title] inContext:managedObjectContext];
        NSParameterAssert(stage);
        self.stage = stage;
        self.team = team;
        return YES;
    }
    // else
    return NO;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"acquiredByConsultantValue",
                                                            @"archivedFlagValue",
                                                            @"flagsValue",
                                                            @"thumbnail",
                                                            @"managedObjectContext",
                                                            @"objectID",
                                                            @"thumbnailImage",
                                                            @"lastNameFirstName",
                                                            @"lastNameFirstNameOrAnonymous",
                                                            @"identifierEMR",
                                                            @"facePhotoTaken",
                                                            @"faceDetectionFailed",
                                                            @"genderIndex",
                                                            @"lastActiveWound",
                                                            @"hasMultipleWounds",
                                                            @"sortedWounds",
                                                            @"woundCount",
                                                            @"photosCount",
                                                            @"dayOrMoreSinceCreated",
                                                            @"lastActiveMedicalHistoryGroup",
                                                            @"hasPatientDetails"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPatient attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPatient relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPatient relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
