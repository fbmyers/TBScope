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
    int numFields = (int)self.currentSlide.slideImages.count;
    
    if (numFields<2)
        fieldSelector.hidden = YES;
    else
    {
        fieldSelector.hidden = NO;
        for (int i=2; i<fieldSelector.numberOfSegments; i++) //clear segments 3, 4, 5...
            [fieldSelector removeSegmentAtIndex:i animated:NO];
        
        for (int i=2; i<numFields; i++)
            [fieldSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d",i+1] atIndex:i animated:NO];
        
        [fieldSelector setSelectedSegmentIndex:0];
    }
    
    [self loadImage:0];
    //TODO: the context needs to be set in the init for these tab views

}

- (IBAction)didChangeFieldSelection:(id)sender
{
    [self loadImage:(int)fieldSelector.selectedSegmentIndex];
    
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
