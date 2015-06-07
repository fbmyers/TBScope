//
//  LogViewController.h
//  TBScope
//
//  Created by Frankie Myers on 10/10/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Presents a listing of the logs entries on this iPad.

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "LogEntryCell.h"
#import "LogEntryDetailViewController.h"

@interface LogViewController : UITableViewController

@property (strong, nonatomic) NSArray *logData;

@property (strong,nonatomic) NSDateFormatter* dateFormatter;
@property (strong,nonatomic) NSDateFormatter* timeFormatter;

@property (weak, nonatomic) IBOutlet UIButton *userFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *hardwareFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *syncFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *systemFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *analysisFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *errorFilterButton;

@property (weak, nonatomic) IBOutlet UIView *filterBarView;

- (IBAction)didPressFilterButton:(id)sender;

@end
