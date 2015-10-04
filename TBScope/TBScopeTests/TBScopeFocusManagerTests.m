//
//  TBScopeFocusManagerTests.m
//  TBScope
//
//  Created by Jason Ardell on 10/2/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "TBScopeHardware.h"
#import "TBScopeHardwareMock.h"
#import "TBScopeFocusManager.h"
#import "TBScopeCamera.h"

@interface TBScopeFocusManagerTests : XCTestCase
@end

@implementation TBScopeFocusManagerTests

- (void)setUp {
    [super setUp];

    // Swizzle [TBScopeHardware sharedHardware] to return TBScopeHardwareMock
    [self _toggleSharedHardwareSwizzling];
}

- (void)tearDown {
    // Un-swizzle [TBScopeHardware sharedHardware]
    [self _toggleSharedHardwareSwizzling];

    [super tearDown];
}

- (void)testThatItFindsTheOptimalFocusPosition {
    // Mock out image quality reports depending on hardware positions:
    //   metric = Math.max(0, Math.abs(5 - zPosition)) * 20.0;
    //   zPosition center-1  -> metric 0
    //   zPosition center+0  -> metric 0
    //   zPosition center+1  -> metric 20
    //   zPosition center+2  -> metric 40
    //   zPosition center+3  -> metric 60
    //   zPosition center+4  -> metric 80
    //   zPosition center+5  -> metric 100
    //   zPosition center+6  -> metric 80
    //   zPosition center+7  -> metric 60
    //   zPosition center+8  -> metric 40
    //   zPosition center+9  -> metric 20
    //   zPosition center+10 -> metric 0
    //   zPosition center+11 -> metric 0
    TBScopeFocusManager *focusManager = [[TBScopeFocusManager alloc] init];

    // Call focus
    [self _toggleFocusManagerCurrentImageQualityMetricSwizzling];
    [focusManager autoFocusWithStackSize:12  // NOTE: test fails when this is set at 5. Seems like the algorithm has an edge case where it doesn't store the starting focus.
                           stepsPerSlice:1
                             numAttempts:1
         successiveIterationsGrowRangeBy:1.5
                               focusMode:TBScopeCameraFocusModeSharpness];
    [self _toggleFocusManagerCurrentImageQualityMetricSwizzling];

    // Expect hardware zPosition to end at 5
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    XCTAssertEqual(hardware.zPosition, 5.0);
}

- (void)DISABLED__testThatItRevertsToPreviousPositionIfMetricIsBelowThreshold {
}

- (void)DISABLED__testThatItUsesBestPositionIfMetricIsBelowThresholdAndNoPreviousPositionExists {
}

#pragma private methods

// Make [TBScopeHardware sharedHardware] return TBScopeHardwareMock
- (void)_toggleSharedHardwareSwizzling
{
    Method originalMethod = class_getClassMethod([TBScopeHardware class], @selector(sharedHardware));
    Method swizzledMethod = class_getClassMethod([self class], @selector(_swizzledSharedHardware));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (id)_swizzledSharedHardware
{
    static id<TBScopeHardwareDriver> sharedHardware;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Using swizzled sharedHardware method");
        sharedHardware = [[TBScopeHardwareMock alloc] init];
    });
    return sharedHardware;
}

// Stub out [focusManager currentImageQualityMetric]
- (void)_toggleFocusManagerCurrentImageQualityMetricSwizzling
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(currentImageQualityMetric));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_swizzledFocusManagerCurrentImageQualityMetric));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (float)_swizzledFocusManagerCurrentImageQualityMetric
{
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    float zPosition = [hardware zPosition];
    float imageQualityMetric = MAX(0.0, ABS(5 - zPosition)*-20.0+100.0);
    NSLog(@"zPosition: %2f, metric: %2f", zPosition, imageQualityMetric);
    return imageQualityMetric;
}

@end
