//
//  CameraScrollView.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Presents a live camera view to the user which allows zoom/pan with touch gestures. This VC also includes camera capture functions, exposure/focus controls, and image quality assessment (including focus, contrast, etc.)

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageQualityAnalyzer.h"
#include "cv.h"

@interface CameraScrollView : UIScrollView <UIScrollViewDelegate>
@property (strong,nonatomic) UIView* previewLayerView;
@property (strong,nonatomic) UILabel* imageQualityLabel;
@property (nonatomic) float imageRotation;
@property (nonatomic) double currentFocusMetric;

- (void) setUpPreview;
- (void) takeDownCamera;
- (void) zoomExtents;
- (void) grabImage;
@end
