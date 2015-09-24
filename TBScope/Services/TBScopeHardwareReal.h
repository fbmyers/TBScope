//
//  TBScopeHardwareReal.h
//  TBScope
//
//  Created by Frankie Myers on 2/8/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TBScopeHardware.h"
#import "BLE.h"
#import "TBScopeData.h"

@interface TBScopeHardwareReal : NSObject <TBScopeHardwareDriver, BLEDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) BLE *ble;

@property (nonatomic,assign) id <TBScopeHardwareDelegate> delegate;


- (void)setupBLEConnection;

- (void) connectionTimer:(NSTimer *)timer;

- (void) disableMotors;

- (void) requestStatusUpdate;

- (void) setStepperInterval:(UInt16)stepInterval;

- (void) moveStageWithDirection:(CSStageDirection) dir
                          Steps:(UInt16)steps
                    StopOnLimit:(BOOL)stopOnLimit
                   DisableAfter:(BOOL)disableAfter;

- (void) moveToPosition:(CSStagePosition)position;

- (void) waitForStage;

- (void) setMicroscopeLED:(CSLED) led
                    Level:(Byte) level;

-(void) pairBLECellScope;


@end
