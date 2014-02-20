//
//  ResultsViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ResultsTabBarController.h"

//TODO: need to display patient/slide metadata somehow (at least from list)...maybe new tab, or maybe all on 1st tab


@implementation ResultsTabBarController

@synthesize currentExam;
@synthesize slideDiagnosisVC,imageResultsVC;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedString(@"Review Slide", nil);
    
    //TODO: only show image view if user has permission.  also tailor slide diagnosis view accordingly
    
    slideDiagnosisVC = (SlideDiagnosisViewController*)(self.viewControllers[0]);
    slideDiagnosisVC.currentExam = self.currentExam;
    [slideDiagnosisVC viewWillAppear:NO]; //kludge
    
    //TODO: create multiple imageresultVCs
    imageResultsVC = (ImageResultViewController*)(self.viewControllers[1]);
    imageResultsVC.currentSlide = (Slides*)self.currentExam.examSlides[0];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}


//TODO: make "back" button go back two screens
- (IBAction)done:(id)sender
{
    
}

@end
