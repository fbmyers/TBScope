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

@synthesize managedObjectContext;
@synthesize currentSlide, image, analysisResults, diagnosis, slideViewer;
@synthesize slideDiagnosisVC,imageResultsVC;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedString(@"Review Slide", nil);
    
    //TODO: only show image view if user has permission.  also tailor slide diagnosis view accordingly
    
    slideDiagnosisVC = (SlideDiagnosisViewController*)(self.viewControllers[0]);
    slideDiagnosisVC.managedObjectContext = self.managedObjectContext;
    slideDiagnosisVC.currentSlide = self.currentSlide;
    slideDiagnosisVC.currentUser = self.currentUser;
    [slideDiagnosisVC viewWillAppear:NO]; //kludge
    
    imageResultsVC = (ImageResultViewController*)(self.viewControllers[1]);
    imageResultsVC.managedObjectContext = self.managedObjectContext;
    imageResultsVC.currentSlide = self.currentSlide;
    imageResultsVC.currentUser = self.currentUser;
    //[imageResultsVC loadImage:0]; //kludge
    
    //todo: remove this and flesh out imageresultVC (with controls as well)
    //slideViewer = (TBSlideViewer*)(((UIViewController*)self.viewControllers[1]).view.subviews[0]);


    /*
     NSMutableString* debugString = [[NSMutableString alloc] init];
     
     if (imageAnalysisResults==nil)
     {
     debugString = [NSMutableString stringWithString:@"ANALYSIS HAS NOT BEEN PERFORMED"];
     }
     else
     {
     //make the debugString
     [debugString appendFormat:@"Diagnostic Threshold: %f\n", [[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"]];
     [debugString appendFormat:@"Num Patches to Average, N: %d\n", [[NSUserDefaults standardUserDefaults] integerForKey:@"NumPatchesToAverage"]];
     [debugString appendFormat:@"Number of ROIs: %d\n", imageAnalysisResults.imageROIs.count];
     [debugString appendFormat:@"Average of top N scores: %f\n", imageAnalysisResults.score];
     [debugString appendString:@"All ROIs [(x,y): score]\n"];
     
     NSSortDescriptor *sortDescriptor;
     sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score"
     ascending:NO];
     NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
     NSArray *sortedArray;
     sortedArray = [imageAnalysisResults.imageROIs sortedArrayUsingDescriptors:sortDescriptors];
     
     for (ROIs* roi in sortedArray)
     {
     [debugString appendFormat:@"(%d,%d): %f\n",roi.x,roi.y,roi.score];
     }
     }
     
     [debugString appendString:@"Image Metadata:"];
     [debugString appendString:currentImage.metadata];
     
     analysisResults = (UITextView*)(((UIViewController*)self.viewControllers[2]).view.subviews[0]);
     
     analysisResults.text = debugString;
     
     NSLog(@"%@",debugString);
     */
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    // Commit to core data (for comments)
    [self.managedObjectContext save:nil];
}


//TODO: make "back" button go back two screens
- (IBAction)done:(id)sender
{
    
    //commit any notes added here
    self.currentSlide.slideAnalysisResults.notes = slideDiagnosisVC.diagnosisNotesTextView.text;
       
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

@end
