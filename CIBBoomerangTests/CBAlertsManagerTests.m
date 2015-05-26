//
//  CBAlertsManagerTests.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 12/9/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBAlertsManager.h"

@interface CBAlertsManagerTests : XCTestCase

@end

@implementation CBAlertsManagerTests

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

- (void)testThatContainsOnlyAlertTextsThatWereAdded
{
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"Travelling all items alert",
                                                        @"iphone.1002": @"Validation US alert"}
                                     isErrorOccurred:NO];
    
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Stamp], @"", @"CBLocationAlertType_Stamp alert text wasn't added but exists");
}

- (void)testThatAlertTextIsRight
{
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"Travelling all items alert",
                                                        @"iphone.1002": @"Validation US alert"}
                                     isErrorOccurred:NO];
    
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Travelling_All_Items], @"Travelling all items alert", @"Alert text is wrong");
}

- (void)testThatAlertTextEqualsToLastAdded
{
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"Travelling all items alert",
                                                        @"iphone.1002": @"Validation US alert"}
                                     isErrorOccurred:NO];
    
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"New travelling all items alert",
                                                        @"iphone.1002": @"New validation US alert"}
                                     isErrorOccurred:NO];
    
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Travelling_All_Items], @"New travelling all items alert", @"Alert's text doesn't equal to last added");
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Validation_US], @"New validation US alert", @"Alert's text doesn't equal to last added");
}

- (void)testThatDataWithErrorDoesntChangeExistedDataset
{
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"Travelling all items alert",
                                                        @"iphone.1002": @"Validation US alert"}
                                     isErrorOccurred:NO];
    
    [CBAlertsManager updateAlertsPlistFromDictionary:@{ @"iphone.1001": @"New travelling all items alert",
                                                        @"iphone.1002": @"New validation US alert"}
                                     isErrorOccurred:YES];
    
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Travelling_All_Items], @"Travelling all items alert", @"Alert text is wrong");
    XCTAssertEqualObjects([CBAlertsManager textForAlertWithType:CBLocationAlertType_Validation_US], @"Validation US alert", @"Alert text is wrong");
}

- (void)testThatEmptyResponseDoesntCrashApp
{
    XCTAssertNoThrow([CBAlertsManager updateAlertsPlistFromDictionary:nil isErrorOccurred:NO], @"Exception is thrown when empty alerts data were received");
}

- (void)testThatAppWontCrashWhenLogicWouldTryToRetrieveAlertTextAfterEmptyButSuccessfulResponse
{
    [CBAlertsManager updateAlertsPlistFromDictionary:nil isErrorOccurred:NO];
    XCTAssertNoThrow([CBAlertsManager textForAlertWithType:CBAlertType_AiportAlert], @"Exception is thrown when logic tries to get alert text");
}

@end
