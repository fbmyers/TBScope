//
//  TBSlideViewer.m
//  TBSlideViewerTestbed
//
//  Created by Frankie Myers on 11/6/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBSlideViewer.h"

@implementation TBSlideViewer

@synthesize subView, imageRotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBouncesZoom:NO];
        [self setBounces:NO];
        [self setScrollEnabled:YES];
        [self setMaximumZoomScale:10.0];
        
        [self setShowsHorizontalScrollIndicator:YES];
        [self setShowsVerticalScrollIndicator:YES];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
    // Drawing code
    
    //if (image)
    //{
    //    [image drawInRect:rect];
    //}
    
    //should this go in drawRect? should these be updated?

    
//}


- (void)setImage:(UIImage*)i
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    subView = [[TBSlideViewerSubview alloc] initWithImage:i];
    //subView = [[TBSlideViewerSubview alloc] initWithFrame:[self bounds]];
    
    [self addSubview:subView];
    [self setContentSize:i.size];
    
    [self setDelegate:self];
    [self zoomExtents];
    
    
    //TODO: are these necessary?
    [subView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return subView;
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView
{
    subView.zoomFactor = self.zoomScale;
    [subView setNeedsDisplay];
}

- (void)setImageRotation:(float)ir
{
    imageRotation = ir;
    [self setTransform:CGAffineTransformMakeRotation(self.imageRotation)];
}

//zooms out so the image fits entirely within the scrollview
//this is called automatically when a new image is loaded
- (void)zoomExtents
{
    float horizZoom = self.bounds.size.width / subView.image.size.width;
    float vertZoom = self.bounds.size.height / subView.image.size.height;
    
    float zoomFactor = MIN(horizZoom,vertZoom);
    
    [self setMinimumZoomScale:zoomFactor];
    
    [self setZoomScale:zoomFactor animated:NO];
    
    subView.zoomFactor = zoomFactor;
    
}

@end
