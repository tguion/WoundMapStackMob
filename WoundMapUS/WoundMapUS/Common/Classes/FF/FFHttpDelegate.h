//
//  FFHttpDelegate.h
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void (^FFHttpMethodCompletion)(NSError *, id, NSHTTPURLResponse *);

@interface FFHttpDelegate : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic)   NSError                 *error;
@property (strong, nonatomic)   NSMutableData           *responseData;
@property (strong, nonatomic)   NSHTTPURLResponse       *httpResponse;
@property (strong, nonatomic)   FFHttpMethodCompletion  onComplete;

- (id) initWithOnComplete:(FFHttpMethodCompletion)onComplete;

/*!
 Need to call this method if you are using self-issued SSL certs.
 By default, "localhost" is a trusted host.
 */
+ (void) addTrustedHost:(NSString *)host;

@end
