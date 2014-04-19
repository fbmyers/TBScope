//
//  MainMenuViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

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

- (IBAction)didPressLogout:(id)sender;

@end
