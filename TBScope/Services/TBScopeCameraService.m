//
//  TBScopeCameraService.m
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeCameraService.h"

@interface TBScopeCameraService ()
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic) BOOL isFocusLocked;
@property (nonatomic) BOOL isExposureLocked;
@end

@implementation TBScopeCameraService

+(instancetype)sharedService
{
    static TBScopeCameraService *sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] initPrivate];
    });
    return sharedService;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[TBScopeCameraService sharedService]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.isFocusLocked = NO;
        self.isExposureLocked = NO;
    }
    return self;
}

- (void)setFocusLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        AVCaptureFocusMode focusMode = locked ? AVCaptureFocusModeLocked : AVCaptureFocusModeContinuousAutoFocus;
        if ([self.device isFocusModeSupported:focusMode]) {
            [self.device setFocusMode:focusMode];
        } else {
            NSLog(@"Warning: Device does not support focusMode: %ld", (long)focusMode);
        }

        self.isFocusLocked = locked;
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"Error: %@",error);
    }
}

- (void)setExposureLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        AVCaptureExposureMode exposureMode = locked ? AVCaptureExposureModeLocked : AVCaptureExposureModeContinuousAutoExposure;
        if ([self.device isExposureModeSupported:exposureMode]) {
            [self.device setExposureMode:AVCaptureExposureModeLocked];
        } else {
            NSLog(@"Warning: Device does not support exposureMode: %ld", (long)exposureMode);
        }

        self.isExposureLocked = locked;
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"Error: %@",error);
    }
}

@end
