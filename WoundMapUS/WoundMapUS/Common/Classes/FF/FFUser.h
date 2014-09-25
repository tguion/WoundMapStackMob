//
//  FFUser.h
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//
/*! \brief The abstract parent of all FFUser objects.. */
/*! The FFUser class is automatically generated for all FF noserver applications*/

#import <Foundation/Foundation.h>
/*! The abstract parent of all FFUser objects.. */

@interface FFUser : NSObject

/*! An NSMutableArry with the string representation of deviceTokens that allow Apple push notifications to the device. */
@property (strong, nonatomic) NSMutableArray    *deviceTokens;
@property (strong, nonatomic) NSMutableArray    *userGroups;
@property (strong, nonatomic) NSString          *userName;
@property (strong, nonatomic) NSString          *firstName;
@property (strong, nonatomic) NSString          *lastName;
@property (strong, nonatomic) NSString          *email;
@end
