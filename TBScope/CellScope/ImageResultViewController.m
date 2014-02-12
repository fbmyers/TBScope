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
    int numFields = self.currentSlide.slideImages.count;
    
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
    [self loadImage:fieldSelector.selectedSegmentIndex];
    
}

- (void) loadImage:(int)index
{
    //load the image at index currentImageIndex and display w/ ROIs
    
    //TODO: convert this to allow for multiple images/slide level diagnosis
    //TODO: make sure currentslide not null, and that it has images
    //for some reason, when we defer analysis, this returns zero images
    
    if (self.currentSlide.slideImages.count<=index) {
        return;
    }
    
    Images* currentImage = (Images*)[[[self.currentSlide slideImages] allObjects] objectAtIndex:index];
    
    //TODO: can we package this into a getImageFromURL method? used in both analysis and results (blocking)
    NSURL *aURL = [NSURL URLWithString:currentImage.path]; //TODO: check that this is a valid url to an image (see example code on stackoverflow)
    
    if ([[aURL scheme] isEqualToString:@"assets-library"])
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             ALAssetRepresentation* rep = [asset defaultRepresentation];
             CGImageRef iref = [rep fullResolutionImage];
             
             UIImage* image = [UIImage imageWithCGImage:iref];
             
             
             //will likely remove this, unless we need it for debugging
             
             //TODO: all the visualization settings (red/green, patch sz) should be set, and also should be tied to GUI elements
             //TODO: image analysis results should include analysis settings?
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
                failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"failure-----");
         }];
    }
    else //this picture is in the bundle
    {
        UIImage* image = [UIImage imageNamed:currentImage.path];
        
        //TODO: refactor so no code duplication...do the slideViewer settings need to be set after image set?
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
}

@end
