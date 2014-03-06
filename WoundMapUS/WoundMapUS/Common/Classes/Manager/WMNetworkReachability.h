//
//   WMNetworkReachability.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/6/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString *  WMNetworkStatusDidChangeNotification;
extern NSString *  WMCurrentNetworkStatusKey;

typedef enum {
     WMNetworkStatusUnknown = -1,
     WMNetworkStatusNotReachable = 0,
     WMNetworkStatusReachable = 1,
}  WMNetworkStatus;

/**
 `  WMNetworkReachability` provides an interface to monitor the network reachability from the device to FatFractal.
 
 ## Checking the Current Network Status ##
 
 To manually check the current network status, use the <currentNetworkStatus> method.
 
 This method will return an   WMNetworkStatus, defined as:
 
 typedef enum {
   WMNetworkStatusUnknown = -1,
   WMNetworkStatusNotReachable  = 0,
   WMNetworkStatusReachable = 1,
 }   WMNetworkStatus;
 
 
 * Reachable - the device has a network connection and can successfully reach FatFractal.
 * Not Reachable - FatFractal is not reachable either because there is no network connection on the device or the service is down.
 * Unknown - Typically this status arises during in-between times of network connection initialization.
 
 An example of testing reachability before sending a request would look like this:
  WMNetworkReachability * networkMonitor = [ WMNetworkReachability sharedInstance];
 if ([networkMonitor currentNetworkStatus] ==   WMNetworkStatusReachable) {
    // send request
 }
 
 You can also handle each state case by case in a switch statement:
 
 switch([client.session.networkMonitor currentNetworkStatus]) {
    case    WMNetworkStatusReachable:
        // do Reachable stuff
        break;
    case   WMNetworkStatusNotReachable:
        // do NotReachable stuff
        break;
    case   WMNetworkStatusUnknown:
        // do Unknown stuff
        break;
    default:
        break;
 }
 
 
 ## Registering For Network Status Change Notifications ##
 
 You can register to receive notifications when the network status changes by simply adding an observer for the notification name `  WMNetworkStatusDidChangeNotification`.  
 The notification will have a `userInfo` dictionary containing one entry with key `  WMCurrentNetworkStatusKey` and `NSNumber` representing the `  WMNetworkStatus` value.
 
 In order to access the value of `  WMCurrentNetworkStatusKey` in a format for comparing to specific states or use in a switch statement, retrieve the intValue like this:
 
 if ([[[notification userInfo] objectForKey:  WMCurrentNetworkStatusKey] intValue] ==   WMNetworkStatusReachable) {
    // do Reachable stuff
 }
 
 **Important:** Remember to remove your notification observer before the application terminates.
 
 ## Executing a Block Whenever the Network Status Changes ##
 
 You also have the option of setting a block that will be executed every time the network status changes.  To do this, use the <setNetworkStatusChangeBlock:> method like this:
 
 [client.session.networkMonitor setNetworkStatusChangeBlock:^(  WMNetworkStatus status){
 
 // maybe log some stuff
 // maybe notify some objects
 
 }];
 
 
 */

@interface  WMNetworkReachability : AFHTTPClient

/**
 Initializes an instance of ` WMNetworkReachability` which can be used to monitor the network reachability from the device to   WM.
 
 @return A new instance of ` WMNetworkReachability`.
 
 */
+ (instancetype)sharedInstance;

/**
 The current status of the device's network connection and reachability to   WM.
 
 @return Reachable if the device has a network connection and can successfully reach   WM, NotReachable if   WM is not reachable either because there is no network connection on the device or the service is down, Unknown during in-between times of network connection initialization.
 
 */
- ( WMNetworkStatus)currentNetworkStatus;

/**
 Provide a block to execute whenever there is a change in network reachability.
 @param block The block to execute when the network status changes.
 
 */
- (void)setNetworkStatusChangeBlock:(void (^)( WMNetworkStatus status))block;


@end
