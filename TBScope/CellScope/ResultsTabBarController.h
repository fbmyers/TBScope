//
//  ResultsViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"
#import "TBSlideViewer.h"
#import "SlideDiagnosisViewController.h"
#import "ImageResultViewController.h"

@class CSUserContext;

@interface ResultsTabBarController : UITabBarController

@property (strong,nonatomic) Exams* currentExam;



- (IBAction)done:(id)sender;


@end
