//
//  FFUserGroup.h
//  FatFractal
//
//  Copyright (c) 2012, 2013 FatFractal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FFUserProtocol;
@class FatFractal;

/*! \brief A special kind of FatFractal object for managing user groups in your application. */
/*! 
 This is the special class for managing user groups in the FatFractal Emergent Framework.
 */ 
@interface FFUserGroup : NSObject <NSCoding> {
    BOOL                 _usersLoaded;
    NSMutableDictionary *_usersDict;
    FatFractal          *ff;
}

/*!
 Standard initializer. No-args initializer calls this initializer with [FatFractal main] as parameter.
 */
- (id)initWithFF:(FatFractal *)_ff;

/*! An NSString with the unique identifier for this FFUserGroup */
@property (strong, nonatomic) NSString          *guid;

/*!
 The name of this group.
 @see FFUser::groupWithName:
 */
@property (strong, nonatomic) NSString *groupName;

/*!
 Add a user to this group's list of users
 @param id<FFUserProtocol> - the user to be added
 @param NSError - will be set to non-nil if an error occurs
 */
- (void) addUser:(id<FFUserProtocol>)user error:(NSError **)outErr;

/*!
 Remove a user from this group's list of users
 @param id<FFUserProtocol> - the user to be removed
 @param NSError - will be set to non-nil if an error occurs
 */
- (void) removeUser:(id<FFUserProtocol>)user error:(NSError **)outErr;

/*!
 Find a specific user in this group's list of users
 @param NSString - the user name
 @param NSError - will be set to non-nil if an error occurs
 @return id<FFUserProtocol> - the user, if found, or nil otherwise
 */
- (id<FFUserProtocol>) userWithName:(NSString *)userName error:(NSError **)outErr;

/*!
 Get all of this group's users.
 @return NSArray - the array of users
 @param NSError - will be set to non-nil if an error occurs
 */
- (NSArray *) getUsersWithError:(NSError **)outErr;

/*!
 Set the FatFractal instance to be associated with this object.
 NOTE: This method is intended to be used after de-archiving via initWithCoder. As such, it will only have an effect when no FatFractal instance has been set.
 */
- (BOOL)setFF:(FatFractal *)ff;

@end
