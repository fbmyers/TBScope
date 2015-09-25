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

-(void)connectionTimer:(NSTimer *)timer;
-(void)pairBLECellScope;
@end
