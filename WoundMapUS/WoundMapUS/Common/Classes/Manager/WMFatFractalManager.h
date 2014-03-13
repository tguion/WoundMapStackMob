//
//  WMFatFractalManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMFatFractalManager : NSObject

+ (WMFatFractalManager *)sharedInstance;

- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext;

@end
