//
//  TBScopeCameraServiceReal.m
//  TBScope
//
//  Created by Jason Ardell on 9/24/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeCameraReal.h"

@interface TBScopeCameraReal ()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;
@property (nonatomic) ImageQuality currentImageQuality;
@property (nonatomic) BOOL isFocusLocked;
@property (nonatomic) BOOL isExposureLocked;
@end

@implementation TBScopeCameraReal

@synthesize currentFocusMetric,
            focusMode,
            lastImageMetadata,
            lastCapturedImage,
            isPreviewRunning;

- (instancetype)init
{
    if (self = [super init]) {
        self.isFocusLocked = NO;
        self.isExposureLocked = NO;
    }
    return self;
}

- (void)setUpCamera
{
    // Setup the AV foundation capture session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Setup still image output
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    //NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, @1.0, AVVideoQualityKey, nil];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];
    
    // Add session input and output
    [self.session addInput:self.input];
    [self.session addOutput:self.stillOutput];
    
    // focus preview stuff
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [dataOutput setSampleBufferDelegate:self queue:queue];

    // Set the video output format
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [dataOutput setVideoSettings:videoSettings];
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    [self startPreview];
}

- (void)setFocusLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        AVCaptureFocusMode focusMode = locked ? AVCaptureFocusModeLocked : AVCaptureFocusModeContinuousAutoFocus;
        if ([self.device isFocusModeSupported:focusMode]) {
            [self.device setFocusMode:focusMode];
        } else {
            NSLog(@"Warning: Device does not support focusMode: %ld", (long)focusMode);
        }
        
        self.isFocusLocked = locked;
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"Error: %@",error);
    }
}

- (void)setExposureLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        AVCaptureExposureMode exposureMode = locked ? AVCaptureExposureModeLocked : AVCaptureExposureModeContinuousAutoExposure;
        if ([self.device isExposureModeSupported:exposureMode]) {
            [self.device setExposureMode:AVCaptureExposureModeLocked];
        } else {
            NSLog(@"Warning: Device does not support exposureMode: %ld", (long)exposureMode);
        }
        
        self.isExposureLocked = locked;
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"Error: %@",error);
    }
}

- (void)captureImage
{
    // necessary to loop like this? seems kludgy
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillOutput.connections)
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
    
    NSLog(@"about to request a capture from: %@", self.stillOutput);
    [self.stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
             // TODO: save this data to CD
             NSLog(@"attachements: %@", exifAttachments);
             self.lastImageMetadata = [[NSString alloc] initWithFormat:@"%@",exifAttachments];
         } else {
             NSLog(@"no attachments");
         }
         
         if (imageSampleBuffer==nil) {
             NSLog(@"error with capture: %@",[error description]);
         } else {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             self.lastCapturedImage = [[UIImage alloc] initWithData:imageData];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageCaptured" object:nil];
         }
     }];
}

- (void)clearLastCapturedImage
{
    self.lastCapturedImage = nil;
}

-(AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer
{
    return [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
}

- (void)startPreview
{
    if (!self.isPreviewRunning)
    {
        [self.session startRunning];
        self.isPreviewRunning = YES;
    }
}

- (void)stopPreview
{
    if (self.isPreviewRunning)
    {
        [self.session stopRunning];
        self.isPreviewRunning = NO;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    static double sharpnessAveragingArray[] = {0,0,0};
    static double contrastAveragingArray[] = {0,0,0};
    
    IplImage *iplImage = [ImageQualityAnalyzer createIplImageFromSampleBuffer:sampleBuffer];
    ImageQuality iq = [ImageQualityAnalyzer calculateFocusMetricFromIplImage:iplImage];

    // Sharpness
    //why is this crashing w/ back?
    sharpnessAveragingArray[2] = sharpnessAveragingArray[1];
    sharpnessAveragingArray[1] = sharpnessAveragingArray[0];
    sharpnessAveragingArray[0] = iq.tenengrad3;
    iq.movingAverageSharpness = (sharpnessAveragingArray[0] + sharpnessAveragingArray[1] + sharpnessAveragingArray[2])/3.0;
    
    // Contrast
    contrastAveragingArray[2] = contrastAveragingArray[1];
    contrastAveragingArray[1] = contrastAveragingArray[0];
    contrastAveragingArray[0] = iq.contrast;
    iq.movingAverageContrast = (contrastAveragingArray[0] + contrastAveragingArray[1] + contrastAveragingArray[2])/3.0;
    
    self.currentImageQuality = iq;
    
    if (self.focusMode == TBScopeCameraFocusModeSharpness) {
        self.currentFocusMetric = iq.tenengrad3; //iq.movingAverageSharpness;
    } else if (self.focusMode == TBScopeCameraFocusModeContrast) {
        self.currentFocusMetric = iq.contrast; //iq.movingAverageContrast;
    }
    
    NSValue *iqAsObject = [NSValue valueWithBytes:&iq objCType:@encode(ImageQuality)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageQualityReportReceived"
                                                        object:self
                                                      userInfo:@{ @"ImageQuality": iqAsObject }];
}

- (void)takeDownCamera
{
    [self stopPreview];
    AVCaptureInput* input2 = [self.session.inputs objectAtIndex:0];
    [self.session removeInput:input2];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[self.session.outputs objectAtIndex:0];
    [self.session removeOutput:output];
    self.session = nil;
}

@end

