//
//  TBScopeFocusManager.m
//  TBScope
//
//  Created by Jason Ardell on 10/2/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeFocusManager.h"
#import "TBScopeCamera.h"
#import "TBScopeHardware.h"

@interface TBScopeFocusManager ()
@property (nonatomic) int currentIterationBestPosition;
@property (nonatomic) float currentIterationBestMetric;
@end

@implementation TBScopeFocusManager

@synthesize lastGoodPosition;

- (instancetype)init
{
    if (self = [super init]) {
        // Do additional setup here
        self.lastGoodPosition = -1;
    }
    return self;
}

- (int)zPositionBroadSweepStepsPerSlice
{
    return 500;  // steps
}

- (int)zPositionBroadSweepMax
{
    return 23000;  // steps
}

- (int)zPositionBroadSweepMin
{
    return 13000;  // steps
}

- (float)currentImageQualityMetric
{
    return [[TBScopeCamera sharedCamera] currentFocusMetric];
}

- (TBScopeFocusManagerResult)autoFocus
{
    // Set up
    [self _resetCurrentIterationStats];
    int startingZPosition = [[TBScopeHardware sharedHardware] zPosition];

    // If we have a lastGoodPosition
    if (self.lastGoodPosition >= 0) {
        if ([self _fineFocus] == TBScopeFocusManagerResultSuccess) {
            [self _updateLastGoodPositionAndMetric];
            [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:self.currentIterationBestPosition];
            [[TBScopeHardware sharedHardware] waitForStage];
            return TBScopeFocusManagerResultSuccess;
        }
    }

    // Otherwise start from a very coarse focus and work our way finer
    if ([self _coarseFocus] == TBScopeFocusManagerResultSuccess) {
        [self _fineFocus];
        [self _updateLastGoodPositionAndMetric];
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:self.currentIterationBestPosition];
        [[TBScopeHardware sharedHardware] waitForStage];
        return TBScopeFocusManagerResultSuccess;
    } else if (self.lastGoodPosition >= 0) {
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:self.lastGoodPosition];
        [[TBScopeHardware sharedHardware] waitForStage];
        return TBScopeFocusManagerResultReturn;
    }

    // Utter failure to focus, return to starting position
    [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:startingZPosition];
    [[TBScopeHardware sharedHardware] waitForStage];
    return TBScopeFocusManagerResultFailure;
}

- (TBScopeFocusManagerResult)_coarseFocus
{
    // Start at zPositionBroadSweepMin
    [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:[self zPositionBroadSweepMin]];
    [[TBScopeHardware sharedHardware] waitForStage];

    // For each slice to zPositionBroadSweepMax...
    int stepsPerSlice = [self zPositionBroadSweepStepsPerSlice];
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    int bestPositionSoFar = -1;
    int bestMetricSoFar = -1;
    for (int position=[self zPositionBroadSweepMin]; position <= [self zPositionBroadSweepMax]; position+=stepsPerSlice)
    {
        // Move into position
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:position];
        [[TBScopeHardware sharedHardware] waitForStage];
        [self pauseForSettling];  // does this help reduce blurring?

        // Gather metric
        float metric = [self currentImageQualityMetric];
        if (metric > bestMetricSoFar) {
            bestMetricSoFar = metric;
            bestPositionSoFar = position;
        }
        [samples addObject:[NSNumber numberWithFloat:metric]];
    }

    // If best metric is more than N stdev from mean, go there and return success
    float mean = [self _mean:samples];
    float stdev = [self _stdev:samples];
    if (bestMetricSoFar > mean+2*stdev) {
        [self _recordNewCurrentIterationPosition:bestPositionSoFar Metric:bestMetricSoFar];
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:bestPositionSoFar];
        [[TBScopeHardware sharedHardware] waitForStage];
        return TBScopeFocusManagerResultSuccess;
    } else {
        return TBScopeFocusManagerResultFailure;
    }
}

// Focus within a 2000 step range using hill climbing (resolution 20 steps)
- (TBScopeFocusManagerResult)_fineFocus
{
    // Calculate min and max positions
    int currentPosition = [[TBScopeHardware sharedHardware] zPosition];
    int minPosition = currentPosition - 1000;
    int maxPosition = currentPosition + 1000;

    // Hill climb
    return [self _hillClimbInSlicesOf:20
                   slicesPerIteration:5
                          inDirection:0
                      withMinPosition:minPosition
                          maxPosition:maxPosition];
}

- (TBScopeFocusManagerResult)_hillClimbInSlicesOf:(int)stepsPerSlice
                               slicesPerIteration:(int)slicesPerIteration
                                      inDirection:(int)direction  // -1 is down, 0 is not sure, 1 is up
                                  withMinPosition:(int)minPosition
                                      maxPosition:(int)maxPosition
{
    // If we're outside min/max position, return failure
    int startZPosition = [[TBScopeHardware sharedHardware] zPosition];
    if (startZPosition < minPosition || startZPosition+stepsPerSlice*slicesPerIteration > maxPosition) {
        return TBScopeFocusManagerResultFailure;
    }
    
    // Gather slicesPerIteration successive points starting at start point
    int bestPositionSoFar = -1;
    int bestMetricSoFar = -1;
    NSMutableArray *samples = [NSMutableArray arrayWithArray:@[]];
    for (int i=0; i<slicesPerIteration; ++i) {
        // Move to position
        int targetZPosition = startZPosition + i*stepsPerSlice;
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:targetZPosition];
        [[TBScopeHardware sharedHardware] waitForStage];
        [self pauseForSettling];  // does this help reduce blurring?

        // Gather metric
        float metric = [self currentImageQualityMetric];
        if (metric > bestMetricSoFar) {
            bestMetricSoFar = metric;
            bestPositionSoFar = targetZPosition;
        }
        [samples addObject:[NSNumber numberWithFloat:metric]];
        [self _recordNewCurrentIterationPosition:targetZPosition Metric:metric];
    }

    // Calculate slope of best-fit
    float sumY = 0.0;
    float sumX = 0.0;
    float sumXY = 0.0;
    float sumX2 = 0.0;
    float sumY2 = 0.0;
    for (int i=0; i<[samples count]; ++i) {
        float value = [[samples objectAtIndex:i] floatValue];
        sumX = sumX + i;
        sumY = sumY + value;
        sumXY = sumXY + (i * value);
        sumX2 = sumX2 + (i * i);
        sumY2 = sumY2 + (value * value);
    }
    float slope = (([samples count] * sumXY) - (sumX * sumY)) / (([samples count] * sumX2) - (sumX * sumX));

    // If slope is 0, move to best position and return success
    if (slope == 0.0) {
        return TBScopeFocusManagerResultSuccess;
    }

    // If direction is 0, set direction based on slope
    if (direction == 0) {
        if (slope > 0.0) {
            direction = 1;
        } else {
            direction = -1;
        }
    }

    // If we're climbing up and slope is decreasing
    if (direction > 0 && slope < 0) {
        return TBScopeFocusManagerResultSuccess;
    }

    // If we're climbing down and slope is increasing
    if (direction < 0 && slope > 0) {
        return TBScopeFocusManagerResultSuccess;
    }

    // Record lastGoodMetric/position and continue climbing
    if (direction > 0) {  // If we're climbing up
        // Move stepsPerSlice steps up
        int targetZPosition = startZPosition + slicesPerIteration*stepsPerSlice;
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:targetZPosition];
        [[TBScopeHardware sharedHardware] waitForStage];
    } else {  // If we're climbing down
        // Move stepsPerSlice steps down
        int targetZPosition = startZPosition - slicesPerIteration*stepsPerSlice;
        [[TBScopeHardware sharedHardware] moveToX:-1 Y:-1 Z:targetZPosition];
        [[TBScopeHardware sharedHardware] waitForStage];
    }
    return [self _hillClimbInSlicesOf:stepsPerSlice
                   slicesPerIteration:slicesPerIteration
                          inDirection:direction
                      withMinPosition:minPosition
                          maxPosition:maxPosition];
}

- (void)_recordNewCurrentIterationPosition:(int)position Metric:(float)metric
{
    // Propagate to currentIterationBestPosition/Metric if applicable
    if (metric > self.currentIterationBestMetric) {
        self.currentIterationBestMetric = metric;
        self.currentIterationBestPosition = position;
    }
}

- (void)_resetCurrentIterationStats
{
    self.currentIterationBestPosition = -1;
    self.currentIterationBestMetric = -1.0;
}

- (void)_updateLastGoodPositionAndMetric
{
    self.lastGoodPosition = self.currentIterationBestPosition;
    self.lastGoodMetric = self.currentIterationBestMetric;
}

- (float)_mean:(NSArray *)array
{
    float total = 0.0;
    for (NSNumber *value in array) {
        total = total + [value floatValue];
    }
    return total / [array count];
}

- (float)_stdev:(NSArray *)array
{
    float mean = [self _mean:array];
    float sumOfSquaredDifferences = 0.0;
    for(NSNumber *value in array)
    {
        float difference = [value floatValue] - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    return sqrt(sumOfSquaredDifferences / [array count]);
}

// Not sure whether pausing briefly after moving the lens up/down helps
// get a less noisy image quality metric. We'll set it arbitrarily for
// now, but would be worth some investigation later.
- (void)pauseForSettling
{
    float focusSettlingTime = 0.5;
    [NSThread sleepForTimeInterval:focusSettlingTime];
}

@end
