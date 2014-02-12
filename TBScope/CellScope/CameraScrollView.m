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
    
    //this is still giving weird behavoir with the boundaries
    
    
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    IplImage* img = [self createIplImageFromSampleBuffer:sampleBuffer];
    
    // assumes that your image is already in planner yuv or 8 bit greyscale
    //IplImage* in = cvCreateImage(cvSize(width,height),IPL_DEPTH_8U,1);
    IplImage* out = cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_16S,1);
    //memcpy(in->imageData,data,width*height);
    
    
    // aperture size of 1 corresponds to the correct matrix
    cvLaplace(img, out, 1);
    
    short maxLap = -32767;
    short* imgData = (short*)out->imageData;
    for(int i =0;i<(out->imageSize/2);i++)
    {
        if(imgData[i] > maxLap) maxLap = imgData[i];
    }
    
    cvReleaseImage(&img);
    cvReleaseImage(&out);
    
    //NSMutableString* strBar = [NSMutableString stringWithString:@""];
    //for(int i=0;i<maxLap;i+=5)
    //    [strBar appendString:@"-"];
    
    //NSLog(strBar);
    
    //why is this crashing w/ back?
    self.currentFocusValue = maxLap;
    
}

//TODO: move this to image proc helper lib
-(IplImage *)createIplImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    IplImage *iplimage = 0;
    IplImage *cropped = 0;
    
    if (sampleBuffer) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // get information of the image in the buffer
        uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bufferWidth = CVPixelBufferGetWidth(imageBuffer);
        size_t bufferHeight = CVPixelBufferGetHeight(imageBuffer);
        
        // create IplImage
        if (bufferBaseAddress) {
            iplimage = cvCreateImage(cvSize(bufferWidth, bufferHeight), IPL_DEPTH_8U, 1);
            iplimage->imageData = (char*)bufferBaseAddress;
            
            //crop it
            cvSetImageROI(iplimage, cvRect(iplimage->width/2-250, iplimage->height/2-250, 500, 500));
            cropped = cvCreateImage(cvGetSize(iplimage),
                                          iplimage->depth,
                                          iplimage->nChannels);
            
            cvCopy(iplimage, cropped, NULL);
            cvResetImageROI(iplimage);
            
            //memcpy(iplimage->imageData, (char*)bufferBaseAddress, iplimage->imageSize);
        }
        
        // release memory
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    else
        NSLog(@"No sampleBuffer!!");
    
    cvReleaseImage(&iplimage);
    
    return cropped;
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
