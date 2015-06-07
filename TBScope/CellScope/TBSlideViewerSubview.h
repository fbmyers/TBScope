//
//  TBSlideViewerSubview.h
//  TBSlideViewerTestbed
//
//  Created by Frankie Myers on 11/6/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  This subview actually contains the image presented by the TBSlideViewer

#import <UIKit/UIKit.h>

@interface TBSlideViewerSubview : UIView



@property (strong,nonatomic) NSOrderedSet* roiList;
@property (nonatomic) int roiSizeX;
@property (nonatomic) int roiSizeY;
@property (nonatomic) float redThreshold;
@property (nonatomic) float yellowThreshold;
@property (nonatomic) BOOL scoresVisible;
@property (nonatomic) BOOL boxesVisible;
@property (strong,nonatomic) UIImage* image;
@property (nonatomic) float brightness;
@property (nonatomic) float contrast;
@property (nonatomic) float zoomFactor;

- (id)initWithImage:(UIImage*)image;

@end
