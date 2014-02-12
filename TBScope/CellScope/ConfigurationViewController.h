//
//  ConfigurationViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Users.h"

@interface ConfigurationViewController : UITabBarController


@property (strong, nonatomic) Users* currentUser;

@end
