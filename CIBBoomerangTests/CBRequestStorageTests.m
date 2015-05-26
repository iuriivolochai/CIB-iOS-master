//
//  CBRequestStorageTests.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 12/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBRequestStorage.h"

@interface CBRequestStorageTests : XCTestCase

@end

@implementation CBRequestStorageTests

#warning TODO: use test environment

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Log Requests

- (void)testIfRemovesAllLogRequestsAfterFetching
{
    [CBRequestStorage saveLogRequestWithParametrs:@{} forCarnetWithGUID:@"carnet-guid1"];
    [CBRequestStorage saveLogRequestWithParametrs:@{} forCarnetWithGUID:@"carnet-guid2"];
    
    [CBRequestStorage fetchAndDeleteLogRequests];
    
    NSArray *requests = [CBRequestStorage fetchAndDeleteLogRequests];
    XCTAssertTrue([requests count] == 0, @"Log requests array should be empty");
}

- (void)testThatFetchedLogRequestsAreEqualToTheSavedOnes
{
    [CBRequestStorage fetchAndDeleteLogRequests];
    [CBRequestStorage saveLogRequestWithParametrs:@{@"p1": @"v1"} forCarnetWithGUID:@"carnet-guid"];
    [CBRequestStorage saveLogRequestWithParametrs:@{@"p2": @"v2"} forCarnetWithGUID:@"carnet-guid"];
    
    NSArray *requests = [CBRequestStorage fetchAndDeleteLogRequests];
    
    XCTAssertTrue([requests containsObject:@{@"carnet-guid": @{@"p1": @"v1"}}] && [requests containsObject:@{@"carnet-guid": @{@"p2": @"v2"}}], @"Fetched request doesn't equal to the saved");
}

#pragma mark - Common Requests

- (void)testIfRemovesAllRequestsAfterFetching
{
    [CBRequestStorage saveRequestParameters:@{@"p1": @"v1",
                                              @"p2": @"v2"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    [CBRequestStorage saveRequestParameters:@{@"p3": @"v3",
                                              @"p4": @"v4"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    [CBRequestStorage fetchAndDeleteRequestsParametersForPath:@"path" method:@"method" carnetGUID:@"carnet-guid"];
    NSArray *requests = [CBRequestStorage fetchAndDeleteRequestsParametersForPath:@"path" method:@"method" carnetGUID:@"carnet-guid"];
    XCTAssertNil([requests lastObject], @"Fetched requests array should be empty");
}

- (void)testThatFetchedRequestAreEqualToTheSavedOnes
{
    [CBRequestStorage saveRequestParameters:@{@"p1": @"v1",
                                              @"p2": @"v2"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    [CBRequestStorage saveRequestParameters:@{@"p3": @"v3",
                                              @"p4": @"v4"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    [CBRequestStorage fetchAndDeleteRequestsParametersForPath:@"path" method:@"method" carnetGUID:@"carnet-guid"];
    
    [CBRequestStorage saveRequestParameters:@{@"p5": @"v5",
                                              @"p6": @"v6"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    [CBRequestStorage saveRequestParameters:@{@"p7": @"v7",
                                              @"p8": @"v8"} withPath:@"path" method:@"method" carnetWithGUID:@"carnet-guid"];
    
    NSArray *requests = [CBRequestStorage fetchAndDeleteRequestsParametersForPath:@"path" method:@"method" carnetGUID:@"carnet-guid"];
    XCTAssertTrue(([requests containsObject:@{@"p5": @"v5", @"p6": @"v6"}] && [requests containsObject:@{@"p7": @"v7", @"p8": @"v8"}]), @"Fetched requests don't equal to saved ones");
}

@end
