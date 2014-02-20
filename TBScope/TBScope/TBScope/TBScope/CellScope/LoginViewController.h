//
//  LoginViewController.h
//  CellScope
//
//  Created by Matthew Bakalar on 9/7/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "MainMenuViewController.h"


@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel* invalidLogin;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)resignAndLogin:(id)sender;

@end
