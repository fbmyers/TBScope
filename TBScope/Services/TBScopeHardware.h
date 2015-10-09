//
//  TBScopeHardware.h
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    CSStagePositionSlideCenter,
    CSStagePositionZHome
};

@protocol TBScopeHardwareDelegate
@optional
-(void) tbScopeStageMoveDidCompleteWithXLimit:(BOOL)xLimit YLimit:(BOOL)yLimit ZLimit:(BOOL)zLimit;
@required
@end

@protocol TBScopeHardwareDriver
@optional
@required
@property (nonatomic,assign) id <TBScopeHardwareDelegate> delegate;
@property (nonatomic) float batteryVoltage;
@property (nonatomic) float temperature;
@property (nonatomic) float humidity;
@property (nonatomic) int xPosition;  // left (-)      / right (+)
@property (nonatomic) int yPosition;  // down (-)      / up (+)
@property (nonatomic) int zPosition;  // focusDown (-) / focusUp (+)

-(void)moveToPosition:(CSStagePosition)position;
-(void)moveToX:(int)x Y:(int)y Z:(int)z;
-(void)setupBLEConnection;
-(void)requestStatusUpdate;
-(BOOL)isConnected;
-(void)setMicroscopeLED:(CSLED)led Level:(Byte)level;
-(void)disableMotors;
-(void)moveStageWithDirection:(CSStageDirection)dir
                        Steps:(UInt16)steps
                  StopOnLimit:(BOOL)stopOnLimit
                 DisableAfter:(BOOL)disableAfter;
-(void)waitForStage;
-(void)setStepperInterval:(UInt16)stepInterval;
@end

@interface TBScopeHardware : NSObject
+(id<TBScopeHardwareDriver>)sharedHardware;
@end
