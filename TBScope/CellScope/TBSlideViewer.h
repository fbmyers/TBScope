//
//  TBSlideViewer.h
//  TBSlideViewerTestbed
//
//  Created by Frankie Myers on 11/6/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBSlideViewerSubview.h"
#import "ROI.h"

@interface TBSlideViewer : UIScrollView <UIScrollViewDelegate>

@property (strong,nonatomic) TBSlideViewerSubview* subView;

@property (nonatomic) float imageRotation;

- (void) zoomExtents;
- (void)setImage:(UIImage*)i;

@end
