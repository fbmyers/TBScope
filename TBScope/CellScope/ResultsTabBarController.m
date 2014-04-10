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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Review Exam", nil);
    [[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Results", nil)];
    
    //TODO: only show image view if user has permission.  also tailor slide diagnosis view accordingly
    
    NSMutableArray* tabVCs = [[NSMutableArray alloc] init];
    
    SlideDiagnosisViewController* slideDiagnosisVC = (SlideDiagnosisViewController*)(self.viewControllers[0]);
    slideDiagnosisVC.currentExam = self.currentExam;
    
    [tabVCs addObject:slideDiagnosisVC];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TBScopeStoryboard" bundle: nil];
    
    
    if (self.currentExam.examSlides.count>0) {
        ImageResultViewController *imageResultsVC1 = [storyboard instantiateViewControllerWithIdentifier:@"ImageResultViewController"];
        imageResultsVC1.currentSlide = (Slides*)self.currentExam.examSlides[0];
        imageResultsVC1.tabBarItem.title = [NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),1];
        [tabVCs addObject:imageResultsVC1];
    }
    if (self.currentExam.examSlides.count>1) {
        ImageResultViewController *imageResultsVC2 = [storyboard instantiateViewControllerWithIdentifier:@"ImageResultViewController"];
        imageResultsVC2.currentSlide = (Slides*)self.currentExam.examSlides[1];
        imageResultsVC2.tabBarItem.title = [NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),2];
        [tabVCs addObject:imageResultsVC2];
    }
    if (self.currentExam.examSlides.count>2) {
        ImageResultViewController *imageResultsVC3 = [storyboard instantiateViewControllerWithIdentifier:@"ImageResultViewController"];
        imageResultsVC3.currentSlide = (Slides*)self.currentExam.examSlides[2];
        imageResultsVC3.tabBarItem.title = [NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),3];
        [tabVCs addObject:imageResultsVC3];
    }
    
    self.viewControllers = tabVCs;
    
}



- (IBAction)done:(id)sender
{
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

@end
