//
//  CameraScrollView.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#include "cv.h"

@interface CameraScrollView : UIScrollView <UIScrollViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>



@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;


@property (strong,nonatomic) UIView* previewLayerView;

@property (strong,atomic) UIImage* lastCapturedImage;
@property (strong,atomic) NSString* lastImageMetadata;

@property (nonatomic) float imageRotation;

@property (nonatomic) BOOL previewRunning;

@property (nonatomic) BOOL isFocusLocked;
@property (nonatomic) BOOL isExposureLocked;

@property (nonatomic) short currentFocusValue;

- (void) setupCamera;
- (void) takeDownCamera;
- (void) zoomExtents;
- (void) startPreview;
- (void) stopPreview;
- (void) grabImage;

- (void) setExposureLock:(BOOL)locked;
- (void) setFocusLock:(BOOL)locked;


//for focusing
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

-(IplImage *)createIplImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
