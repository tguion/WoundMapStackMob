//
//  WoundMapUSTests.m
//  WoundMapUSTests
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WMWoundType.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WoundMapUSTests : XCTestCase

@end

@implementation WoundMapUSTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

- (void)testSeedWoundType
{
//    WMFatFractal *ff = [WMFatFractal sharedInstance];
//    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
//    NSString *uri = [NSString stringWithFormat:@"/%@", [WMWoundType entityName]];
//    NSArray *woundTypes = [ff getArrayFromUri:uri];
//    for (WMWoundType *woundType in woundTypes) {
//        [ff deleteObj:woundType];
//    }
//    id<FFUserProtocol> user = [ff loginWithUserName:@"todd" andPassword:@"todd"];
//    if (nil == user) {
//        XCTFail(@"FF login failed \"%s\"", __PRETTY_FUNCTION__);
//    }
//    // first attempt to acquire data from backend
//    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
//    [WMWoundType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
//        // update backend
//        [ffm createArray:objectIDs collection:[WMWoundType entityName] ff:ff addToQueue:YES reverseEnumerate:YES completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
//            // nothing more to do for children
//            if (error) {
//                [WMUtilities logError:error];
//            } else {
//                NSArray *rootWoundTypes = [ff getArrayFromUri:@"/WMWoundType/parent = null?depthGB=20"];
//                if ([rootWoundTypes count] == 0) {
//                    XCTFail(@"FF failed to fetch from back end \"%s\"", __PRETTY_FUNCTION__);
//                }
//            }
//        }];
//    }];

}

@end
