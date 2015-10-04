//
//  TBScopeHardwareMock.h
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBScopeHardware.h"

@interface TBScopeHardwareMock : NSObject <TBScopeHardwareDriver>
@property (nonatomic) float xPosition;  // left (-)      / right (+)
@property (nonatomic) float yPosition;  // down (-)      / up (+)
@property (nonatomic) float zPosition;  // focusDown (-) / focusUp (+)
@end
