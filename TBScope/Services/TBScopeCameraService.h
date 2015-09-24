//
//  TBScopeCameraService.h
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TBScopeCameraService : NSObject
+(instancetype)sharedService;
-(void)setFocusLock:(BOOL)locked;
-(void)setExposureLock:(BOOL)locked;
@end
