//
//  ConfigurationViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Tab bar controller which contains settings, users, an google drive info.

#import <UIKit/UIKit.h>
#import "TBScopeHardware.h"
#import "TBScopeData.h"

@interface ConfigurationViewController : UITabBarController


@property (strong, nonatomic) Users* currentUser;

@end
