//
//  TBScopeContext.m
//  TBScope
//
//  Created by Frankie Myers on 2/8/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeHardware.h"

BOOL _isMoving = NO;

@implementation TBScopeHardware

@synthesize ble;

+ (id)sharedHardware {
    static TBScopeHardware *newContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newContext = [[self alloc] init];
    });
    return newContext;
}

- (id)init {
    if (self = [super init]) {

        
    }
    return self;
}

- (void)setupBLEConnection {
    
    //todo: handle case where microscope not found
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;

    //connect to BLE devices
    //first disconnect from any current connections
    //this is probably not necessary, just start the timer
    if (ble.activePeripheral)
        if(ble.activePeripheral.isConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    if (ble.peripherals)
        ble.peripherals = nil;
    
    
    [TBScopeData CSLog:@"Searching for Bluetooth CellScope" inCategory:@"HARDWARE"];
    
    //now connect
    [ble findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}

#pragma mark - BLE delegate

- (void)bleDidDisconnect
{
    [ble findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [TBScopeData CSLog:@"Bluetooth Disconnected" inCategory:@"HARDWARE"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothDisconnected" object:nil];
    
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    
}

// When connected, this will be called
-(void) bleDidConnect
{
    [TBScopeData CSLog:@"Bluetooth Connected" inCategory:@"HARDWARE"];
    
    [self setMicroscopeLED:CSLEDBrightfield Level:0];
    [self setMicroscopeLED:CSLEDFluorescent Level:0];
    [self disableMotors];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothConnected" object:nil];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    // parse data, all commands are in 3-byte chunks
    for (int i = 0; i < length; i+=3)
    {
        
        if (data[i] == 0xFF) //all "move completed" messages should start with FF
        {
            BOOL xLimit = ((data[i+1] & 0b00000100)!=0);
            BOOL yLimit = ((data[i+1] & 0b00000010)!=0);
            BOOL zLimit = ((data[i+1] & 0b00000001)!=0);
            
            _isMoving = NO;
            
            //[[self delegate] tbScopeStageMoveDidCompleteWithXLimit:xLimit YLimit:yLimit ZLimit:zLimit];
        }
        else
        {
            NSLog(@"unrecognized response from scope");
        }
    }
}

//This function is called by an NSTimer at 1s interval
//It attempts to connect to BLE device, and auto-retries if it fails
-(void) connectionTimer:(NSTimer *)timer
{
    
    if (ble.peripherals.count > 0)
    {
        for (CBPeripheral* p in ble.peripherals)
        {
            [TBScopeData CSLog:[NSString stringWithFormat:@"CellScope detected w/ UUID: %@",p.identifier.UUIDString]
                    inCategory:@"HARDWARE"];
            
            if ([p.identifier.UUIDString isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeBTUUID"]])
            {
                [ble connectPeripheral:p];
                return;
            }
        }
        
        [TBScopeData CSLog:@"Currently paired CellScope was not detected." inCategory:@"HARDWARE"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bluetooth Connection", nil)
                                                         message:NSLocalizedString(@"A new CellScope has been detected. Pair this iPad with this CellScope?",nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"No",nil)
                                               otherButtonTitles:NSLocalizedString(@"Yes",nil),nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.tag = 1;
        [alert show];
    }
    else
    {
        //try connecting again
        if (ble.activePeripheral)
            if(ble.activePeripheral.isConnected)
            {
                [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
                return;
            }
        
        if (ble.peripherals)
            ble.peripherals = nil;
        
        [ble findBLEPeripherals:2];
        [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
        
    }
}

-(void) pairBLECellScope
{
    if (ble.peripherals.count > 0)
    {
        NSString* newUUID = ((CBPeripheral*)ble.peripherals[0]).identifier.UUIDString;
        
        [[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:@"CellScopeBTUUID"];
        
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        
        [TBScopeData CSLog:[NSString stringWithFormat:@"This iPad is now paired with CellScope Bluetooth UUID: %@",newUUID]
                inCategory:@"HARDWARE"];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //this is the title prompt for new photo/video
    {
        if (buttonIndex==1) {
            [self pairBLECellScope];
        }
    }
}

//stage/led controls (maybe belongs in another file)

-(void) disableMotors
{
    [self moveStageWithDirection:CSStageDirectionDown StepInterval:100 Steps:0 StopOnLimit:NO DisableAfter:YES];
    [self moveStageWithDirection:CSStageDirectionLeft StepInterval:100 Steps:0 StopOnLimit:NO DisableAfter:YES];
    [self moveStageWithDirection:CSStageDirectionFocusUp StepInterval:100 Steps:0 StopOnLimit:NO DisableAfter:YES];

}

- (void) moveStageWithDirection:(CSStageDirection) dir
                          StepInterval:(UInt16)stepInterval
                          Steps:(UInt16)steps
                    StopOnLimit:(BOOL)stopOnLimit
                   DisableAfter:(BOOL)disableAfter
{
    NSLog(@"moving stage");
    _isMoving = YES;
    
    UInt8 buf[3] = {0x00, 0x00, 0x00};
    
    
    //   0   0   1   A   A   D   L   E                           {16 bits}
    // |-----------  ------  --- --- ---||-------------------------||---------------------------|
    //   move cmd     axis   dir lim en                         # steps
    
    buf[0] |= 0b00100000; //move command
    
    switch (dir) {
        case CSStageDirectionUp:
            buf[0] |= 0b00001100;
            break;
        case CSStageDirectionDown:
            buf[0] |= 0b00001000;
            break;
        case CSStageDirectionLeft:
            buf[0] |= 0b00010000;
            break;
        case CSStageDirectionRight:
            buf[0] |= 0b00010100;
            break;
        case CSStageDirectionFocusUp:
            buf[0] |= 0b00011000;
            break;
        case CSStageDirectionFocusDown:
            buf[0] |= 0b00011100;
            break;
    }
    if (stopOnLimit)
        buf[0] |= 0b00000010;
    if (disableAfter)
        buf[0] |= 0b00000001;
    
    //last 2 bytes = # steps
    buf[1] = (UInt8)((steps & 0xFF00) >> 8);
    buf[2] = (UInt8)(steps & 0x00FF);
    
    //send move command
    [ble write:[NSData dataWithBytes:buf length:3]];
    

    //disable
    /*
    if (disableAfter)
    {
        buf[0] = (UInt8)((buf[0] & 0x0F) | 0x30);
        buf[1] = (UInt8)0x00;
        buf[2] = (UInt8)0x00;
        [ble write:[NSData dataWithBytes:buf length:3]];
    }
    */
    
}

- (void) moveToPosition:(CSStagePosition) position
{
    UInt8 buf[3] = {0b01100000, 0x00, 0x00};
    _isMoving = YES;
    
    switch (position) {
        case CSStagePositionHome:
            buf[1] = 0x00;
            break;
        case CSStagePositionTestTarget:
            buf[1] = 0x01;
            break;
        case CSStagePositionSlideCenter:
            buf[1] = 0x02;
            break;
        case CSStagePositionLoading:
            buf[1] = 0x03;
            break;
    }
    
    
    [ble write:[NSData dataWithBytes:buf length:3]];
}

- (void) waitForStage
{
    while (_isMoving)
        [NSThread sleepForTimeInterval:0.05];
    
    //[NSThread sleepForTimeInterval:0.1]; //give stage some time to settle
}

- (void) setMicroscopeLED:(CSLED) led
                    Level:(Byte) level
{
    NSLog(@"setting LED state");
    
    //0x04: LED command
    UInt8 buf[3] = {0b10000000, 0x00, 0x00};
    
    //set LED
    switch (led) {
        case CSLEDFluorescent:
            buf[1] = 0x01;
            break;
        case CSLEDBrightfield:
            buf[1] = 0x02;
            break;
    }
    
    buf[2] = level;
    
    [ble write:[NSData dataWithBytes:buf length:3]];
}

@end
