//
//  Faulter.h
//  Grocery Cloud
//
//  Created by Tim Roadley on 23/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Faulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID*)objectID
                inContext:(NSManagedObjectContext*)context;

@end
