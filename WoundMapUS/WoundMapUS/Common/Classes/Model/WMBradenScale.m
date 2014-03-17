#import "WMBradenScale.h"
#import "WMPatient.h"
#import "WMBradenSection.h"
#import "WMBradenCell.h"
#import "WMUtilities.h"

NSString * const kBradenScaleTitle = @"Braden Scale";
NSInteger const kBradenSectionCount = 6;

@interface WMBradenScale ()

// Private interface goes here.

@end


@implementation WMBradenScale

+ (WMBradenScale *)createNewBradenScaleForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMBradenScale *bradenScale = [WMBradenScale MR_createInContext:managedObjectContext];
    bradenScale.patient = patient;
    return bradenScale;
}

+ (WMBradenScale *)latestBradenScale:(WMPatient *)patient create:(BOOL)create
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMBradenScale *bradenScale = [WMBradenScale MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                                 sortedBy:@"createdAt"
                                                                ascending:NO
                                                                inContext:managedObjectContext];
    if (create && nil == bradenScale) {
        bradenScale = [WMBradenScale MR_createInContext:managedObjectContext];
    }
	return bradenScale;
}

+ (WMBradenScale *)latestCompleteBradenScale:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSArray *array = [WMBradenScale MR_findAllSortedBy:@"createdAt"
                                             ascending:NO
                                         withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                             inContext:managedObjectContext];
    for (WMBradenScale *bradenScale in array) {
        if (bradenScale.isScored) {
            return bradenScale;
        }
        // else continue
    }
    return nil;
}

+ (NSDate *)lastCompleteBradenScaleDataModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMBradenScale"];
    request.predicate = [NSPredicate predicateWithFormat:@"patient == %@ AND completeFlag == YES", patient];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *dates = (NSDictionary *)[WMBradenScale MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    if ([dates count] == 0)
        return nil;
    // else
    return dates[@"updatedAt"];
}

+ (NSArray *)sortedScoredBradenScales:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    // first delete
    [self deleteIncompleteClosedBradenScales:patient];
    // now fetch
    return [WMBradenScale MR_findAllSortedBy:@"createdAt"
                                   ascending:YES
                               withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                   inContext:managedObjectContext];
}

+ (NSInteger)closeBradenScalesCreatedBefore:(NSDate *)date
                                    patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSArray *array = [WMBradenScale MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date]
                                                  inContext:managedObjectContext];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (void)deleteIncompleteClosedBradenScales:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSArray *array = [WMBradenScale MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:managedObjectContext];
    for (WMBradenScale *bradenScale in array) {
        if (bradenScale.isClosed && !bradenScale.isScored) {
            [managedObjectContext deleteObject:bradenScale];
        }
    }
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	self.createdAt = [NSDate date];
	self.updatedAt = [NSDate date];
}

- (NSString *)scoreMessage
{
    NSInteger score = [self.score intValue];
    NSString *message = nil;
    if (score <= 12) {
        message = @"High risk of developing pressure ulsers";
    } else if (score <= 14) {
        message = @"Moderate risk of developing pressure ulsers";
    } else if (score <= 16) {
        message = @"Low risk of developing pressure ulsers";
    } else {
        message = @"Minimum risk of developing pressure ulsers";
    }
    return message;
}

- (BOOL)isScored
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isScored == YES"];
    NSArray *array = [[self.sections allObjects] filteredArrayUsingPredicate:predicate];
    return [array count] == [self.sections count];
}

- (BOOL)isScoredCalculated
{
    NSInteger count = [WMBradenCell MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"section.bradenScale == %@ AND selectedFlag == YES", self]
                                                          inContext:[self managedObjectContext]];
    return (count == kBradenSectionCount);
}

- (void)updateScoreFromSections
{
    NSInteger score = 0;
    NSSet *sections = self.sections;
    for (WMBradenSection *bradenSection in sections) {
        score += [bradenSection.selectedCell.value intValue];
    }
    self.scoreValue = score;
    self.completeFlag = @(self.isScoredCalculated);
}

- (NSArray *)sortedSections
{
	return [[self.sections allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:NO]]];
}

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

- (void)populateSections
{
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"BradenScale" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"BradenScale.plist not found");
		return;
	}
	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:fileURL];
	id propertyList = [NSPropertyListSerialization propertyListWithData:data
																options:NSPropertyListImmutable
																 format:NULL
																  error:&error];
	NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
    @autoreleasepool {
        for (NSDictionary *dictionary in propertyList) {
            WMBradenSection *bradenSection = [WMBradenSection instanceWithBradenScale:self
                                                                 managedObjectContext:[self managedObjectContext]
                                                                      persistentStore:nil];
            bradenSection.sortRank = [dictionary objectForKey:@"sortRank"];
            bradenSection.bradenScale = self;
            bradenSection.title = [dictionary objectForKey:@"title"];
            bradenSection.desc = [dictionary objectForKey:@"desc"];
            id object = [dictionary objectForKey:@"cells"];
            if ([object isKindOfClass:[NSArray class]]) {
                for (NSDictionary *d in object) {
                    WMBradenCell *bradenCell = [WMBradenCell instanceWithBradenSection:bradenSection
                                                                  managedObjectContext:[self managedObjectContext]];
                    bradenCell.title = [d objectForKey:@"title"];
                    bradenCell.primaryDescription = [d objectForKey:@"primaryDescription"];
                    id obj = [d objectForKey:@"secondaryDescription"];
                    if ([obj isKindOfClass:[NSString class]]) {
                        bradenCell.secondaryDescription = obj;
                    }
                    bradenCell.value = [d objectForKey:@"value"];
                }
            }
        }
    }
}

@end
