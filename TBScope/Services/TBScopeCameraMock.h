//
//  TBScopeCameraMock.h
//  TBScope
//
//  Created by Jason Ardell on 9/30/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBScopeCamera.h"

@interface TBScopeCameraMock : NSObject <TBScopeCameraDriver, AVCaptureVideoDataOutputSampleBufferDelegate>
@end
