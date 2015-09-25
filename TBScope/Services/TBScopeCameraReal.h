//
//  TBScopeCameraServiceReal.h
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "TBScopeCamera.h"

@interface TBScopeCameraReal : NSObject <TBScopeCameraDriver, AVCaptureVideoDataOutputSampleBufferDelegate>
@end
