//
//  FatFractal.m
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//

/*! \brief FatFractal helper class implementation. */
/*! The FatFractal helper class implementation provides a numer of internal methods that are used to interact with the FF noserver using the standard REST API. */

#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import "FatFractal.h"
#import "FFUtils.h"
#import "FFUser.h"
#import "FFMetaData.h"
#import "FFHttpDelegate.h"

@interface FatFractal()
// Private methods

/*!
 This method maintains device tokens which are used for push notifications. Data is maintained 
 consistently on both the FFUser class as well as on the FF noserver for that FFUser object.
 */
- (void) saveDeviceToken;


/*!
 Utility method which will construct an object of this class from an NSJSONSerialization dictionary. 
 @param NSDictionary dict
 @return <b>(id)</b> the returned object. 
 */
- (id) objectFromDictionary:(NSDictionary *)dict;

/*!
 Utility method which will construct an NSDictionary from am object, avoiding cyclic references
 Will not include any NSData fields in the dictionary; will instead put those fields' names into the blobFields out parameter.
 @param (id)obj (required) the instance of any arbritrary class object.
 @param done : the array of objects already serialized, to avoid cyclic references
 @param level : the recurse level. Any blobs found at levels deeper than 0 will trigger an error.
 @param blobFields : out parameter into which will be placed a list of all NSData fields in this object
 @param error : out parameter which will contain any error which has occurred
 @return <b>(id)</b> the returned object. 
 */
- (id) dictionaryFromObject:(id)obj
           alreadyProcessed:(NSMutableArray *)done
                      level:(int)level
                 blobFields:(NSMutableArray *)blobFields
                      error:(NSError **)error;

/*! Sets core object data even if objects don't conform to the object protocol */
- (void) setMetaDataFromDict:(NSDictionary *)_values forObj:(id)_obj;

/*! Populates the dictionary with the stored core object data for this object */
- (void) addMetaDataToDict:(NSDictionary *)_values fromObj:(id)_obj;

// FatFractal Cookies
/*!
 Provides "cookie" support to properly format a REST request to the FF noserver. 
 @param NSMutableURLRequest request
 @return This method does not return anything, it modifies the url request to 
 include a HTTP Header Field that contain a string value with <b>sessionId</b> and <b>userName</b>
 for field called <b>"Cookie"</b>.
 */
- (void) addAuthCookieToRequest:(NSMutableURLRequest *)request;

/*! 
 Used to invoke HTTP methods on a url.
 @param NSString httpMethod - the HTTP method (GET, POST, PUT, DELETE, etc)
 @param NSDictionary dict - the JSON content (if any) to be sent with this request.
 @param NSURL url - target for the method
 @param BOOL isJson - if true, will deserialize the HTTP response into a JSON dictionary and return that as response.
 If false, will return the raw HTTP response data as the response.
 @param FFHttpMethodCompletion onComplete - Block which will execute when the HTTP call completes; parameters are
 <br><b>NSError error - will be non-nil if an error has occurred - you MUST check this
 <br><b>id response - the JSON response, deserialized
 <br><b>NSHTTPURLResponse httpResponse - the NSHTTPURLResponse should you wish to inspect it
 @return <b>(id)</b> does not return anything directly - response is via the onComplete block.
 */
- (void) invokeHttpMethod:(NSString *)httpMethod
                     body:(id)bodyParam
               bodyIsJson:(BOOL)bodyIsJson
                    onUrl:(NSURL *)url
           responseIsJson:(BOOL)responseIsJson
               onComplete:(FFHttpMethodCompletion)onComplete;

/*! 
 Synchronous version of #invokeHttpMethod:dict:onUrl:isJson:onComplete
 @param NSString httpMethod - the HTTP method (GET, POST, PUT, DELETE, etc)
 @param NSDictionary dict - the JSON content (if any) to be sent with this request.
 @param BOOL isJson - if true, will deserialize the HTTP response into a JSON dictionary and return that as response.
 @param NSError outErr out parameter - will be non-nil if an error has occurred
 @param NSHTTPURLResponse httpResponse out parameter
 @return <b>(id)</b> the HTTP response data - deserialized (if isJson is true) or raw; or nil if there was an error.
 */
- (id) invokeHttpMethod:(NSString *)httpMethod
                   body:(id)bodyParam
             bodyIsJson:(BOOL)bodyIsJson
                  onUrl:(NSURL *)url
         responseIsJson:(BOOL)responseIsJson
                  error:(NSError **)outErr
           httpResponse:(NSHTTPURLResponse **)httpResponse;

/*!
 Utility method for adding error messages to <b>NSError</b>
 @param NSString msg the message to be returned with the error.
 @return <b>NSError</b> errorWithDomain:@"FatFractal" code:1 userInfo: NSDictionary errorDetail    
 @return <b>NSError error</b> is nil if no error. In the event of an error, <b>NSError error</b> is set using 
 <b>createErrorWithLocalizedDescription</b> with an error message.
 */
- (NSError *) createErrorWithLocalizedDescription:(NSString *)msg;
@end

@implementation FatFractal

@synthesize baseUrl, sslUrl, loggedIn, loggedInUser, loggedInUserGuid, loggedInSessionId, debug, classToClazzDict, clazzToClassDict;

static FatFractal * _ffMainInstance;

+ (FatFractal *) main { return _ffMainInstance; }

+ (void) setMain:(FatFractal *)_main { _ffMainInstance = _main; }

- (id) init {
    self = [super init];
    
    [self setClassToClazzDict:[[NSMutableDictionary alloc] init]];
    [self setClazzToClassDict:[[NSMutableDictionary alloc] init]];
    [self setDebug:false];
    [self setLoggedIn: false];
    
    if (!_ffMainInstance)
        _ffMainInstance = self;
    
    references = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id) initWithBaseUrl:(NSString *)theBaseUrl sslUrl:(NSString *)theSslUrl {
    self = [self init];
    
    [self setBaseUrl: theBaseUrl];
    if (! theSslUrl) {
        theSslUrl = [theBaseUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
    }
    [self setSslUrl: theSslUrl];
    
    return self;
}

- (id) initWithBaseUrl:(NSString *)theBaseUrl {
    return [self initWithBaseUrl:theBaseUrl sslUrl:nil];
}

- (void) invokeHttpMethod:(NSString *)httpMethod
                     body:(id)bodyParam
               bodyIsJson:(BOOL)bodyIsJson
                    onUrl:(NSURL *)url
           responseIsJson:(BOOL)responseIsJson
               onComplete:(FFHttpMethodCompletion)onComplete
{
    if (debug) NSLog(@"invokeHttpMethod: Will send HTTP %@ to url: %@", httpMethod, url); 
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:httpMethod];
    [self addAuthCookieToRequest:request];
    
    NSData * httpReqBody;
    
    if (bodyIsJson) {
        NSDictionary * dict = bodyParam;
        NSError *jsonError = nil;
        if (dict) {
            httpReqBody = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];        
            if (jsonError) {
                NSLog(@"invokeHttpMethod: Failed to serialize %@ request: %@", httpMethod, [jsonError localizedDescription]);
                onComplete(jsonError, nil, nil);
                return;
            }
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
    }
    else {
        httpReqBody = bodyParam;
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request setHTTPBody:httpReqBody];
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:[[FFHttpDelegate alloc]
                                                                                              initWithOnComplete:^(NSError *err, NSData *data, NSHTTPURLResponse *response)
                                                                                              
                                                                                              {
                                                                                                  if (err) {
                                                                                                      NSLog(@"HTTP %@ failed: %@", httpMethod, [err localizedDescription]);
                                                                                                      onComplete(err, nil, response);
                                                                                                      return;
                                                                                                  }
                                                                                                  if (([response statusCode] / 100) != 2) {
                                                                                                      NSString *errString = [NSString stringWithFormat:@"HTTP %@ failed with response code %d", httpMethod, [response statusCode]];
                                                                                                      NSLog(@"%@", errString);
                                                                                                      onComplete([self createErrorWithLocalizedDescription:errString], nil, response);
                                                                                                      return;
                                                                                                  }
                                                                                                  if (!data) {
                                                                                                      NSString *msg = [NSString stringWithFormat:@"HTTP %@ returned no data, but no error was set ...", httpMethod];
                                                                                                      onComplete([self createErrorWithLocalizedDescription:msg], nil, response);
                                                                                                      return;
                                                                                                  }
                                                                                                  
                                                                                                  if (responseIsJson) {
                                                                                                      NSError *jsonResponseError;
                                                                                                      id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonResponseError];
                                                                                                      if (jsonResponseError) {
                                                                                                          NSLog(@"HTTP %@ failed to JSON deserialize POST response: %@", httpMethod, [jsonResponseError localizedDescription]);
                                                                                                          onComplete(jsonResponseError, nil, response);
                                                                                                          return;
                                                                                                      }
                                                                                                      if (debug) NSLog(@"HTTP %@: Deserialized JSON response: Top JSON wrapper type is %@: Main JSON result type is %@: Data is %@",
                                                                                                                       httpMethod, [response class], [[jsonResponse valueForKey:@"result"] class], response);
                                                                                                      onComplete(nil, jsonResponse, response);
                                                                                                  }
                                                                                                  else {
                                                                                                      if (debug) NSLog(@"HTTP %@: Received (non-JSON) response; data length is %d", httpMethod, [data length]);
                                                                                                      onComplete(nil, data, response);
                                                                                                  }
                                                                                                  return;
                                                                                              }]];
    
    [connection start];
}

- (id) invokeHttpMethod:(NSString *)httpMethod
                   body:(id)bodyParam
             bodyIsJson:(BOOL)bodyIsJson
                  onUrl:(NSURL *)url
         responseIsJson:(BOOL)responseIsJson
                  error:(NSError **)outErr
           httpResponse:(NSHTTPURLResponse **)httpResponse
{
    __block BOOL opCompleted = false;
    __block id outObj;
    __block NSError *tempErr;
    __block NSHTTPURLResponse *tempHR;
    [self invokeHttpMethod:httpMethod body:bodyParam bodyIsJson:bodyIsJson onUrl:url responseIsJson:responseIsJson
                onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
                    tempErr = crudErr;
                    outObj  = crudObj;
                    tempHR = r;
                    opCompleted = true;
                }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    *httpResponse = tempHR;
    
    return outObj;
}


- (FFUser *) loginWithUserName:(NSString *)theUserName andPassword:(NSString *)thePassword error:(NSError **)outErr {
    __block FFUser *outUser;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self loginWithUserName:theUserName andPassword:thePassword onComplete:^(NSError *loginErr, id user, NSHTTPURLResponse *r) {
        tempErr = loginErr;
        outUser = user;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outUser;
}

- (FFUser *) loginWithUserName:(NSString *)theUserName andPassword:(NSString *)thePassword {
    NSError *error;
    return [self loginWithUserName:theUserName andPassword:thePassword error:&error];
}

- (void) loginWithUserName:(NSString *)theUserName andPassword:(NSString *)thePassword onComplete:(FFHttpMethodCompletion)onComplete {
    if (! self.sslUrl) {
        onComplete([self createErrorWithLocalizedDescription:@"Login failed - no SSL URL has been set"], nil, nil);
        return;
    }
    NSString *loginUrlString = [NSString stringWithFormat:@"%@/ff/login", [self sslUrl]];
    NSURL *loginUrl= [NSURL URLWithString:loginUrlString];
    if (debug) NSLog(@"Attempting to login as %@ to %@",
                     theUserName, [loginUrl absoluteString]);
    
    NSMutableDictionary *credentialDict = [[NSMutableDictionary alloc] init];
    [credentialDict setValue:theUserName forKey:@"userName"];
    [credentialDict setValue:thePassword forKey:@"password"];
    
    NSMutableDictionary *reqDict = [[NSMutableDictionary alloc] init];
    [reqDict setValue:credentialDict forKey:@"credential"];
    
    [self invokeHttpMethod:@"POST" body:reqDict bodyIsJson:true onUrl:loginUrl responseIsJson:true
                onComplete:^(NSError *err, id jsonResponseDict, NSHTTPURLResponse *httpResponse) {
                    if (err) {
                        onComplete(err, nil, httpResponse);
                        return;
                    } else {
                        self.loggedInSessionId = [jsonResponseDict valueForKeyPath:@"result.authResult.session.sessionId"];
                        self.loggedInUserGuid = [jsonResponseDict valueForKeyPath:@"result.credential.userGuid"];
                        self.loggedIn = true;
                        
                        if (debug) NSLog(@"Login succeeded");
                        
                        [self saveDeviceToken];
                        
                        NSString *userUrl = [NSString stringWithFormat:@"/ff/resources/FFUser/%@", [self loggedInUserGuid]];
                        [self getObjFromUrl:userUrl onComplete:^(NSError *err, id user, NSHTTPURLResponse *httpResponse) {
                            self.loggedInUser = user;
                            onComplete(nil, user, httpResponse);
                        }];
                    }
                }];
    
    return;
}

- (void) setDeviceTokenHexString:(NSString *)_deviceTokenHexString {
    deviceTokenHexString = _deviceTokenHexString;
    [self saveDeviceToken];
}

- (void) saveDeviceToken {
    if (! deviceTokenHexString || ! loggedIn)
        return;
    
    // Logic for device tokens
    // Store the device token in the array of device tokens which currently exists for this user
    // So - we'll retrieve the User from the server
    NSString *url = [NSString stringWithFormat:@"/ff/resources/FFUser/%@", [self loggedInUserGuid]];
    [self getObjFromUrl:url onComplete:^(NSError *err, id user, NSHTTPURLResponse *httpResponse) {
        if (err) {
            NSLog(@"saveDeviceToken - failed to retrieve FFUser with error %@", [err localizedDescription]);
            return;
        }
        if (! user) {
            NSLog(@"saveDeviceToken - no error, but FFUser is nil");
            return;
        }
        
        // DeviceTokens is an array of Strings
        // Each token looks like "PushProvider.TokenData"
        // We search for a token which looks like "Apple.<thisDeviceToken>"
        NSLog(@"Device Token is hex string [%@]", deviceTokenHexString);
        NSString * tokenString = [NSString stringWithFormat:@"Apple.%@", deviceTokenHexString];
        BOOL found = false;
        int i = 0;
        for (i = 0; i < [[user deviceTokens] count]; i++) {
            if ([[[user deviceTokens] objectAtIndex:i] isEqualToString:tokenString]) {
                found = true;
                break;
            }
        }
        // If it exists, do nothing
        if (found) {
            if (debug) NSLog(@"saveDeviceToken - Device token already exists - no need to do anything");
            return;
        } else { // If it doesn't exist, add it to the array and save the data back to where it came from
            [[user deviceTokens] addObject:tokenString];
            [self updateObj:user onComplete:^(NSError *updateErr, id obj, NSHTTPURLResponse *httpResponse) {
                if (err)
                    NSLog(@"saveDeviceToken - failed to update FFUser with error %@", [err localizedDescription]);
                else
                    NSLog(@"saveDeviceToken - FFUser updated successfully");
            }];
        }
    }];
}


- (Class) getClassFromClazz:(NSString *)_clazz {
    Class _class = [self.clazzToClassDict valueForKey:_clazz];
    if (! _class)
        _class = objc_lookUpClass([_clazz UTF8String]);
    return _class;
}

- (NSString *) getClazzFromClass:(Class)_class {
    NSString * _clazz = [self.classToClazzDict valueForKey:[NSString stringWithCString:class_getName(_class) encoding:NSUTF8StringEncoding]];
    if (!_clazz)
        _clazz = [NSString stringWithCString:class_getName(_class) encoding:NSUTF8StringEncoding];
    return _clazz;
}

- (void) registerClass:(Class)_class forClazz:(NSString *)_clazz {
    [self.clazzToClassDict setValue:_class forKey:_clazz];
    [self.classToClazzDict setValue:_clazz forKey:[NSString stringWithCString:class_getName(_class) encoding:NSUTF8StringEncoding]];
}

- (id) createObj:(id)obj atUrl:(NSString *)ffUrl {
    NSError *err;
    return [self createObj:obj atUrl:ffUrl error:&err];
}

- (id) createObj:(id)obj atUrl:(NSString *)ffUrl error:(NSError **)outErr {
    __block id outObj;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self createObj:obj atUrl:ffUrl onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
        tempErr = crudErr;
        outObj  = crudObj;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outObj;
}

#pragma mark CRUD support
- (void) createObj:(id)obj atUrl:(NSString *)ffUrl onComplete:(FFHttpMethodCompletion)onComplete {
    if (! loggedIn) {
        onComplete([self createErrorWithLocalizedDescription:@"Not logged in"], nil, nil);
    }
    
    NSString *urlString;
    if ([ffUrl hasPrefix:@"/ff/"])
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, ffUrl];
    else
        urlString = [NSString stringWithFormat:@"%@/ff/resources%@", baseUrl, ffUrl];
    
    NSURL *theUrl = [[NSURL alloc] initWithString:urlString];
    
    NSError *jsonRequestError;
    // Serialize the object to a Dictionary - NB - this will IGNORE NSData fields and put those field names into an NSArray of NSStrings
    NSMutableArray *blobFields = [[NSMutableArray alloc] init];
    NSDictionary *reqDict = [self dictionaryFromObject:obj
                                      alreadyProcessed:[[NSMutableArray alloc]init]
                                                 level:0
                                            blobFields:blobFields
                                                 error:&jsonRequestError];
    if (jsonRequestError) {
        onComplete(jsonRequestError, nil, nil);
        return;
    }
    
    [self invokeHttpMethod:@"POST" body:reqDict bodyIsJson:true onUrl:theUrl responseIsJson:true
                onComplete:^(NSError *err, id jsonResponseDict, NSHTTPURLResponse *httpResponse) {
                    if (err) {
                        onComplete(err, nil, httpResponse);
                        return;
                    } else {
                        if (!jsonResponseDict) {
                            onComplete([self createErrorWithLocalizedDescription:@"createObj: empty response from the server"], nil, httpResponse);
                            return;
                        }
                        if (![jsonResponseDict valueForKey:@"result"]) {
                            onComplete([self createErrorWithLocalizedDescription:@"createObj: response from the server did not contain 'result' value"],
                                       nil, httpResponse);
                            return;
                        }
                        if (debug) NSLog(@"createObj: Got response %@ from server", jsonResponseDict);
                        [self setMetaDataFromDict:[jsonResponseDict valueForKey:@"result"] forObj:obj];
                        
                        for (NSString * blobFieldName in blobFields) {
                            id blobVal = [obj valueForKey:blobFieldName];
                            if ([blobVal isKindOfClass:[NSNull class]] || blobVal == nil) {
                                NSLog(@"Blob value for field %@ is null", blobFieldName);
                                continue;
                            }
                            else {
                                if (debug) NSLog(@"Blob is non-nil and has class %@", [blobVal class]);
                                if ([blobVal isKindOfClass:[NSData class]]) {
                                    if (debug) NSLog(@"Blob is NSData - length is %d", [blobVal length]);
                                    NSString *blobUrlString = [NSString stringWithFormat:@"%@/%@/%@", urlString,
                                                               [[self metaDataForObj:obj] guid], blobFieldName];
                                    NSURL *blobUrl = [[NSURL alloc] initWithString:blobUrlString];
                                    NSError *blobErr;
                                    NSHTTPURLResponse *blobHR;
                                    id blobPutResponseDict = [self invokeHttpMethod:@"PUT" body:blobVal bodyIsJson:false onUrl:blobUrl responseIsJson:true
                                                                              error:&blobErr httpResponse:&blobHR];
                                    if (blobErr)
                                        NSLog(@"Failed to PUT blob to %@ - error was %@ - response code was %d",
                                              blobUrlString, [blobErr localizedDescription], [blobHR statusCode]);
                                    else
                                        if (debug) NSLog(@"Blob PUT succeeded! Response is %@", blobPutResponseDict);
                                }
                            }
                        }
                        
                        [references setObject:obj forKey:[[self metaDataForObj:obj] ffUrl]];
                        
                        onComplete(nil, obj, httpResponse);
                        return;
                    }
                }];
}

- (void) getArrayFromUrl:(NSString *)relativeUrl onComplete:(FFHttpMethodCompletion)onComplete
{
    NSString *urlString;
    if ([relativeUrl hasPrefix:@"/ff/"])
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, relativeUrl];
    else
        urlString = [NSString stringWithFormat:@"%@/ff/resources%@", baseUrl, relativeUrl];
    
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    
    NSURL *instanceUrl = [[NSURL alloc] initWithString:encodedUrlString];
    
    [self invokeHttpMethod:@"GET" body:nil bodyIsJson:true onUrl:instanceUrl responseIsJson:true
                onComplete:^(NSError *err, id jsonResponseDict, NSHTTPURLResponse *httpResponse) {
                    if (err || ! jsonResponseDict) {
                        onComplete (err, nil, httpResponse);
                        return;
                    }
                    
                    NSMutableArray *retVal = [[NSMutableArray alloc] init];
                    
                    // the result will usually be an array of Dictionaries
                    // but it might be an individual Dictionary also
                    NSMutableArray * allObjects;
                    id resultObj = [jsonResponseDict valueForKey:@"result"];
                    if ([resultObj isKindOfClass:[NSDictionary class]]) {
                        allObjects = [[NSMutableArray alloc] init];
                        [allObjects addObject:resultObj];
                    }
                    else if ([resultObj isKindOfClass:[NSArray class]]) {
                        allObjects = resultObj;
                    }
                    else {
                        NSString *msg = [NSString stringWithFormat:@"Unexpected result type %@ - can only handle Dictionary or Array", [resultObj class]];
                        onComplete([self createErrorWithLocalizedDescription:msg], nil, httpResponse);
                        return;
                    }
                    for (NSDictionary *dict in allObjects) {
                        id obj = [self objectFromDictionary:dict];
                        
                        NSString *objectsFfUrl = [[self metaDataForObj:obj] ffUrl];
                        if (objectsFfUrl)
                            [references setObject:obj forKey:objectsFfUrl];
                        [retVal addObject:obj];
                    }
                    
                    if (debug) NSLog(@"getArrayFromUrl (%@) found %d objects", relativeUrl, [retVal count]);
                    
                    onComplete(nil, retVal, httpResponse);
                }];
}

- (NSArray *) getArrayFromUrl:(NSString *)ffUrl {
    NSError *err;
    return [self getArrayFromUrl:ffUrl error:&err];
}

- (NSArray *) getArrayFromUrl:(NSString *)ffUrl error:(NSError **)outErr {
    __block id outObj;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self getArrayFromUrl:ffUrl onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
        tempErr = crudErr;
        outObj  = crudObj;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outObj;
}

- (void) getObjFromUrl:(NSString *)relativeUrl onComplete:(FFHttpMethodCompletion)onComplete {
    [self getArrayFromUrl:relativeUrl onComplete:^(NSError *err, id objects, NSHTTPURLResponse *httpResponse) {
        if (err) {
            onComplete(err, nil, httpResponse);
            return;
        }
        // must return EXACTLY 1 object
        NSArray *retVal = (NSArray *)objects;
        if ([retVal count] != 1) {
            NSString *errMsg = [NSString stringWithFormat:@"getObjFromUrl expects ONE object - received %d", [retVal count]];
            onComplete([self createErrorWithLocalizedDescription:errMsg], nil, httpResponse);
            return;
        }
        else {
            onComplete(nil, [retVal objectAtIndex:0], httpResponse);
        }
    }];
}

- (id) getObjFromUrl:(NSString *)ffUrl {
    NSError *err;
    return [self getObjFromUrl:ffUrl error:&err];
}

- (id) getObjFromUrl:(NSString *)ffUrl error:(NSError **)outErr {
    __block id outObj;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self getObjFromUrl:ffUrl onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
        tempErr = crudErr;
        outObj  = crudObj;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outObj;
}

- (void) updateObj:(id)obj onComplete:(FFHttpMethodCompletion)onComplete {
    NSString *relativeUrl = [[self metaDataForObj:obj] ffUrl];
    if (! relativeUrl) {
        onComplete([self createErrorWithLocalizedDescription:@"updateObj: Could not find FatFractal url for this object"], nil, nil);
        return;
    }
    NSString *urlString;
    if ([relativeUrl hasPrefix:@"/ff/"])
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, relativeUrl];
    else
        urlString = [NSString stringWithFormat:@"%@/ff/resources%@", baseUrl, relativeUrl];
    
    NSURL *instanceUrl = [[NSURL alloc] initWithString:urlString];
    
    if (debug) NSLog(@"updateObj: Will update object at URL %@", [instanceUrl absoluteString]);
    
    // Serialize the object to a Dictionary
    NSError *jsonRequestError;
    NSMutableArray *blobFields = [[NSMutableArray alloc] init];
    NSDictionary *reqDict = [self dictionaryFromObject:obj
                                      alreadyProcessed:[[NSMutableArray alloc]init]
                                                 level:0
                                            blobFields:blobFields
                                                 error:&jsonRequestError];
    
    if (jsonRequestError) {
        onComplete(jsonRequestError, nil, nil);
        return;
    }
    
    for (NSString * blobFieldName in blobFields) {
        NSLog(@"updateObj: Found a blob field called %@", blobFieldName);
    }
    
    // Then PUT it to the server
    [self invokeHttpMethod:@"PUT" body:reqDict bodyIsJson:true onUrl:instanceUrl responseIsJson:true
                onComplete:^(NSError *err, id jsonResponseDict, NSHTTPURLResponse *httpResponse) {
                    if (err || !jsonResponseDict || ! [jsonResponseDict valueForKey:@"result"]) {
                        onComplete(err, nil, httpResponse);
                        return;
                    }
                    
                    [self setMetaDataFromDict:[jsonResponseDict valueForKey:@"result"] forObj:obj];
                    
                    if (debug) NSLog(@"updateObj: Got response %@ from server", jsonResponseDict);
                    
                    onComplete(nil, obj, httpResponse);
                    return;
                }];
}

- (id) updateObj:(id)obj {
    NSError *err;
    return [self updateObj:obj error:&err];
}

- (id) updateObj:(id)obj error:(NSError **)outErr {
    __block id outObj;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self updateObj:obj onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
        tempErr = crudErr;
        outObj  = crudObj;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outObj;
}

- (void) deleteObj:(id)obj onComplete:(FFHttpMethodCompletion)onComplete
{
    NSString *relativeUrl = [[self metaDataForObj:obj] ffUrl];
    if (! relativeUrl) {
        NSString *msg = [NSString stringWithFormat:@"deleteObj: Could not find FatFractal url for this object (%@)", [obj description]];
        onComplete([self createErrorWithLocalizedDescription:msg], nil, nil);
        return;
    }
    
    NSString *urlString;
    if ([relativeUrl hasPrefix:@"/ff/"])
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, relativeUrl];
    else
        urlString = [NSString stringWithFormat:@"%@/ff/resources%@", baseUrl, relativeUrl];
    
    NSURL *instanceUrl = [[NSURL alloc] initWithString:urlString];
    
    if (debug) NSLog(@"deleteObj: Will delete object at URL %@", [instanceUrl absoluteString]);
    
    [self invokeHttpMethod:@"DELETE" body:nil bodyIsJson:true onUrl:instanceUrl responseIsJson:true
                onComplete:^(NSError *err, id jsonResponseDict, NSHTTPURLResponse *httpResponse) {
                    if (err) {
                        onComplete(err, nil, httpResponse);
                        return;
                    }
                    if (debug) NSLog(@"deleteObj: Got response %@ from server", jsonResponseDict);
                    onComplete(nil, obj, httpResponse);
                }];
}

- (id) deleteObj:(id)obj {
    NSError *err;
    return [self deleteObj:obj error:&err];
}

- (id) deleteObj:(id)obj error:(NSError **)outErr {
    __block id outObj;
    __block BOOL opCompleted = false;
    __block NSError *tempErr;
    [self deleteObj:obj onComplete:^(NSError *crudErr, id crudObj, NSHTTPURLResponse *r) {
        tempErr = crudErr;
        outObj  = crudObj;
        opCompleted = true;
    }];
    
    while (!opCompleted) {
        NSDate* cycle = [NSDate dateWithTimeIntervalSinceNow:0.001];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:cycle];
    }
    *outErr = tempErr;
    
    return outObj;
}


static char akMetaData;

- (FFMetaData *) metaDataForObj:(id)obj {
    return objc_getAssociatedObject(obj, &akMetaData);
    
}

#pragma mark Private methods

- (void) addAuthCookieToRequest:(NSMutableURLRequest *) request {
    NSString *ffAuthCookie = [[NSString alloc] initWithFormat:@"sessionId=%@; userGuid=%@",
                              [self loggedInSessionId], [self loggedInUserGuid]];
    [request setValue:ffAuthCookie forHTTPHeaderField:@"Cookie"];
}

static NSString *KEY_FF_URL         = @"ffUrl";
static NSString *KEY_FF_CLAZZ       = @"clazz";
static NSString *KEY_FF_GUID        = @"guid";
static NSString *KEY_FF_VERSION     = @"version";
static NSString *KEY_FF_UPDATED_AT  = @"updatedAt";
static NSString *KEY_FF_UPDATED_BY  = @"updatedBy";
static NSString *KEY_FF_CREATED_AT  = @"createdAt";
static NSString *KEY_FF_CREATED_BY  = @"createdBy";
static NSString *KEY_FF_RL          = @"ffRL";
static NSString *KEY_FF_REFS        = @"ffRefs";

- (void) addMetaDataToDict:(NSDictionary *)dict fromObj:(id)_obj {
    FFMetaData *metaData = [self metaDataForObj:_obj];
    if (!metaData)
        return;
    
    [dict setValue:[self getClazzFromClass:[_obj class]]
            forKey:KEY_FF_CLAZZ];
    [dict setValue:[metaData ffUrl] forKey:KEY_FF_URL];
    [dict setValue:[metaData guid] forKey:KEY_FF_GUID];
    [dict setValue:[metaData createdBy] forKey:KEY_FF_CREATED_BY];
    [dict setValue:[metaData updatedBy] forKey:KEY_FF_UPDATED_BY];
    [dict setValue:[NSNumber numberWithLongLong:(long long)([[metaData createdAt] timeIntervalSince1970] * 1000.0)]
            forKey:KEY_FF_CREATED_AT];
    [dict setValue:[NSNumber numberWithLongLong:(long long)([[metaData updatedAt] timeIntervalSince1970] * 1000.0)]
            forKey:KEY_FF_UPDATED_AT];
    [dict setValue:[metaData objVersion] forKey:KEY_FF_VERSION];
}

- (void) setMetaDataFromDict:(NSDictionary *)_values forObj:(id)_obj {
    //    NSString *clazz     = [_values valueForKeyPath:KEY_FF_CLAZZ];
    NSString *ffUrl     = [_values valueForKeyPath:KEY_FF_URL];
    NSString *guid      = [_values valueForKeyPath:KEY_FF_GUID];
    NSString *createdBy = [_values valueForKeyPath:KEY_FF_CREATED_BY];
    NSString *updatedBy = [_values valueForKeyPath:KEY_FF_UPDATED_BY];
    NSDate   *createdAt = [[NSDate alloc] initWithTimeIntervalSince1970:
                           [[_values valueForKeyPath:KEY_FF_CREATED_AT] doubleValue]/1000.0];
    NSDate   *updatedAt = [[NSDate alloc] initWithTimeIntervalSince1970:
                           [[_values valueForKeyPath:KEY_FF_UPDATED_AT] doubleValue]/1000.0];
    NSNumber *version   = [_values valueForKeyPath:KEY_FF_VERSION];
    
    FFMetaData *md = [[FFMetaData alloc] init];
    [md setFfUrl:ffUrl];
    [md setGuid:guid];
    [md setCreatedBy:createdBy];
    [md setCreatedAt:createdAt];
    [md setUpdatedBy:updatedBy];
    [md setUpdatedAt:updatedAt];
    [md setObjVersion:version];
    
    objc_setAssociatedObject(_obj, &akMetaData, md, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSError *) createErrorWithLocalizedDescription:(NSString *)msg {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:msg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"FatFractal" code:1 userInfo: errorDetail];    
}

- (NSString *) classNameForPropAttributes:(NSString *)propAttributes {
    const char * type = [propAttributes UTF8String];
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    // NSString * propertyType = [typeAttribute substringFromIndex:1];
    // const char * rawPropertyType = [propertyType UT`F8String];
    
    if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 2) // turn, for example, T@"object" into object
        return [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
    else
        return nil;
}

- (BOOL) isReservedKey:(NSString *)key {
    return (
            [   key isEqualToString:KEY_FF_URL ]        
            || [key isEqualToString:KEY_FF_VERSION ]    
            || [key isEqualToString:KEY_FF_CREATED_BY ] 
            || [key isEqualToString:KEY_FF_CREATED_AT ] 
            || [key isEqualToString:KEY_FF_UPDATED_BY ] 
            || [key isEqualToString:KEY_FF_UPDATED_AT ] 
            || [key isEqualToString:KEY_FF_CLAZZ ]      
            || [key isEqualToString:KEY_FF_GUID ]
            || [key isEqualToString:KEY_FF_RL ]
            );
}

- (id) dictionaryFromObject:(id)obj
           alreadyProcessed:(NSMutableArray *)done
                      level:(int)level
                 blobFields:(NSMutableArray *)blobFields
                      error:(NSError **)error
{
    [done addObject:obj];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [self addMetaDataToDict:obj fromObj:obj];
        return obj;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *dictRefs;
    [self addMetaDataToDict:dict fromObj:obj];
    [dict setValue:[self getClazzFromClass:[obj class]] forKey:@"clazz"];
    NSDictionary *props = [FFUtils propertiesForClass:[obj class]];
    NSString *key;
    for (key in [props allKeys]) {
        if ([self isReservedKey:key]) continue;
        NSString *propAttributes = [props valueForKey:key];
        if (self.debug) NSLog(@"dictionaryFromObject: Got property attributes %@ for key %@", propAttributes, key);
        id val = [obj valueForKey:key];
        if ([val isKindOfClass:[NSArray class]])
        {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[val count]];
            [dict setValue:array forKey:key];
            for (id arrayItem in [val objectEnumerator]) {
                if ([arrayItem isKindOfClass:[NSNumber class]] ||
                    [arrayItem isKindOfClass:[NSString class]] ||
                    [arrayItem isKindOfClass:[NSNull class]])
                    [array addObject:arrayItem];
                else if ([arrayItem isKindOfClass:[NSDate class]])
                    [array addObject:[NSNumber numberWithLongLong:(long long)([(NSDate *)arrayItem timeIntervalSince1970] * 1000.0)]];
                else
                    [array addObject:[self dictionaryFromObject:arrayItem
                                               alreadyProcessed:done
                                                          level:level+1
                                                     blobFields:blobFields
                                                          error:error]];
                if (*error) return nil;
            }
            continue;
        }
        if (val == nil) {
            if (debug) NSLog(@"dictionaryFromObject: Setting [NSNull null] for %@", key);
            [dict setValue:[NSNull null] forKey:key];
            continue;
        }
        if ([val isKindOfClass:[NSNumber class]] ||
            [val isKindOfClass:[NSString class]] ||
            [val isKindOfClass:[NSNull class]])
        {
            [dict setValue:val forKey:key];
            continue;
        }
        if ([val isKindOfClass:[NSDate class]])
        {
            NSNumber *dateNum = [NSNumber numberWithLongLong:(long long)([(NSDate *)val timeIntervalSince1970] * 1000.0)];
            [dict setValue:dateNum forKey:key];
            continue;
        }
        if ([val isKindOfClass:[NSData class]])
        {
            if (level > 0) {
                *error = [self createErrorWithLocalizedDescription:@"Blob fields may currently only be at level 0 of a FF object"];
                return nil;
            }
            [blobFields addObject:key];
            continue;
        }
        if ([done containsObject:val])
            NSLog(@"Avoiding cyclic reference, not serializing key %@ in obj %@", key, obj);
        else {
            // Need to figure out if we're persisting by reference or by value
            if ([self metaDataForObj:val]) // we know about this object; store as reference
            {
                if (!dictRefs) {
                    dictRefs = [[NSMutableArray alloc] init];
                    [dict setValue:dictRefs forKey:KEY_FF_REFS];
                }
                NSMutableDictionary *dictForThisDictRef = [[NSMutableDictionary alloc] init];
                [dictForThisDictRef setObject:key                               forKey:@"name"];
                [dictForThisDictRef setObject:@"FFO"                            forKey:@"type"];
                [dictForThisDictRef setObject:[[self metaDataForObj:val] ffUrl] forKey:@"url"];
                [dictRefs addObject:dictForThisDictRef];
            }
            else { // we don't know about this object; store as value
                [dict setValue:[self dictionaryFromObject:val
                                         alreadyProcessed:done
                                                    level:level+1
                                               blobFields:blobFields
                                                    error:error] forKey:key];
                if (*error) return nil;
            }
        }
        continue;
    }
    
    if (debug) NSLog(@"dictionaryFromObject created dictionary %@ from object %@", dict, obj);
    
    return dict;
}

- (id) objectFromDictionary:(NSDictionary *)dict {
    Class class = [self getClassFromClazz:[dict valueForKeyPath:@"clazz"]];
    if (!class) class = objc_lookUpClass("NSMutableDictionary");
    id obj = [[class alloc] init];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [self setMetaDataFromDict:dict forObj:dict];
        if (debug) NSLog(@"objectFromDictionary created object %@ from dictionary %@", dict, dict);
        return dict;
    }
    id refs;
    [self setMetaDataFromDict:dict forObj:obj];    
    NSDictionary *props = [FFUtils propertiesForClass:class];
    for (NSString *key in [dict allKeys]) {
        if ([self isReservedKey:key]) continue;
        id val = [dict valueForKey:key];
        if ([key isEqualToString:KEY_FF_REFS]) { // keep for processing later
            refs = val; continue; }
        NSString *propAttributes = [props objectForKey:key];
        if (! propAttributes) {
            NSLog(@"objectFromDictionary: %@ does not have key %@", class, key);
            continue;
        }
        if (debug) NSLog(@"Trying to set value %@ (type %@) for key %@ (propAttributes %@)",
                         val, [val class], key, propAttributes);
        if ([val isKindOfClass:[NSNull class]])
            continue;
        if ([val isKindOfClass:[NSString class]] ||
            [val isKindOfClass:[NSNumber class]])
        {
            NSString *propClassName = [self classNameForPropAttributes:propAttributes];
            if ([propClassName isEqualToString:@"NSDate"]) {
                if (debug) NSLog(@"objectFromDictionary: setting NSDate value for key %@", key);
                NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:[val doubleValue]/1000.0];                
                [obj setValue:d forKey:key];                
            }
            else {[obj setValue:val forKey:key];}
            continue;
        }
        if ([val isKindOfClass:[NSDictionary class]]) {
            [obj setValue:[self objectFromDictionary:val] forKey:key];            
            continue;
        }
        if ([val isKindOfClass:[NSArray class]]) {
            if ([val count] == 0) {
                [obj setValue: [[NSMutableArray alloc] init] forKey: key];
                continue;
            }
            id first = [val objectAtIndex:0];            
            // If the value looks like an array of primitives, set it
            if ([first isKindOfClass:[NSString class]] ||
                [first isKindOfClass:[NSNumber class]] ||
                [first isKindOfClass:[NSNull class]]) {
                [obj setValue: val forKey: key];
                continue;
            }
            if ([first isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *targetArray = [[NSMutableArray alloc] init];
                [obj setValue: targetArray forKey: key];                
                for (NSDictionary *thisDict in [val objectEnumerator])
                    [targetArray addObject:[self objectFromDictionary:thisDict]];
                continue;
            }
            NSLog(@"objectFromDictionary found an un-handled array value %@ for key %@", val, key);
            continue;
        }
        // We've got to here? Then our JSON-dictionary parsing algorithm is incorrect
        NSLog(@"objectFromDictionary: Found value with un-handled class %@", [val class]);
        continue;
    }
    
    // OK we've iterated over all the keys
    // now let's process the references
    for (id ref in refs) {
        // each ref is a Dictionary with 3 important keys:
        // name: the "field" name; type: FFB:blob, FFO:object, or FFC:collection; url: an ffUrl
        NSString *refFieldName = [ref valueForKey:@"name"];
        // the 'field name' ought to exist in our props dictionary; if it doesn't then log an error and continue
        if (! [props objectForKey:refFieldName] ) {
            NSLog(@"objectFromDictionary: Found a reference called %@ but class %@ doesn't have a property with this name",
                  refFieldName, class);
            continue;
        }
        NSString *refFieldType = [ref valueForKey:@"type"];
        NSString *refFieldUrl  = [ref valueForKey:@"url"];
        // If it's FFB, retrieve it inline
        if ([refFieldType isEqualToString:@"FFB"]) {
            NSString *blobUrlString = [NSString stringWithFormat:@"%@/%@/%@", [self baseUrl],
                                       [[self metaDataForObj:obj] ffUrl], refFieldName];
            NSURL *blobUrl = [[NSURL alloc] initWithString:blobUrlString];
            NSError *blobGetErr;
            NSHTTPURLResponse *blobHR;
            NSData *blobData = [self invokeHttpMethod:@"GET" body:nil bodyIsJson:false onUrl:blobUrl responseIsJson:false
                                                error:&blobGetErr httpResponse:&blobHR];
            if (blobGetErr) NSLog(@"Got error %@ when retrieving blob called %@ from url %@",
                                  [blobGetErr localizedDescription], refFieldName, [blobUrl absoluteString]);
            else {
                if (debug) NSLog(@"Setting BLOB value length %d for field name %@", [blobData length], refFieldName);
                [obj setValue:blobData forKey:refFieldName];
            }
        }
        // If it's FFO, check to see if we have it already
        else if ([refFieldType isEqualToString:@"FFO"]) {
            id knownObject = [references objectForKey:refFieldUrl];
            if (knownObject)
                [obj setValue:knownObject forKey:refFieldName];
            else {
                id newObject = [self getObjFromUrl:refFieldUrl];
                if (newObject)
                    [obj setValue:newObject forKey:refFieldName];
            }
        }
        // If it's FFC, log a message and ignore for now
        else {
            NSLog(@"objectFromDictionary: Found a reference called %@ at url %@ of type %@ not currently handled",
                  refFieldName, refFieldUrl, refFieldType);
            continue;
        }
        
    }
    
    if (debug) NSLog(@"objectFromDictionary created object %@ from dictionary %@", obj, dict);
    
    return obj;
}

@end
