//
//  ImageResultViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ImageResultViewController.h"



@implementation ImageResultViewController

@synthesize slideViewer,fieldSelector;

- (void) viewWillAppear:(BOOL)animated
{
    //clear field selector
    /*
    while (fieldSelector.numberOfSegments>0)
        [fieldSelector removeSegmentAtIndex:0 animated:NO];
    
    int numFields = (int)self.currentSlide.slideImages.count;

    fieldSelector.hidden = (numFields<=1);
    
    //populate the images
    for (int i=0; i<numFields; i++) {
        [fieldSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d",i+1] atIndex:i animated:NO];
    }
    */
    
    
    
    //set thresholds
    self.slideViewer.subView.redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"RedThreshold"];
    self.slideViewer.subView.yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
    self.roiGridView.redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"RedThreshold"];
    self.roiGridView.yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
    
    self.currentImageIndex = 0;
    
    //this could prob go in storyboard (but it's over top of tab bar)
    self.imageViewModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageViewModeButton.frame = CGRectMake(0.0, 0.0, 150.0, 40.0);
    self.imageViewModeButton.center = CGPointMake(900.0,743.0);
    self.imageViewModeButton.backgroundColor = [UIColor blueColor];
    [self.imageViewModeButton addTarget:self action:@selector(switchImageViewMode) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarController.view addSubview:self.imageViewModeButton];
    [self.view bringSubviewToFront:self.imageViewModeButton];
    
    BOOL analysisHasBeenPerformed = (self.currentSlide.slideAnalysisResults!=nil);
    if (analysisHasBeenPerformed) {

       self.imageViewModeButton.tag = 2;
        self.imageViewModeButton.hidden = NO;

    }
    else {
        self.imageViewModeButton.tag = 1;
        self.imageViewModeButton.hidden = YES;
    }
    
    [self switchImageViewMode];
        
}

- (void)didReceiveMemoryWarning
{
    [TBScopeData CSLog:@"ImageResultViewController received memory warning" inCategory:@"MEMORY"];
}

- (void) switchImageViewMode
{
    UIAlertView* av = [self showWaitIndicator];
    
    if (self.imageViewModeButton.tag==1) {
        [self.imageViewModeButton setTitle:NSLocalizedString(@"Show Patches",nil) forState:UIControlStateNormal];
        self.imageViewModeButton.tag = 2;
        
        //show image view
        self.roiGridView.hidden = YES;
        self.slideViewer.hidden = NO; //TODO: should we delete image data?
        self.leftArrow.hidden = NO;
        self.rightArrow.hidden = NO;
        
        //int fieldIndex = selectedTitle.intValue;
        [self loadImage:self.currentImageIndex completionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [av dismissWithClickedButtonIndex:0 animated:YES];
            });
        }];
        
        self.tabBarController.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Exam %@, Slide %d, Image %d of %ld",nil),
                                                        self.currentSlide.exam.examID,
                                                        self.currentSlide.slideNumber,
                                                        self.currentImageIndex+1,
                                                        self.currentSlide.slideImages.count];
        
        
        [TBScopeData CSLog:@"Image view presented" inCategory:@"USER"];
    }
    else {
        [self.imageViewModeButton setTitle:NSLocalizedString(@"Show Images",nil) forState:UIControlStateNormal];
        self.imageViewModeButton.tag = 1;
        
        //show ROIs
        self.roiGridView.hidden = NO;
        self.slideViewer.hidden = YES;
        self.leftArrow.hidden = YES;
        self.rightArrow.hidden = YES;
        
        self.roiGridView.scoresVisible = YES;
        self.roiGridView.boxesVisible = YES;
        self.roiGridView.selectionVisible = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.roiGridView setSlide:self.currentSlide];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [av dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        self.tabBarController.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Exam %@, Slide %d, Analyzed Patches",nil),
                                     self.currentSlide.exam.examID,
                                     self.currentSlide.slideNumber];
        
        
        [TBScopeData CSLog:@"ROI view presented" inCategory:@"USER"];
    }
}


- (IBAction)didPressArrow:(id)sender
{
    UIAlertView* av = [self showWaitIndicator];
    
    if (sender==self.rightArrow && (self.currentImageIndex<(self.currentSlide.slideImages.count-1)))
        self.currentImageIndex++;
    else if (sender==self.leftArrow && self.currentImageIndex>0)
        self.currentImageIndex--;
    
    [self loadImage:self.currentImageIndex completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [av dismissWithClickedButtonIndex:0 animated:YES];
            
            self.tabBarController.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Exam %@, Slide %d, Image %d of %ld",nil),
                                                          self.currentSlide.exam.examID,
                                                          self.currentSlide.slideNumber,
                                                          self.currentImageIndex+1,
                                                          self.currentSlide.slideImages.count];
        });
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.roiGridView.hasChanges) {
        [TBScopeData touchExam:self.currentSlide.exam];
        [[TBScopeData sharedData] saveCoreData];
    }
    
    [self.imageViewModeButton removeFromSuperview];
    
}


-(UIAlertView*)showWaitIndicator{
    UIAlertView* altpleasewait = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please wait...",nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    
    [altpleasewait show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicator.center = CGPointMake(altpleasewait.bounds.size.width / 2, altpleasewait.bounds.size.height - 50);
    [indicator startAnimating];
    [altpleasewait addSubview:indicator];
    
    return altpleasewait;
}


- (void) loadImage:(int)index completionHandler:(void(^)())completionBlock
{
    //load the image at index currentImageIndex and display w/ ROIs
    
    if (self.currentSlide.slideImages.count<=index) {
        completionBlock();
        return;
    }
    
    Images* currentImage = (Images*)[[self.currentSlide slideImages] objectAtIndex:index];
    
    [TBScopeData getImage:currentImage resultBlock:^(UIImage* image, NSError* err){
        if (err==nil)
        {
            //do the slideViewer settings need to be set after image set?
            [slideViewer setImage:image];
            [slideViewer.subView setRoiList:currentImage.imageAnalysisResults.imageROIs];
            [slideViewer.subView setBoxesVisible:YES];
            [slideViewer.subView setScoresVisible:YES];
            [slideViewer setMaximumZoomScale:10.0];
            [slideViewer setShowsHorizontalScrollIndicator:YES];
            [slideViewer setShowsVerticalScrollIndicator:YES];
            [slideViewer setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
            [slideViewer setNeedsDisplay];

        }
        completionBlock();
    }];
    
    [TBScopeData CSLog:[NSString stringWithFormat:@"Image viewer screen presented, field #%d",currentImage.fieldNumber] inCategory:@"USER"];
}

@end
