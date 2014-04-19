//
//  SlideListViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBScopeHardware.h"
#import "TBScopeData.h"
#import "ResultsTabBarController.h"
#import "ExamListTableViewCell.h"
#import "MapViewController.h"

@interface ExamListViewController : UITableViewController <MapViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *examListData;

@property (strong,nonatomic) NSDateFormatter* dateFormatter;
@property (strong,nonatomic) NSDateFormatter* timeFormatter;

@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncSpinner;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@end
