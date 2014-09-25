//
//  FFUser.m
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//

#import "FFUser.h"

@implementation FFUser

@synthesize deviceTokens, userName, firstName, lastName, email, userGroups;

- (id)init {
    self = [super init];
    if (self) {
        deviceTokens = [[NSMutableArray alloc] init];
        userGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString*) description {
    return [[NSString alloc]
            initWithFormat:@"FFUser[userName[%@],firstName[%@],lastName[%@],email[%@],deviceTokens[%@],userGroups[%@]]",
            userName, firstName, lastName, email, deviceTokens, userGroups];
}

@end
