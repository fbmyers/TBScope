//
//  CameraScrollView.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CameraScrollView.h"
#import "TBScopeCamera.h"

@implementation CameraScrollView

@synthesize previewLayerView;
@synthesize imageRotation;

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
        
        [[TBScopeCamera sharedCamera] setExposureLock:NO];
        [[TBScopeCamera sharedCamera] setFocusLock:NO];
    }
    return self;
}

- (void)setUpPreview
{
    [[TBScopeCamera sharedCamera] setUpCamera];

    // Setup image preview layer
    CGRect frame = CGRectMake(0, 0, 2592, 1936); //TODO: grab the resolution from the camera?
    previewLayerView = [[UIView alloc] initWithFrame:frame];
    CALayer *viewLayer = previewLayerView.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[TBScopeCamera sharedCamera] captureVideoPreviewLayer];
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
    [viewLayer addSublayer:captureVideoPreviewLayer];
    [self addSubview:previewLayerView];
    [self setContentSize:frame.size];
    [self setDelegate:self];
    [self zoomExtents];
    
    // If we're debugging, add a label to display image quality metrics
    self.imageQualityLabel = [[UILabel alloc] init];
    [self addSubview:self.imageQualityLabel];
    [self.imageQualityLabel setBounds:CGRectMake(0,0,400,400)];
    [self.imageQualityLabel setCenter:CGPointMake(1000, 100)];
    self.imageQualityLabel.textColor = [UIColor whiteColor];
    [self bringSubviewToFront:self.imageQualityLabel];
    self.imageQualityLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.imageQualityLabel.numberOfLines = 0;
    self.imageQualityLabel.hidden = YES; //remove for now
    
    //TODO: are these necessary?
    [previewLayerView setNeedsDisplay];
    [self setNeedsDisplay];

    // Listen for ImageQuality updates
    __weak CameraScrollView *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ImageQualityReportReceived"
              object:nil
               queue:[NSOperationQueue mainQueue]
          usingBlock:^(NSNotification *notification) {
              NSValue *iqAsObject = notification.userInfo[@"ImageQuality"];
              ImageQuality iq;
              [iqAsObject getValue:&iq];
              NSString *text = [NSString stringWithFormat:@""
                  "entropy:       %3.3lf\n"
                  "maxval:        %3.0lf\n"
                  "avg sharpness: %3.3lf\n"
                  "avg contrast:  %3.3lf\n"
                  "norm gray var: %@ (%3.3f)\n"
                  "mod lap:       %@ (%3.3f)\n"
                  "var lap:       %@ (%3.3f)\n"
                  "tgrad1:        %@ (%3.3f)\n"
                  "tgrad3:        %@ (%3.3f)\n"
                  "tgrad9:        %@ (%3.3f)\n"
                  "contrast:      %@ (%3.3f)\n\n",
                  iq.entropy,
                  iq.maxVal,
                  iq.movingAverageSharpness,
                  iq.movingAverageContrast,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.normalizedGraylevelVariance/0.08876)) withString: @"|" startingAtIndex:0],
                  iq.normalizedGraylevelVariance,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.modifiedLaplacian/0.08876)) withString: @"|" startingAtIndex:0],
                  iq.modifiedLaplacian,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.varianceOfLaplacian/0.625)) withString: @"|" startingAtIndex:0],
                  iq.varianceOfLaplacian,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.tenengrad1/10.375)) withString: @"|" startingAtIndex:0],
                  iq.tenengrad1,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.tenengrad3/14.375)) withString: @"|" startingAtIndex:0],
                  iq.tenengrad3,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.tenengrad9/1000.0)) withString: @"|" startingAtIndex:0],
                  iq.tenengrad9,
                  [@"" stringByPaddingToLength:(int)MIN(80, (iq.modifiedLaplacian/0.1275)) withString: @"|" startingAtIndex:0],
                  iq.modifiedLaplacian
              ];
              dispatch_async(dispatch_get_main_queue(), ^{
                  // NSLog(@"Image quality report: %@", text);
                  [weakSelf.imageQualityLabel setText:text];
              });
          }
    ];
}

- (void)takeDownCamera
{
    [[TBScopeCamera sharedCamera] takeDownCamera];
    [self.previewLayerView.layer removeFromSuperlayer];
}



- (void) zoomExtents
{
    float horizZoom = self.bounds.size.width / previewLayerView.bounds.size.width;
    float vertZoom = self.bounds.size.height / previewLayerView.bounds.size.height;
    
    float zoomFactor = MIN(horizZoom,vertZoom);
    
    [self setMinimumZoomScale:zoomFactor];
    
    [self setZoomScale:zoomFactor animated:YES];
    
}

- (void) grabImage
{
    [[TBScopeCamera sharedCamera] captureImage];  // TODO: add a completion block instead of processing it up the chain?

    //TODO: now update the field with the captured image and stop preview mode
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return previewLayerView;
}


@end
