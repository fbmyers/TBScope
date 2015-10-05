//
//  TBScopeHardware.m
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeHardware.h"

// If the AllowScanWithoutCellScope flag is set to 1 we'll use the HardwareMock
// (for testing without a device). Otherwise we'll use the real hardware.
#import "TBScopeHardwareReal.h"
#import "TBScopeHardwareMock.h"

@implementation TBScopeHardware

+ (id)sharedHardware
{
    static id<TBScopeHardwareDriver> sharedHardware;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL simulateScope = [[[NSProcessInfo processInfo] arguments] containsObject:@"-AllowScanWithoutCellScope"];
        if (simulateScope) {
            sharedHardware = [[TBScopeHardwareMock alloc] init];
        } else {
            sharedHardware = [[TBScopeHardwareReal alloc] init];
        }
    });
    return sharedHardware;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[TBScopeHardware sharedHardware]"];
    return nil;
}

@end
