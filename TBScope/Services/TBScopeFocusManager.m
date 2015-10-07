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
#import "TBScopeData.h"

@implementation TBScopeFocusManager

- (instancetype)init
{
    if (self = [super init]) {
        // Do additional setup here
    }
    return self;
}

// This algorithm will go numSteps/2 up, then numSteps down, then
// back up to a maximum of numSteps+1 (backlash)
// focusMode 0 = BF, based on tenegrad3 averaged over last 3 frames
// focusMode 1 = FL, based on contrast averaged over last 3 frames
- (BOOL) autoFocusWithStackSize:(int)stackSize
                  stepsPerSlice:(int)stepsPerSlice
                    numAttempts:(int)numAttempts
successiveIterationsGrowRangeBy:(float)growRangeBy
                      focusMode:(int)focusMode
{
    float bfFocusThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"BFFocusThreshold"];
    float flFocusThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"FLFocusThreshold"];
    int focusStepInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"FocusStepInterval"];
    float focusSettlingTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"FocusSettlingTime"];
    
    int state = 1;
    double maxFocus = 0;
    double minFocus = 999999;
    double improvement_threshold;
    
    int currentCycle = 0;
    int numCyclesToGoBack = 0;
    int numIterationsRemaining = numAttempts;
    
    [TBScopeCamera sharedCamera].focusMode = focusMode;
    
    [NSThread sleepForTimeInterval:0.1];
    
    while (state!=0) {
        switch (state) {
            case 1: //reset
                state = 0;
                maxFocus = 0;
                minFocus = 999999;
                currentCycle = 0;
                numCyclesToGoBack = 0;
                state = 2;
                break;
            case 2: //backup
                [[TBScopeHardware sharedHardware] setStepperInterval:focusStepInterval];
                [NSThread sleepForTimeInterval:0.1];
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                   Steps:ceil(stepsPerSlice*stackSize/2)
                                                             StopOnLimit:YES
                                                            DisableAfter:NO];
                [[TBScopeHardware sharedHardware] waitForStage];
                [NSThread sleepForTimeInterval:focusSettlingTime]; //0.1 //0.2 //0.4
                state = 3;
                break;
            case 3: //scan forward
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusDown
                                                                   Steps:stepsPerSlice
                                                             StopOnLimit:YES
                                                            DisableAfter:NO];
                [[TBScopeHardware sharedHardware] waitForStage];
                [NSThread sleepForTimeInterval:focusSettlingTime]; //0.1 //0.2  //0.4
                if ([self currentImageQualityMetric] > maxFocus) {
                    maxFocus = [self currentImageQualityMetric];
                    numCyclesToGoBack = 0;
                    //maxPosition = currentPosition;
                } else {
                    numCyclesToGoBack++;
                }
                
                if ([self currentImageQualityMetric] < minFocus)
                    minFocus = [self currentImageQualityMetric];
                
                currentCycle++;
                if (currentCycle>=stackSize) {
                    currentCycle = 0;
                    state = 4;
                }
                break;
            case 4: //move back to maxfocus position
                //if maxFocus wasn't significantly better than minFocus, go back to original point and do another iteration
                if (focusMode==TBScopeCameraFocusModeSharpness)
                    improvement_threshold = bfFocusThreshold;
                else
                    improvement_threshold = flFocusThreshold;
                
                if ((maxFocus/minFocus)<improvement_threshold) {
                    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                       Steps:stepsPerSlice*stackSize/2
                                                                 StopOnLimit:YES
                                                                DisableAfter:NO];
                    
                    [[TBScopeHardware sharedHardware] waitForStage];
                    [NSThread sleepForTimeInterval:focusSettlingTime]; //0.1 //0.2 //0.4
                    
                    if (numIterationsRemaining>0) {
                        numIterationsRemaining--;
                        stackSize = ceil(stackSize*growRangeBy);
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Could not auto focus, retrying with expanded stack. minFocus=%lf, maxFocus=%lf, mode=%d, stepSize=%d, newStackSize=%d, numIterationsAttempted=%d",minFocus,maxFocus,focusMode,stepsPerSlice,stackSize,(numAttempts-numIterationsRemaining+1)] inCategory:@"CAPTURE"];
                        state = 1;
                    }
                    else {
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Could not auto focus, giving up. minFocus=%lf, maxFocus=%lf, mode=%d, stepSize=%d, finalStackSize=%d, numIterationsAttempted=%d",minFocus,maxFocus,focusMode,stepsPerSlice,stackSize,(numAttempts-numIterationsRemaining+1)] inCategory:@"CAPTURE"];
                        [[TBScopeHardware sharedHardware] disableMotors];
                        return NO;
                    }
                }
                else //move back to maxfocus position
                {
                    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                       Steps:(stepsPerSlice*numCyclesToGoBack)+FOCUS_BACKLASH_CORRECTION
                                                                 StopOnLimit:YES
                                                                DisableAfter:NO];
                    
                    [[TBScopeHardware sharedHardware] waitForStage];
                    [NSThread sleepForTimeInterval:focusSettlingTime]; //0.1 //0.2 //0.4
                    
                    [TBScopeData CSLog:[NSString stringWithFormat:@"Autofocused with minFocus=%lf, maxFocus=%lf, deltaSteps=%d, mode=%d, stepSize=%d, finalStackSize=%d, numIterationsAttempted=%d",minFocus,maxFocus,(stepsPerSlice*numCyclesToGoBack),focusMode,stepsPerSlice,stackSize,(numAttempts-numIterationsRemaining+1)] inCategory:@"CAPTURE"];
                    state = 0; //done
                    [[TBScopeHardware sharedHardware] disableMotors];
                    return YES;
                }
                break;
            default:
                break;
        }
        // NSLog(@"currentCycle=%d currentFocus=%f, maxFocus=%f", currentCycle, [self currentImageQualityMetric], maxFocus);
    }
    [[TBScopeHardware sharedHardware] disableMotors];
    return YES;
}

- (float)currentImageQualityMetric
{
    return [[TBScopeCamera sharedCamera] currentFocusMetric];
}

@end
