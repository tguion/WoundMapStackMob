//
//  FFMetaData.h
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//
/*! \brief FFMetaData useful data about your data. */
/*! 
 FFMetaData contains essential information about your object that is stored on the FF noserver.
 This can be accessed via FatFractal::metaDataForObj:
 */

#import <Foundation/Foundation.h>

@interface FFMetaData: NSObject

/*! An NSString that contains the url (relative to the application base url) of this object*/
@property (strong, nonatomic) NSString          *ffUrl;
/*! An NSString that contains the FatFractal "type" of this object. Value is either FFO (object) or FFC (collection) */
@property (strong, nonatomic) NSString          *ffType;
/*! An NSString that contains the guid of this object
 Guids are unique within a given resource domain
 FatFractal URLs look like this: http://host/yourAppName/ff/resources/SomeRootResource/resourceGuid
 */
@property (strong, nonatomic) NSString          *guid;
/*! The object's version. Objects are created with version 1, version increments on every update */
@property (strong, nonatomic) NSNumber          *objVersion;
/*! An NSString that contains guid of the FFUSer that created the object. */
@property (strong, nonatomic) NSString          *createdBy;
/*! An NSDate with the date/time stamp when the object was created as set by the FF noserver. */
@property (strong, nonatomic) NSDate            *createdAt;
/*! An NSString that contains the guid of the FFUSer that updated the object. */
@property (strong, nonatomic) NSString          *updatedBy;
/*! An NSDate with the date/time stamp when the object was last updated as set by the FF noserver. */
@property (strong, nonatomic) NSDate            *updatedAt;

@end
