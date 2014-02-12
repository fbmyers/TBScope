//
//  ResultsViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBSlideViewer.h"
#import "Users.h"
#import "Slides.h"
#import "ROIs.h"
#import "Images.h"
#import "ImageAnalysisResults.h"
#import "SlideAnalysisResults.h"
#import "SlideDiagnosisViewController.h"
#import "ImageResultViewController.h"

@class CSUserContext;

@interface ResultsTabBarController : UITabBarController


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong,nonatomic) Slides* currentSlide;

//remove these, stick w/ currentslide
//@property (strong, nonatomic) NSMutableArray *roiData;
@property (strong, nonatomic) UIImage* image;

@property (weak, nonatomic) IBOutlet UITextView *analysisResults;
@property (weak, nonatomic) IBOutlet TBSlideViewer* slideViewer;
@property (weak, nonatomic) IBOutlet UITextField *diagnosis;

@property (weak, nonatomic) IBOutlet SlideDiagnosisViewController* slideDiagnosisVC;
@property (weak, nonatomic) IBOutlet ImageResultViewController* imageResultsVC;

- (IBAction)done:(id)sender;


@end
