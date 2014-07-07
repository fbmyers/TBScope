//
//  CameraScrollView.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CameraScrollView.h"


@implementation CameraScrollView

@synthesize session,device,input,stillOutput;
@synthesize previewLayerView;
@synthesize imageRotation,previewRunning;
@synthesize lastCapturedImage;

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
        
        [self setExposureLock:NO];
        [self setFocusLock:NO];
        
    }
    return self;
}


- (void) setupCamera
{
    
    
    
    // Setup the AV foundation capture session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
    
    // Setup image preview layer
    CGRect frame = CGRectMake(0, 0, 2592, 1936); //TODO: grab the resolution from the camera?
    
    previewLayerView = [[UIView alloc] initWithFrame:frame];
    CALayer *viewLayer = previewLayerView.layer;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
        
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    
    captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
    
    [viewLayer addSublayer:captureVideoPreviewLayer];
    
    [self addSubview:previewLayerView];
    [self setContentSize:frame.size];
    [self setDelegate:self];
    [self zoomExtents];
    
    //if we're debugging, add a label to display image quality metrics
    self.imageQualityLabel = [[UILabel alloc] init];
    [self addSubview:self.imageQualityLabel];
    [self.imageQualityLabel setBounds:CGRectMake(0,0,400,400)];
    [self.imageQualityLabel setCenter:CGPointMake(1000, 100)];
    self.imageQualityLabel.textColor = [UIColor whiteColor];
    [self bringSubviewToFront:self.imageQualityLabel];
    self.imageQualityLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.imageQualityLabel.numberOfLines = 0;
    
    // Setup still image output
    
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];
    
    
    // Add session input and output
    [self.session addInput:self.input];
    [self.session addOutput:self.stillOutput];
    
    
    // focus preview stuff
    AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
    dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if ( [self.session canAddOutput:dataOutput] )
        [self.session addOutput:dataOutput];
        
        dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
        [dataOutput setSampleBufferDelegate:self queue:queue];
    
    
    
    
    [self startPreview];
    
    //TODO: are these necessary?
    [previewLayerView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)takeDownCamera
{
    if([session isRunning])[session stopRunning];
    
    AVCaptureInput* input2 = [session.inputs objectAtIndex:0];
    
    [session removeInput:input2];
    
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[session.outputs objectAtIndex:0];
    
    [session removeOutput:output];
    
    [self.previewLayerView.layer removeFromSuperlayer];
    
    
    self.session = nil;
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    static double averagingArray[] = {0,0,0};
    

    ImageQuality iq = [ImageQualityAnalyzer calculateFocusMetric:sampleBuffer];
    
    
    //NSLog(@"%lf",iq.contrast);
    /*
    NSMutableString* strBar = [NSMutableString stringWithString:@""];
    for(int i=0;i<iq.movingAverageSharpness;i+=10)
        [strBar appendString:@"-"];
    
    NSLog(strBar);
    */
    
    //why is this crashing w/ back?
    averagingArray[2] = averagingArray[1];
    averagingArray[1] = averagingArray[0];
    averagingArray[0] = iq.tenengrad3;
    
    iq.movingAverageSharpness = (averagingArray[0] + averagingArray[1] + averagingArray[2])/3.0;
    
    self.currentImageQuality = iq;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageQualityLabel setText:[NSString stringWithFormat:@"entropy: %3.3lf\nmod lap: %3.3lf\nnorm gray var: %3.3lf\nvar lap: %3.3lf\ntgrad1: %3.3lf\ntgrad3: %3.3lf\ntgrad9: %3.3lf\navg sharpness: %3.3lf",
                                        iq.entropy,
                                        iq.modifiedLaplacian,
                                        iq.normalizedGraylevelVariance,
                                        iq.varianceOfLaplacian,
                                        iq.tenengrad1,
                                        iq.tenengrad3,
                                        iq.tenengrad9,
                                         iq.movingAverageSharpness]];
    });
}


- (void) zoomExtents
{
    float horizZoom = self.bounds.size.width / previewLayerView.bounds.size.width;
    float vertZoom = self.bounds.size.height / previewLayerView.bounds.size.height;
    
    float zoomFactor = MIN(horizZoom,vertZoom);
    
    [self setMinimumZoomScale:zoomFactor];
    
    [self setZoomScale:zoomFactor animated:YES];
    
}

- (void)setExposureLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        if (locked)
            [self.device setExposureMode:AVCaptureExposureModeLocked];
        else
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        self.isExposureLocked = locked;
        [self.device unlockForConfiguration];
    }
    else
        NSLog(@"Error: %@",error);
    
}

- (void)setFocusLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        if (locked)
            [self.device setFocusMode:AVCaptureFocusModeLocked];
        else
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        self.isFocusLocked = locked;
        [self.device unlockForConfiguration];
    }
    else
        NSLog(@"Error: %@",error);
}

- (void) startPreview
{
    [self.session startRunning];
    previewRunning = YES;
}

- (void) stopPreview
{
    [self.session stopRunning];
    previewRunning = NO;
}

- (void) grabImage
{
    
     //necessary to loop like this? seems kludgy
     AVCaptureConnection *videoConnection = nil;
     for (AVCaptureConnection *connection in stillOutput.connections)
     {
         for (AVCaptureInputPort *port in [connection inputPorts])
         {
             if ([[port mediaType] isEqual:AVMediaTypeVideo] )
             {
                 videoConnection = connection;
                 break;
             }
         }
         if (videoConnection) { break; }
     }
     
     self.lastCapturedImage = nil;
     self.lastImageMetadata = nil;
    
     NSLog(@"about to request a capture from: %@", stillOutput);
     [stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             //TODO: save this data to CD
             NSLog(@"attachements: %@", exifAttachments);
             self.lastImageMetadata = [[NSString alloc] initWithFormat:@"%@",exifAttachments];
         }
         else
             NSLog(@"no attachments");
         
         
         if (imageSampleBuffer==nil)
         {
             NSLog(@"error with capture: %@",[error description]);
         }
         else
         {
             //extract green channel only
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             self.lastCapturedImage = [[UIImage alloc] initWithData:imageData];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageCaptured" object:nil];
         }
         
     }];
    


    
    //TODO: now update the field with the captured image and stop preview mode
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return previewLayerView;
}


@end
