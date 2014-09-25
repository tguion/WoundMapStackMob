//
//  FatFractal.h
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//

/*! \brief FatFractal helper class. */
/*! 
 The FatFractal class provides a set of helpful methods which make it a breeze to construct JSON representations
 and transmit them to and from the FatFractal noserver using the uniform HTTP interface.
 */
#import <Foundation/Foundation.h>
#import "FFMetaData.h"
#import "FFHttpDelegate.h"
#import "FFUser.h"

@interface FatFractal : NSObject
{
    NSMutableDictionary     *references;
    /*! 
     The #deviceTokenHexString property (NSString) is the string representation of the device 
     tokens that are used by the Apple push notification service. 
     */
    NSString                *deviceTokenHexString;
}

#pragma mark Properties

/*!
 The #baseUrl property (NSString) of the FatFractal helper class allows the developer to 
 change the target host and application name without having to change all of the CRUD, query, 
 server extension and event methods. For example, you could set baseUrl to something 
 like: http://localhost/hoodyoodoo 
 */
@property (strong, nonatomic)   NSString              *baseUrl;
/*!
 The #sslUrl is the SSL equivalent of the baseUrl.
 If not set explicitly by the application, will default to copying baseUrl and replacing http: with https:
 Needed so that you can test with non-standard SSL ports
 */
@property (strong, nonatomic)   NSString              *sslUrl;

/*! 
 The #loggedIn property is a Boolean representation of loggedIn status which is set 
 by the FatFractal::loginWithUserName:andPassword:error: method. The default value is set to false. 
 */
@property (nonatomic)           BOOL                   loggedIn;

/*! 
 The #loggedInUserGuid property (NSString) is the userGuid of the FFUser that is logged 
 in. It is set by the login:withUserName:andPassword method on successful login.
 */
@property (strong, nonatomic)   NSString              *loggedInUserGuid;

@property (strong, nonatomic)   FFUser                *loggedInUser;

/*!
 The #loggedInSessionId property (NSString) is the sessionId returned by the authentication 
 service upon successful login/ register which is set by the FatFractal::loginWithUserName:andPassword:error: method.
 FatFractal::loginWithUserName:andPassword:error:
 */
@property (strong, nonatomic)   NSString              *loggedInSessionId;

/*!
 The #debug property (BOOL) is the Boolean representation of debug mode for the FatFractal 
 helper class.  If you want verbose NSLog output, set debug to true. It defaults to false. 
 This property is typically set by your AppDelegate class.
 
 */
@property (nonatomic)           BOOL                   debug;

/*!
 The #classToClazzDict property (NSMutableDictionary) holds the mapping from Obj-C Class to 
 the 'class name' that the FF noserver stores with the data
 */
@property (strong, nonatomic)   NSMutableDictionary     *classToClazzDict;
/*!
 The #clazzToClassDict property (NSMutableDictionary) holds the mapping to Obj-C Class from 
 the 'class name' that the server stores with the data
 */
@property (strong, nonatomic)   NSMutableDictionary     *clazzToClassDict;

#pragma mark Lifecycle

/*!
 FatFractal is not a singleton class; however in most cases there will be only a single instance.
 This method returns the "main" instance, which defaults to being the first FatFractal instance
 which was created, but can also be explicitly set.
 */
+ (FatFractal *) main;

/*!
 Explicitly set the FatFractal instance which #FatFractal:main returns.
 */
+ (void) setMain:(FatFractal *)_main;

/*!
 Plain ol init.
 @return <b>FatFractal id</b> - an instance of the FactFractal helper class is returned with no 
 property values set. Should use FatFractal::initWithBaseUrl:(NSString *) instead.
 */
- (id) init;

/*! 
 The #initWithBaseUrl method when passed a string like: http://localhost/hoodyoodoo, configures 
 the FatFractal helper class for all of the CRUD, query, server extension and event methods.
 @param NSString theBaseUrl (required) sets the #baseUrl parameter for the FatFractal helper 
 class that is used to create <b>NSURL</b> constructs.
 @param NSString theSslUrl (required) sets the #sslUrl parameter for the FatFractal helper 
 class that is used to create <b>NSURL</b> constructs. Use when using non-standard ports.
 @return <b>(id)</b> - this method returns an instance of the FactFractal helper class with 
 the value of the #baseUrl property of the FatFractal helper class set to <b>theBaseUrl</b>.
 */
- (id) initWithBaseUrl:(NSString *)theBaseUrl sslUrl:(NSString *)theSslUrl;

/*!
 Calls #initWithBaseUrl:sslUrl setting sslUrl to a copy of the baseUrl, but replacing http: with https:
 @see #initWithBaseUrl:sslUrl
 */
- (id) initWithBaseUrl:(NSString *)theBaseUrl;

#pragma mark Dynamic typing

/*!
 Utility method which will determine a Class from the <b>(NSString)</b> ffClass which is returned 
 from the FF noserver.
 @param NSString _clazz
 @return <b>Class _class</b>
 */
- (Class) getClassFromClazz:(NSString *)_clazz;

/*! 
 Utility method which will determine a NSString name for a Class _class.
 @param <b>Class _class</b>
 @return NSString _clazz
 */
- (NSString *) getClazzFromClass:(Class)_class;

/*!
 As one goes cross-platform, will need to maintain a mapping from canonical (server) 'class' to 
 Obj-C class. To get started, one can ignore this; the ffClass will default to the Obj-C Class 
 and vice versa.
 @param Class _class (required) for the desired class to be registered with the FatFractal helper class. 
 @param NSString _clazz (required) is the relative URL to be used to access the remote resource.
 @return This method does not return anything, instead upon success, the <b>NSMutableDictionary metaData</b>
 property for the FatFractal helper class is set to <b>relUrl</b> with the key that is a <b>NSString</b>
 representation of <b>class</b>.
 */
- (void) registerClass:(Class)_class forClazz:(NSString *)_clazz;


#pragma mark Authentication

/*!
 Asynchronous method to login a user.
 @param NSString userName
 @param NSString password
 @param FFHttpMethodCompletion Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - the logged-in FFUser, if the login was successful
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return This method does not return anything, instead upon success, the values for three properties 
 that are accessible by your application are set. 
 <br><b>NSString loggedInSessionId</b> is set to the SessionId returned by the FF noserver.
 <br><b>NSString loggedInUserName</b> is set to the UserName returned by the FF noserver.
 <br><b>BOOL loggedIn</b> is set to true.
 */
- (void) loginWithUserName:(NSString *)userName 
               andPassword:(NSString *)password
                onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous method to login a user.
 @param NSString userName
 @param NSString password
 @param NSError outErr - will be non-nil if an error has occurred
 @return FFUser - the logged-in FFUser, if the login was successful, nil otherwise.
 Additionally upon success, the values for some other properties that are accessible by your
 application are set:
 <br><b>NSString loggedInSessionId</b> is set to the SessionId returned by the FF noserver.
 <br><b>NSString loggedInUserName</b> is set to the UserName returned by the FF noserver.
 <br><b>BOOL loggedIn</b> is set to true.
 */
- (FFUser *) loginWithUserName:(NSString *)theUserName andPassword:(NSString *)thePassword error:(NSError **)outErr;

/*!
 Synchronous method to login a user.
 @param NSString userName
 @param NSString password
 @return FFUser - the logged-in FFUser, if the login was successful, nil otherwise.
 Additionally upon success, the values for some other properties that are accessible by your
 application are set:
 <br><b>NSString loggedInSessionId</b> is set to the SessionId returned by the FF noserver.
 <br><b>NSString loggedInUserName</b> is set to the UserName returned by the FF noserver.
 <br><b>BOOL loggedIn</b> is set to true.
 */
- (FFUser *) loginWithUserName:(NSString *)theUserName andPassword:(NSString *)thePassword;


#pragma mark Push support

/*!
 Your AppDelegate should call this method when it is informed by iOS of the device token.
 For example:
 - (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
 NSLog(@"didRegisterForRemoteNotifications called");
 [[FatFractal main] setDeviceTokenHexString:[devToken description]];
 }
 */
- (void) setDeviceTokenHexString:(NSString *)_deviceTokenHexString;

#pragma mark Lifecycle support for your persistent objects, via HTTP to your Fat Fractal backend

/*! 
 Asynchronous <b>CRUD CREATE</b> method that performs a <b>HTTP POST</b> to create a new resource on the 
 FF noserver. When passed an object <b>(id)obj</b>, the method, using the <b>NSURL url</b>, including 
 appropriate authentication information will then <b>POST</b> the object to that url.
 @param (id) obj the instance of any arbritrary class object to be created and persisted on 
 the FF noserver.
 @param NSString relativeUrl is the url for this resource relative to the #baseUrl 
 property set by FatFractal::initWithBaseUrl:(NSString *).
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - the object which was passed to the method, or nil if there's been an error
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 <br><br>
 Note that on success your object will have an associated FFMetaData object, which makes available the
 mandatory ivars required by the FF CRUD API, including:
 @return <b>NSString guid</b> the unique identifier for the resource that was created on the FF noserver.
 @return <b>NSString createdBy</b> the unique user name for the FFUser that created the object.
 @return <b>NSDate createdAt</b> with the date/time stamp when the object was created as set by the 
 FF noserver.
 @return <b>NSDate updatedAt</b> with the date/time stamp when the object was last updated as set by the 
 FF noserver.
 @return <b>NSString clazz</b> that contains the qualified class name for this object.
 @return <b>NSString ffUrl</b> that contains the fully qualified url to access to this object on the 
 FF noserver.
 @return <b>NSNumber version</b> is a counter that tracks the version of the object for data inegrity purposes.
 @return <b>NSString resourceLocation</b> that contains the relative url to access to this object on 
 the FF noserver
 */
- (void) createObj:(id)obj atUrl:(NSString *)ffUrl onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous version of #createObj:atUrl:onComplete:
 @param (id) obj the instance of any arbritrary class object to be created and persisted on 
 the FF noserver.
 @param NSString relativeUrl is the url for this resource relative to the #baseUrl 
 property set by FatFractal::initWithBaseUrl:(NSString *).
 @return <b>(id)</b> the object which passed in, or nil if there was an error.
 */
- (id) createObj:(id)obj atUrl:(NSString *)ffUrl;

/*!
 Synchronous version of #createObj:atUrl:onComplete:
 @param (id) obj the instance of any arbritrary class object to be created and persisted on 
 the FF noserver.
 @param NSString relativeUrl is the url for this resource relative to the #baseUrl 
 property set by FatFractal::initWithBaseUrl:(NSString *).
 @param NSError outErr - will be non-nil if an error has occurred
 @return <b>(id)</b> the object which passed in, or nil if there was an error.
 */
- (id) createObj:(id)obj atUrl:(NSString *)ffUrl error:(NSError **)outErr;

/*!
 Asynchronous <b>CRUD READ</b> method that performs a <b>HTTP GET</b> to retrieve 0..N resources from the FF noserver
 and returns an <b>NSArray</b> containing all the obects. If the class to deserialize to can 
 be determined, then instances of that class will be returned. If not, then NSDictionaries are returned. 
 <br><br> In the event an error is encountered, <b>error</b> is set with a localized <b>NSError</b>.
 @param NSString url - the url for this query. For example @"/ff/resources/MyObjects/(GET-ALL)"
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - an NSArray containing the retrieved values
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 <br><br>
 Note that on success your object will have an associated FFMetaData object, which makes available the
 mandatory ivars required by the FF CRUD API, including:
 @return <b>NSString guid</b> the unique identifier for the resource that was created on the FF noserver.
 @return <b>NSString createdBy</b> the unique user name for the FFUser that created the object.
 @return <b>NSDate createdAt</b> with the date/time stamp when the object was created as set by the 
 FF noserver.
 @return <b>NSDate updatedAt</b> with the date/time stamp when the object was last updated as set by the 
 FF noserver.
 @return <b>NSString clazz</b> that contains the qualified class name for this object.
 @return <b>NSString ffUrl</b> that contains the fully qualified url to access to this object on the 
 FF noserver.
 @return <b>NSNumber version</b> is a counter that tracks the version of the object for data inegrity purposes.
 @return <b>NSString resourceLocation</b> that contains the relative url to access to this object on 
 the FF noserver
 */
- (void) getArrayFromUrl:(NSString *)ffUrl onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous version of #getArrayFromUrl:onComplete:
 @param NSString url - the url for this query. For example @"/ff/resources/MyObjects/(GET-ALL)"
 @return <b>(id)</b> an array containing 0 or more objects; or nil if there was an error
 */
- (NSArray *) getArrayFromUrl:(NSString *)ffUrl;
/*!
 Synchronous version of #getArrayFromUrl:onComplete:
 @param NSString url - the url for this query. For example @"/ff/resources/MyObjects/(GET-ALL)"
 @param NSError outErr - will be non-nil if an error has occurred
 @return <b>(id)</b> an array containing 0 or more objects; or nil if there was an error
 */
- (NSArray *) getArrayFromUrl:(NSString *)ffUrl error:(NSError **)outErr;

/*!
 
 A <b>CRUD READ</b> method that performs a <b>HTTP GET</b> to retrieve a single resource from this 
 relative URL. If the class to deserialize to can be determined, then an instance of that class 
 will be returned. If not, then an NSDictionary is returned. 
 @param NSString relativeUrl (required) is the url for this resource relative to the #baseUrl 
 property set above.
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - 1 instance of the relevant class
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 <br><br>
 Note that on success your object will have an associated FFMetaData object, which makes available the
 mandatory ivars required by the FF CRUD API, including:
 @return <b>NSString guid</b> the unique identifier for the resource that was created on the FF noserver.
 @return <b>NSString createdBy</b> the unique user name for the FFUser that created the object.
 @return <b>NSDate createdAt</b> with the date/time stamp when the object was created as set by the 
 FF noserver.
 @return <b>NSDate updatedAt</b> with the date/time stamp when the object was last updated as set by the 
 FF noserver.
 @return <b>NSString clazz</b> that contains the qualified class name for this object.
 @return <b>NSString ffUrl</b> that contains the fully qualified url to access to this object on the 
 FF noserver.
 @return <b>NSNumber version</b> is a counter that tracks the version of the object for data inegrity purposes.
 @return <b>NSString resourceLocation</b> that contains the relative url to access to this object on 
 the FF noserver
 */
- (void) getObjFromUrl:(NSString *)ffUrl onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous version of #getObjFromUrl:onComplete:
 @param NSString url - the url for this query. For example @"/ff/resources/MyObjects/(GET-ALL)"
 @return <b>(id)</b> The retrieved object, or nil if there was an error
 */
- (id) getObjFromUrl:(NSString *)ffUrl;
/*!
 Synchronous version of #getObjFromUrl:onComplete:
 @param NSString url - the url for this query. For example @"/ff/resources/MyObjects/(GET-ALL)"
 @param NSError outErr - will be non-nil if an error has occurred. (Not retrieving EXACTLY one object is an error for this method.)
 @return <b>(id)</b> The retrieved object, or nil if there was an error
 */
- (id) getObjFromUrl:(NSString *)ffUrl error:(NSError **)outErr;

/*!
 A <b>CRUD UPDATE</b> method that performs a <b>HTTP PUT</b> to update an existing resource on the FF 
 server. When passed the modified object, the method determines the correct URL that will then <b>PUT</b> 
 the object to that url, including appropriate authentication information. The object must have previously 
 been retrieved or created via the FF API.
 @param (id) obj (required) the instance to be updated.
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - the object which was passed to the method
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 */
- (void) updateObj:(id)obj onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous version of #updateObj:onComplete:
 @param (id) obj the instance which is to replace the current version on the noserver
 @return <b>(id)</b> the object which was passed in, or nil if there was an error.
 */
- (id) updateObj:(id)obj;

/*!
 Synchronous version of #updateObj:onComplete:
 @param (id) obj the instance which is to replace the current version on the noserver
 @param NSError outErr - will be non-nil if an error has occurred
 @return <b>(id)</b> the object which was passed in, or nil if there was an error.
 */
- (id) updateObj:(id)obj error:(NSError **)outErr;

/*!
 A <b>CRUD DELETE</b> method that performs a <b>HTTP DELETE</b> to delete a resource from the 
 FF noserver. When passed any arbitrary object, the method determines the correct URL that will then 
 attempts to <b>DELETE</b> the object with that url, including appropriate authentication information. 
 The object must have previously been retrieved or created via the FF API.
 <br><br> In the event an error is encountered, <b>error</b> is set with a localized <b>NSError</b>.
 @param (id) obj (required) the instance of the object to be deleted.
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - the object which was passed to the method
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 */
- (void) deleteObj:(id)obj onComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Synchronous version of #deleteObj:onComplete:
 @param (id) obj the instance which is to be deleted on the noserver
 @return <b>(id)</b> the object which was passed in, or nil if there was an error.
 */
- (id) deleteObj:(id)obj;

/*!
 Synchronous version of #deleteObj:onComplete:
 @param (id) obj the instance which is to be deleted on the noserver
 @param NSError outErr - will be non-nil if an error has occurred
 @return <b>(id)</b> the object which was passed in, or nil if there was an error.
 */
- (id) deleteObj:(id)obj error:(NSError **)outErr;


/*!
 Get the FatFractal metadata for this object.
 The object must have previously been retrieved or created via the FF API; method will return nil if not.
 @param (id) obj (required) the instance of the object for which the metaData is required.
 @return <b>FFMetaData *</b> - the FFMetaData for the object
 */
- (FFMetaData *) metaDataForObj:(id)obj;

@end
