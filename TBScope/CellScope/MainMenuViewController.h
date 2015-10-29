//
//  MainMenuViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  The main menu that appears after login.

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "EditExamViewController.h"
#import "ExamListViewController.h"
#import "ConfigurationViewController.h"

@interface MainMenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel* loggedInAs;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncSpinner;
@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIButton *scanSlideButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewResultsButton;
@property (weak, nonatomic) IBOutlet UIButton *configurationButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UILabel* bluetoothIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NSTimer* statusUpdateTimer;


- (IBAction)didPressLogout:(id)sender;

@end
