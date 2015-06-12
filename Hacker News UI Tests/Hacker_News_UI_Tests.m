//
//  Hacker_News_UI_Tests.m
//  Hacker News UI Tests
//
//  Created by Ryan Nystrom on 6/8/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;
@import XCTest;

#import "HNUITestURLProtocol.h"

@interface Hacker_News_UI_Tests : XCTestCase

@end

@implementation Hacker_News_UI_Tests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables.buttons[@"337 comments"] tap];
    [app.tables.staticTexts[@"cpr 5 hours ago"] tap];
    XCTAssert([[[app.tables childrenMatchingType:XCUIElementTypeCell] elementAtIndex:0].staticTexts[@"+"] exists], @"");
}

@end
