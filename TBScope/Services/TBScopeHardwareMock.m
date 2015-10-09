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
            delegate,
            xPosition,
            yPosition,
            zPosition;

- (instancetype)init
{
    if (self = [super init]) {
        self.xPosition = 0;
        self.yPosition = 0;
        self.zPosition = 0;
    }
    return self;
}

- (void) moveToPosition:(CSStagePosition)position
{
    [self _log:@"moveToPosition"];

    switch (position) {
        case CSStagePositionHome:
            self.xPosition = 0;
            self.yPosition = 0;
            break;
        case CSStagePositionZHome:
            self.zPosition = 0;
            break;
        case CSStagePositionLoading:
            // What to do here?
            break;
        case CSStagePositionSlideCenter:
            // What to do here?
            break;
        case CSStagePositionTestTarget:
            // What to do here?
            break;
    }
}

- (void)moveToX:(int)x Y:(int)y Z:(int)z
{
    if (x >= 0) {
        int xSteps = (int)x - self.xPosition;
        if (xSteps > 0) {
            [self moveStageWithDirection:CSStageDirectionRight
                                   Steps:xSteps
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        } else if (xSteps < 0) {
            [self moveStageWithDirection:CSStageDirectionLeft
                                   Steps:ABS(xSteps)
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        }
    }

    if (y >= 0) {
        int ySteps = (int)y - self.yPosition;
        if (ySteps > 0) {
            [self moveStageWithDirection:CSStageDirectionUp
                                   Steps:ySteps
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        } else if (ySteps < 0) {
            [self moveStageWithDirection:CSStageDirectionDown
                                   Steps:ABS(ySteps)
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        }
    }

    if (z >= 0) {
        int zSteps = (int)z - self.zPosition;
        if (zSteps > 0) {
            [self moveStageWithDirection:CSStageDirectionFocusDown
                                   Steps:zSteps
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        } else if (zSteps < 0) {
            [self moveStageWithDirection:CSStageDirectionFocusUp
                                   Steps:ABS(zSteps)
                             StopOnLimit:YES
                            DisableAfter:NO];
            [self waitForStage];
        }
    }

    [[TBScopeHardware sharedHardware] disableMotors];
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

    switch (dir) {
        case CSStageDirectionLeft:
            self.xPosition = self.xPosition - steps;
            break;
        case CSStageDirectionRight:
            self.xPosition = self.xPosition + steps;
            break;
        case CSStageDirectionDown:
            self.yPosition = self.yPosition - steps;
            break;
        case CSStageDirectionUp:
            self.yPosition = self.yPosition + steps;
            break;
        case CSStageDirectionFocusDown:
            self.zPosition = self.zPosition + steps;
            break;
        case CSStageDirectionFocusUp:
            self.zPosition = self.zPosition - steps;
            break;
    }

    NSLog(@"Position changed to (%d, %d, %d).", self.xPosition, self.yPosition, self.zPosition);
}

- (void)waitForStage
{
    [self _log:@"waitForStage"];
    [NSThread sleepForTimeInterval:0.001];  // really short so tests go fast
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
