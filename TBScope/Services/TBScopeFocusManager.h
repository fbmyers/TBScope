//
//  TBScopeFocusManager.h
//  TBScope
//
//  Created by Jason Ardell on 10/2/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

// What is this for? Seems to be causing autofocus to return incorrect values.
// #define FOCUS_BACKLASH_CORRECTION 10 //TODO: make this a config setting
#define FOCUS_BACKLASH_CORRECTION 0 //TODO: make this a config setting

@interface TBScopeFocusManager : NSObject
-(BOOL)autoFocusWithStackSize:(int)stackSize
                 stepsPerSlice:(int)stepsPerSlice
                   numAttempts:(int)numAttempts
successiveIterationsGrowRangeBy:(float)growRangeBy
                     focusMode:(int)focusMode;
-(float)currentImageQualityMetric;
@end
