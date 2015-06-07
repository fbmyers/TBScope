//
//  ResultsViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  This tab bar controller includes 3 sub-viewcontrollers: SlideDiagnosis, ImageResult/ImageROIResult, and FollowUp. These three comprise all the information needed to review a completed exam, and the tab bar controller allows the user to select among them after picking an exam out of the ExamListViewController to review.

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"
#import "TBSlideViewer.h"
#import "SlideDiagnosisViewController.h"
#import "ImageResultViewController.h"
#import "FollowUpViewController.h"

@class CSUserContext;

@interface ResultsTabBarController : UITabBarController

@property (strong,nonatomic) Exams* currentExam;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;



- (IBAction)done:(id)sender;


@end
