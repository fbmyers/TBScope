//
//  TBScopeHardware.h
//  TBScope
//
//  Created by Frankie Myers on 2/8/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "BLE.h"
#import "TBScopeData.h"

@protocol TBScopeHardwareDelegate
@optional
-(void) tbScopeStageMoveDidCompleteWithXLimit:(BOOL)xLimit YLimit:(BOOL)yLimit ZLimit:(BOOL)zLimit;
@required
@end

@interface TBScopeHardware : NSObject <BLEDelegate, UIAlertViewDelegate>

typedef NS_ENUM(int, CSStageDirection)
{
    CSStageDirectionUp,
    CSStageDirectionDown,
    CSStageDirectionLeft,
    CSStageDirectionRight,
    CSStageDirectionFocusUp,
    CSStageDirectionFocusDown
};

typedef NS_ENUM(int, CSStageSpeed)
{
    CSStageSpeedStopped,
    CSStageSpeedSlow,
    CSStageSpeedFast
};

typedef NS_ENUM(int, CSLED)
{
    CSLEDFluorescent,
    CSLEDBrightfield
};

typedef NS_ENUM(int, CSStagePosition)
{
    CSStagePositionLoading,
    CSStagePositionHome,
    CSStagePositionTestTarget,
    CSStagePositionSlideCenter
};

@property (strong, nonatomic) BLE *ble;

@property (nonatomic,assign) id <TBScopeHardwareDelegate> delegate;


+ (id)sharedHardware;

- (void)setupBLEConnection;

- (void) connectionTimer:(NSTimer *)timer;

- (void) disableMotors;


- (void) moveStageWithDirection:(CSStageDirection) dir
                          StepInterval:(UInt16)stepInterval
                          Steps:(UInt16)steps
                    StopOnLimit:(BOOL)stopOnLimit
                   DisableAfter:(BOOL)disableAfter;

- (void) moveToPosition:(CSStagePosition)position;

- (void) waitForStage;

- (void) setMicroscopeLED:(CSLED) led
                    Level:(Byte) level;

-(void) pairBLECellScope;


@end
