//
//  SlideListViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Presents a listing of all the exams stored on this iPad. Note that exams in this list weren't necessarily all recorded on this iPad. Google Drive synchronization allows iPads to upload their exams to the shared cloud repository and other iPads can retrieve them. They all show up here.

#import <UIKit/UIKit.h>
#import "TBScopeHardware.h"
#import "TBScopeData.h"
#import "ResultsTabBarController.h"
#import "ExamListTableViewCell.h"
#import "MapViewController.h"
#import "AnalysisViewController.h"

@interface ExamListViewController : UITableViewController <MapViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *examListData;

@property (strong,nonatomic) NSDateFormatter* dateFormatter;
@property (strong,nonatomic) NSDateFormatter* timeFormatter;


@property (weak, nonatomic) IBOutlet UILabel *examNumHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *clinicHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCollectionHeaderLabel;

@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncSpinner;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

- (IBAction)didPressAnalyzeAll:(id)sender;
- (void)runAnalysisOnNextExam;

@end
