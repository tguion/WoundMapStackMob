#import "WMIAPTransaction.h"
#import "WMUtilities.h"

typedef enum {
    WMIAPTransactionFlagsKVSTransmitted = 0,
} WMIAPTransactionFlags;

@interface WMIAPTransaction ()

// Private interface goes here.

@end


@implementation WMIAPTransaction

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               credits:(NSNumber *)credits
{
	return [WMIAPTransaction instanceWithManagedObjectContext:managedObjectContext credits:credits startupCredits:NO];
}


+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               credits:(NSNumber *)credits
                        startupCredits:(BOOL)startupCredits
{
    WMIAPTransaction *iapTransaction = nil;
    if (nil != managedObjectContext) {
        iapTransaction = [WMIAPTransaction MR_createInContext:managedObjectContext];
        [iapTransaction setTxnId:[[NSUUID UUID] UUIDString]];
        [iapTransaction setCredits:credits];
        [iapTransaction setFlags:[NSNumber numberWithInteger:0]];
        [iapTransaction setStartupCredits:[NSNumber numberWithBool:startupCredits]];
        [iapTransaction setTxnDate:[NSDate date]];
    }
	return iapTransaction;
}

+ (NSNumber *)sumTokens:(NSManagedObjectContext *)managedObjectContext
{
    NSNumber *resultValue = nil;
    
    NSExpression *ex = [NSExpression expressionForFunction:@"sum:"
                                                 arguments:@[[NSExpression expressionForKeyPath:@"credits"]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSInteger64AttributeType];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[WMIAPTransaction entityName]];
    
    [request setPropertiesToFetch:@[ed]];
    [request setResultType:NSDictionaryResultType];
    
    if (nil != managedObjectContext) {
        NSDictionary *resultsDictionary = (NSDictionary *)[WMIAPTransaction MR_executeFetchRequestAndReturnFirstObject:request
                                                                                                             inContext:managedObjectContext];
        resultValue = resultsDictionary[@"result"];
    }
    //    DLog(@"sumTokens has resultValue: %i", [resultValue integerValue]);
    return resultValue;
    
}

+(NSDate *)lastPurchasedCreditDate:(NSManagedObjectContext *)managedObjectContext
{
    NSDate *lastPurchasedDate = nil;
    
    NSExpression *ex = [NSExpression expressionForFunction:@"max:"
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"txnDate"]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSDateAttributeType];
    
    NSArray *properties = [NSArray arrayWithObject:ed];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setPropertiesToFetch:properties];
    [request setResultType:NSDictionaryResultType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"startupCredits == 0 && credits > 0"]];
    
    if (nil != managedObjectContext) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
        NSDictionary *resultsDictionary = [results objectAtIndex:0];
        lastPurchasedDate = [resultsDictionary objectForKey:@"result"];
    }
    return lastPurchasedDate;
    
}

+(BOOL) hasStartupCredits:(NSManagedObjectContext *)managedObjectContext
{
    return [WMIAPTransaction MR_countOfEntitiesWithContext:managedObjectContext] > 0;
}

+(WMIAPTransaction *) startupCredits:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"startupCredits != 0"]];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    WMIAPTransaction *transaction = [array lastObject];
    return transaction;
}

+(NSUInteger)transactionCount:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
    
}


+ (WMIAPTransaction *)transactionWithId:(NSString *)txnId managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMIAPTransaction *transaction = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"txnId == %@", txnId]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    transaction = [array lastObject];
    return transaction;
}

+ (NSArray *)creditTransactionsNotTransmitted:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"flags == 0"]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    return array;
}

+ (NSArray *)enumerateTransactions:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    return array;
}

//[WMIAPTransaction deleteTxnWithTxnId:[alreadyRecordedStartupCredits txnId]];
+ (void)deleteTransaction:(NSManagedObjectContext *)managedObjectContext transaction:(WMIAPTransaction *) transaction
{
    [managedObjectContext deleteObject:transaction];
}

+ (void)deleteAllTxns:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[WMIAPTransaction entityName] inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    //    DLog(@"about to delete %i WCIAPTransactions", [array count]);
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [managedObjectContext deleteObject:obj];
    }];
    [managedObjectContext save:&error];
}


- (BOOL)hasBeenKeyValueStoreTransmitted
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMIAPTransactionFlagsKVSTransmitted];
}

- (void)setKeyValueStoreTransmittedFlag:(BOOL)kvsTransmittedFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMIAPTransactionFlagsKVSTransmitted to:kvsTransmittedFlag]);
}

//- (BOOL) isStartupCreditTransaction
//{
////    return [WCUtilities isBitSetForValue:[self.flags intValue] atPosition:WCIAPTransactionStartupCreditsPeriCloudAccount];
//    return [WMIAPTransaction isStartupCreditTransaction:self.flags];
//}
//
//+ (BOOL) isStartupCreditTransaction:(NSNumber *)flags
//{
//    return [WCUtilities isBitSetForValue:[flags intValue] atPosition:WCIAPTransactionStartupCreditsPeriCloudAccount];
//}
//
//- (void)setStartupCreditTransaction:(BOOL)startupCreditsFlag
//{
//    self.flags = [NSNumber numberWithInt:[WCUtilities updateBitForValue:[self.flags intValue] atPosition:WCIAPTransactionStartupCreditsPeriCloudAccount to:startupCreditsFlag]];
//}

//- (void)encodeWithCoder:(NSCoder *)coder {
//    [coder encodeObject:[self txnId] forKey:@"txnId"];
//    [coder encodeObject:[self credits] forKey:@"credits"];
//    [coder encodeObject:[self flags] forKey:@"flags"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder {
//    self = [super init];
//    if (self) {
//        [self setTxnId:[coder decodeObjectForKey:@"txnId"]];
//        [self setCredits:[coder decodeObjectForKey:@"credits"]];
//        [self setFlags:[coder decodeObjectForKey:@"flags"]];
//    }
//    return self;
//}

@end
