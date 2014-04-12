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
    while (fieldSelector.numberOfSegments>0)
        [fieldSelector removeSegmentAtIndex:0 animated:NO];
    
    int numFields = (int)self.currentSlide.slideImages.count;
    BOOL analysisHasBeenPerformed = (self.currentSlide.slideAnalysisResults!=nil);
    fieldSelector.hidden = (numFields<=1);
    
    //populate the images
    for (int i=0; i<numFields; i++) {
        [fieldSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d",i+1] atIndex:i animated:NO];
    }
    
    //add the option for ROI view
    if (analysisHasBeenPerformed) {
        [fieldSelector insertSegmentWithTitle:@"ROI" atIndex:0 animated:NO];
    }
    
    //trigger the field selector to load the first image
    [fieldSelector setSelectedSegmentIndex:0];
    [self didChangeFieldSelection:nil];
    
    //[self loadImage:0];
    
    //set thresholds
    self.slideViewer.subView.redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"RedThreshold"];
    self.slideViewer.subView.yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
    self.roiGridView.redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"RedThreshold"];
    self.roiGridView.yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
    

}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.roiGridView.hasChanges) {
        [TBScopeData touchExam:self.currentSlide.exam];
        [[TBScopeData sharedData] saveCoreData];
    }
}

- (IBAction)didChangeFieldSelection:(id)sender
{
    NSString* selectedTitle = [fieldSelector titleForSegmentAtIndex:fieldSelector.selectedSegmentIndex];
    if ([selectedTitle isEqualToString:@"ROI"])
    {
        self.roiGridView.hidden = NO;
        self.slideViewer.hidden = YES;
        
        self.roiGridView.scoresVisible = YES;
        self.roiGridView.boxesVisible = YES;
        self.roiGridView.selectionVisible = YES;
        
        [self.roiGridView setSlide:self.currentSlide];
        
    }
    else //assume it's a number indicating the field
    {
        self.roiGridView.hidden = YES;
        self.slideViewer.hidden = NO; //TODO: should we delete image data?
        
        int fieldIndex = selectedTitle.intValue;
        [self loadImage:fieldIndex-1];
        
    }
}

- (void) loadImage:(int)index
{
    //load the image at index currentImageIndex and display w/ ROIs
    
    if (self.currentSlide.slideImages.count<=index) {
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
    }];
    
    [TBScopeData CSLog:[NSString stringWithFormat:@"Image viewer screen presented, field #%d",currentImage.fieldNumber] inCategory:@"USER"];
}

@end
