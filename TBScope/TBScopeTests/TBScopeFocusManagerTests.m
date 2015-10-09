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
@property (strong, nonatomic) TBScopeFocusManager *focusManager;
@end

@implementation TBScopeFocusManagerTests

- (void)setUp {
    [super setUp];

    // Swizzle [TBScopeHardware sharedHardware] to return TBScopeHardwareMock
    [self _toggleSharedHardwareSwizzling];

    // Reset hardware manager position to home
    [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionZHome];

    // Set up focusManager
    self.focusManager = [[TBScopeFocusManager alloc] init];
    self.focusManager.lastGoodPosition = -1;
    [self _toggleFocusManagerPauseForSettlingSwizzling];
}

- (void)tearDown {
    // Un-swizzle [TBScopeHardware sharedHardware]
    [self _toggleSharedHardwareSwizzling];

    [super tearDown];
}

- (void)testThatItReturnsFailureCodeIfItHasNoLastGoodPositionAndBroadSweepFails {
    [self _toggleCurrentImageQualityMetricCurveFlat];
    TBScopeFocusManagerResult result = [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurveFlat];
    
    XCTAssertEqual(result, TBScopeFocusManagerResultFailure);
}

- (void)testThatItReturnsToStartingPositionIfItFailsToFocus {
    int startingZPosition = [[TBScopeHardware sharedHardware] zPosition];

    [self _toggleCurrentImageQualityMetricCurveFlat];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurveFlat];

    int endingZPosition = [[TBScopeHardware sharedHardware] zPosition];
    XCTAssertEqual(startingZPosition, endingZPosition);
}

- (void)testThatItFailsWhenMaxFocusIsOutsideRange {
    [self _toggleCurrentImageQualityMetricCurvePeakOutsideRange];
    TBScopeFocusManagerResult result = [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakOutsideRange];

    XCTAssertEqual(result, TBScopeFocusManagerResultFailure);
}

- (void)testThatItRevertsToLastGoodPositionIfNothingGoodWasFound {
    [self _setLastGoodPositionAndMoveTo:60];
    
    [self _toggleCurrentImageQualityMetricCurveFlat];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurveFlat];
    
    // Expect hardware zPosition to end where it started
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    XCTAssertEqual(hardware.zPosition, 60);
}

- (void)testThatItCoarseFocusesWithoutLastGoodPosition {
    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];

    // Expect hardware zPosition to end at 18000
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    XCTAssertEqual(hardware.zPosition, 18000);
}

- (void)testThatItReturnsSuccessOnSuccessfulFocus {
    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];
    TBScopeFocusManagerResult result = [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];

    XCTAssertEqual(result, TBScopeFocusManagerResultSuccess);
}

- (void)testThatItUpdatesLastGoodPositionOnSuccess {
    self.focusManager.lastGoodPosition = -1;

    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakAt18000];

    XCTAssertEqual(self.focusManager.lastGoodPosition, 18000);
}

- (void)testThatItFindsTheOptimalFocusPositionNearToLastGoodPosition {
    [self _setLastGoodPositionAndMoveTo:18000];

    // Call focus
    [self _toggleCurrentImageQualityMetricCurvePeakAt18120];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakAt18120];

    // Expect hardware zPosition to end at 18120
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    XCTAssertEqual(hardware.zPosition, 18120);
}

- (void)testThatItFineFocusesWithoutLastGoodPosition {
    [self _toggleCurrentImageQualityMetricCurvePeakAt18120];
    [self.focusManager autoFocus];
    [self _toggleCurrentImageQualityMetricCurvePeakAt18120];

    // Expect hardware zPosition to end at 18120
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    XCTAssertEqual(hardware.zPosition, 18120);
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

// Stub out [focusManager currentImageQualityMetric] to be a linear curve
// peaking at 18000 (for coarse focus testing).
//   metric = Math.max(0, Math.abs(18000 - zPosition));
//   ...
//   zPosition 17880 -> metric 0
//   zPosition 17900 -> metric 0
//   zPosition 17920 -> metric 20
//   zPosition 17940 -> metric 40
//   zPosition 17960 -> metric 60
//   zPosition 17980 -> metric 80
//   zPosition 18000 -> metric 100
//   zPosition 18020 -> metric 80
//   zPosition 18040 -> metric 60
//   zPosition 18060 -> metric 40
//   zPosition 18080 -> metric 20
//   zPosition 18100 -> metric 0
//   zPosition 18120 -> metric 0
//   zPosition 18140 -> metric 0
//   ...
- (void)_toggleCurrentImageQualityMetricCurvePeakAt18000
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(currentImageQualityMetric));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_imageQualityCurvePeakAt18000));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (float)_imageQualityCurvePeakAt18000
{
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    float zPosition = [hardware zPosition];
    float imageQualityMetric = MAX(0.0, ABS(18000 - zPosition)*-1.0+100.0);
    NSLog(@"zPosition: %2f, metric: %2f", zPosition, imageQualityMetric);
    return imageQualityMetric;
}

// Stub out [focusManager currentImageQualityMetric] to be a linear curve
// peaking at 18020 (for fine focus testing)
//   metric = Math.max(0, Math.abs(18120 - zPosition));
//   ...
//   zPosition 17080 -> metric 860
//   zPosition 18000 -> metric 880
//   zPosition 18020 -> metric 900
//   zPosition 18040 -> metric 920
//   zPosition 18060 -> metric 940
//   zPosition 18080 -> metric 960
//   zPosition 18100 -> metric 980
//   zPosition 18120 -> metric 1000
//   zPosition 18140 -> metric 980
//   zPosition 18160 -> metric 960
//   zPosition 18180 -> metric 940
//   zPosition 18200 -> metric 920
//   zPosition 18220 -> metric 900
//   zPosition 18240 -> metric 880
//   ...
- (void)_toggleCurrentImageQualityMetricCurvePeakAt18120
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(currentImageQualityMetric));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_imageQualityCurvePeakAt18120));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (float)_imageQualityCurvePeakAt18120
{
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    float zPosition = [hardware zPosition];
    float imageQualityMetric = MAX(0.0, ABS(18120 - zPosition)*-1.0+1000.0);
    NSLog(@"zPosition: %2f, metric: %2f", zPosition, imageQualityMetric);
    return imageQualityMetric;
}

// Stub out [focusManager currentImageQualityMetric] to be flat
- (void)_toggleCurrentImageQualityMetricCurveFlat
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(currentImageQualityMetric));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_imageQualityCurveFlat));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (float)_imageQualityCurveFlat
{
    return 0.0;
}

// Stub out [focusManager currentImageQualityMetric] to be flat
- (void)_toggleCurrentImageQualityMetricCurvePeakOutsideRange
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(currentImageQualityMetric));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_imageQualityCurveFlat));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (float)_imageQualityCurvePeakOutsideRange
{
    TBScopeHardwareMock *hardware = (TBScopeHardwareMock *)[TBScopeHardware sharedHardware];
    float zPosition = [hardware zPosition];
    if (zPosition < [self.focusManager zPositionBroadSweepMin]) {
        return 0;
    } else if (zPosition > [self.focusManager zPositionBroadSweepMax]) {
        return 0;
    } else {
        int peak = [self.focusManager zPositionBroadSweepMax] + 5000;
        float imageQualityMetric = MAX(0.0, ABS(peak - zPosition)*-1.0+100.0);
        return imageQualityMetric;
    }
}

- (void)_toggleFocusManagerPauseForSettlingSwizzling
{
    Method originalMethod = class_getInstanceMethod([TBScopeFocusManager class], @selector(pauseForSettling));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_pauseForSettling));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)_pauseForSettling
{
    // Do nothing, it's really fast!
}

- (void)_setLastGoodPositionAndMoveTo:(int)zPosition
{
    [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:zPosition];
    self.focusManager.lastGoodPosition = zPosition;
}

@end
