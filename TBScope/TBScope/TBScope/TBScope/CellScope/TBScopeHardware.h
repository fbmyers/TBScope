//
//  TBScopeHardware.h
//  TBScope
//
//  Created by Frankie Myers on 2/8/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE.h"

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


@property (strong, nonatomic) BLE *ble;

+ (id)sharedHardware;

- (void)setupBLEConnection;

- (void) connectionTimer:(NSTimer *)timer;

- (void) disableMotors;


- (void) moveStageWithDirection:(CSStageDirection) dir
                          Steps:(int)steps
                   DisableAfter:(BOOL)disableAfter;

- (void) setMicroscopeLED:(CSLED) led
                    Level:(Byte) level;

-(void) pairBLECellScope;

@end
