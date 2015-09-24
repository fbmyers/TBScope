//
//  TBScopeHardwareMock.m
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeHardwareMock.h"

@implementation TBScopeHardwareMock

@synthesize batteryVoltage,
            temperature,
            humidity,
            delegate;

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void) moveToPosition:(CSStagePosition)position
{
    [self _log:@"moveToPosition"];
}

- (void)setupBLEConnection
{
    [self _log:@"setupBLEConnection"];
}

-(void)requestStatusUpdate
{
    [self _log:@"requestStatusUpdate"];

    // Trigger the notifications that BLE would send
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.batteryVoltage = 1.5;
        NSLog(@"battery = %f", self.batteryVoltage);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUpdated" object:nil];
    });
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.temperature = 25.0;
        NSLog(@"temp = %f", self.temperature);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUpdated" object:nil];
    });
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.humidity = 30.0;
        NSLog(@"humidity = %f", self.humidity);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUpdated" object:nil];
    });
}

- (BOOL)isConnected
{
    [self _log:@"isConnected"];
    // TODO: have this track a private variable that gets set to true
    // when the proper setup ceremony is completed.
    return true;
}

- (void)setMicroscopeLED:(CSLED)led
                   Level:(Byte)level
{
    [self _log:@"setMicroscopeLED:Level:"];
}

- (void)disableMotors
{
    [self _log:@"disableMotors"];
    // TODO: do we need to track the enabled state of the motors?
}

- (void)moveStageWithDirection:(CSStageDirection)dir
                        Steps:(UInt16)steps
                  StopOnLimit:(BOOL)stopOnLimit
                 DisableAfter:(BOOL)disableAfter
{
    [self _log:@"moveStageWithDirection:Steps:StopOnLimit:DisableAfter"];
}

- (void)waitForStage
{
    [self _log:@"waitForStage"];
    [NSThread sleepForTimeInterval:0.1];
}

- (void)setStepperInterval:(UInt16)stepInterval
{
    [self _log:@"setStepperInterval"];
}

#pragma mark - private methods

- (void)_log:(NSString *)message
{
    NSLog(@"%@ >> %@", @"Hardware Mock", message);
}

@end
