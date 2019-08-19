//
//  SungroupTests.m
//  SungroupTests
//
//  Created by DUY TAN on 18/3/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"
@interface SungroupTests : XCTestCase
@property (nonatomic) ViewController * vcToTest;
@end

@implementation SungroupTests

- (void)setUp {
    [super setUp];
    self.vcToTest = [[ViewController alloc]init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
