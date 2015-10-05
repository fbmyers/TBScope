//
//  TBScopeCamera.m
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeCamera.h"

// If the AllowScanWithoutCellScope flag is set to 1 we'll use the CameraMock
// (for testing without a device). Otherwise we'll use the real camera.
#import "TBScopeCameraReal.h"
#import "TBScopeCameraMock.h"

@implementation TBScopeCamera

+ (id)sharedCamera
{
    static id<TBScopeCameraDriver> sharedCamera;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL simulateScope = [[[NSProcessInfo processInfo] arguments] containsObject:@"-AllowScanWithoutCellScope"];
        if (simulateScope) {
            sharedCamera = [[TBScopeCameraMock alloc] init];
        } else {
            sharedCamera = [[TBScopeCameraReal alloc] init];
        }
    });
    return sharedCamera;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[TBScopeCamera sharedCamera]"];
    return nil;
}

@end
