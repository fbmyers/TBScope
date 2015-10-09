//
//  TBScopeFocusManager.h
//  TBScope
//
//  Created by Jason Ardell on 10/2/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, TBScopeFocusManagerResult)
{
    TBScopeFocusManagerResultSuccess,  // found a new good focus
    TBScopeFocusManagerResultReturn,   // returned to last good position
    TBScopeFocusManagerResultFailure   // failed to focus, no last good position to return to :-(
};

// NOTE: This used to be used when the driver for zPosition had a
// lot of slack in its line. We don't have a problem with backlash
// since switching to a larger motor.
#define FOCUS_BACKLASH_CORRECTION 0 //TODO: make this a config setting

@interface TBScopeFocusManager : NSObject
-(TBScopeFocusManagerResult)autoFocus;
-(int)zPositionBroadSweepMin;
-(int)zPositionBroadSweepMax;
-(float)currentImageQualityMetric;
-(void)pauseForSettling;  // NOTE: only public so we can mock it out in tests
@property (nonatomic) int lastGoodPosition;
@property (nonatomic) float lastGoodMetric;
@end
