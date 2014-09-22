//
//  WMFFManagedObject.h
//  WoundMapUS
//
//  Created by Todd Guion on 9/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WMFFManagedObject <NSObject>

@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSString* ffUrl;
@property (nonatomic, strong) NSDate* updatedAt;

@end
