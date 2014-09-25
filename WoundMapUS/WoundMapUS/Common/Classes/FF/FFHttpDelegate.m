//
//  HttpDelegate.m
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//

#import "FFHttpDelegate.h"

@implementation FFHttpDelegate

static NSMutableSet * _ffTrustedHosts;

@synthesize responseData, error, httpResponse, onComplete;

+ (void) addTrustedHost:(NSString *)host {
    if (!_ffTrustedHosts) {
        _ffTrustedHosts = [[NSMutableSet alloc] init];
    }
    
    [_ffTrustedHosts addObject:@"localhost"];
    [_ffTrustedHosts addObject:@"developer.fatfractal.com"];
    [_ffTrustedHosts addObject:host];
}

- (id) initWithOnComplete:(FFHttpMethodCompletion)_onComplete {
    self = [super init];
    onComplete = _onComplete;
    
    if (!_ffTrustedHosts) {
        [FFHttpDelegate addTrustedHost:@"localhost"];
        [FFHttpDelegate addTrustedHost:@"developer.fatfractal.com"];
    }
    
    return self;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"canAuthenticateAgainstProtectionSpace %@ called", protectionSpace);
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"didReceiveAuthenticationChallenge %@ called", challenge);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSLog(@"\t\t\tChallenge.protectionSpace.host == %@", challenge.protectionSpace.host);
        BOOL isTrustedHost = [_ffTrustedHosts containsObject:challenge.protectionSpace.host];
        if (isTrustedHost) {
            NSLog(@"\t\t\tHost is a trusted host");
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
        else
            NSLog(@"\t\t\tHost is NOT a trusted host. Use [FFHttpDelegate addTrustedHost]");
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError {
    self.error = theError;
    self.onComplete(error, nil, httpResponse);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    self.httpResponse = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!responseData)
        responseData = [[NSMutableData alloc] init];
    
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.onComplete(nil, responseData, httpResponse);
}

@end
