//
//  Faulter.m
//  Grocery Cloud
//
//  Created by Tim Roadley on 23/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "Faulter.h"
@implementation Faulter

+ (void)faultObjectWithIDs:(NSArray *)objectIDs
                 inContext:(NSManagedObjectContext *)context
{
    for (NSManagedObjectID *objectID in objectIDs) {
        [self faultObjectWithID:objectID inContext:context];
    }
}

+ (void)faultObjectWithID:(NSManagedObjectID*)objectID
                inContext:(NSManagedObjectContext*)context
{
    if (!objectID || !context) {
        return;
    }
    // else
    [context performBlockAndWait:^{
        NSManagedObject *object = [context objectWithID:objectID];
        if (object.hasChanges) {
            NSLog(@"Skipped faulting an object that because it has changes");
        }
        if (!object.isFault) {
            NSLog(@"Faulting object %@ in context %@", object.objectID, context);
            [context refreshObject:object mergeChanges:NO];
        } else {
            NSLog(@"Skipped faulting an object that is already a fault");
        }
        // Repeat the process if the context has a parent
        if (context.parentContext) {
            [self faultObjectWithID:objectID inContext:context.parentContext];
        }
    }];
}
@end
