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
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
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

    // Set custom white balance/iso
    [self setExposureLock:YES];
    [self _setWhiteBalanceGainsFromUserDefaults];
    [self _setExposureAndISOFromUserDefaults];
    
    // Setup still image output
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    //NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, @1.0, AVVideoQualityKey, nil];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];

    // Set up the preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];

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
        AVCaptureFocusMode mode = locked ? AVCaptureFocusModeLocked : AVCaptureFocusModeContinuousAutoFocus;
        if ([self.device isFocusModeSupported:mode]) {
            [self.device setFocusMode:mode];
        } else {
            NSLog(@"Warning: Device does not support focusMode: %ld", (long)mode);
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

- (void)setExposureDuration:(int)milliseconds
                   ISOSpeed:(int)isoSpeed
{
    // I think it unlocks/locks exposure when you set it manually
    // if (self.isExposureLocked) [self setExposureLock:NO];

    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        CMTime exposureDuration = CMTimeMake(milliseconds, 1e3);
        __block TBScopeCameraReal *weakSelf = self;
        [self.device setExposureModeCustomWithDuration:exposureDuration
                                                   ISO:isoSpeed
                                     completionHandler:^(CMTime cmTime){
                                         [weakSelf.device unlockForConfiguration];
                                         // [weakSelf setExposureLock:YES];
                                     }];
    } else {
        NSLog(@"Error: %@",error);
    }
}

-(void)setWhiteBalanceRed:(int)redGain
                    Green:(int)greenGain
                     Blue:(int)blueGain
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        AVCaptureWhiteBalanceGains gains;
        gains.redGain = redGain;
        gains.greenGain = greenGain;
        gains.blueGain = blueGain;
        __block TBScopeCameraReal *weakSelf = self;
        [self.device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:gains
                                                        completionHandler:^(CMTime cmTime){
                                                            [weakSelf.device unlockForConfiguration];
                                                        }];
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
    return self.previewLayer;
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
    // This is a dirty hack to get iOS to keep the ISO and
    // Exposure Duration constant. :-/
    if (rand() % 30 == 0) [self _setExposureAndISOFromUserDefaults];
    [self _sendExposureReport];

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
    contrastAveragingArray[0] = iq.greenContrast;
    iq.movingAverageContrast = (contrastAveragingArray[0] + contrastAveragingArray[1] + contrastAveragingArray[2])/3.0;
    
    self.currentImageQuality = iq;
    
    if (self.focusMode == TBScopeCameraFocusModeSharpness) {
        self.currentFocusMetric = iq.tenengrad3; //iq.movingAverageSharpness;
    } else if (self.focusMode == TBScopeCameraFocusModeContrast) {
        self.currentFocusMetric = iq.greenContrast; //iq.movingAverageContrast;
    }
    
    NSValue *iqAsObject = [NSValue valueWithBytes:&iq objCType:@encode(ImageQuality)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageQualityReportReceived"
                                                        object:self
                                                      userInfo:@{ @"ImageQuality": iqAsObject }];
}

- (void)takeDownCamera
{
    [self stopPreview];
    for(AVCaptureInput *input1 in self.session.inputs) {
        [self.session removeInput:input1];
    }
    for(AVCaptureOutput *output1 in self.session.outputs) {
        [self.session removeOutput:output1];
    }
    self.session = nil;
    self.device = nil;
    self.input = nil;
    self.previewLayer = nil;
    self.stillOutput = nil;
}

- (void)_setWhiteBalanceGainsFromUserDefaults
{
    [self setWhiteBalanceRed:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraWhiteBalanceRedGain"]
                       Green:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraWhiteBalanceGreenGain"]
                        Blue:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraWhiteBalanceBlueGain"]];
}

- (void)_setExposureAndISOFromUserDefaults
{
    int isoSpeed, exposureDuration;
    if (self.focusMode == TBScopeCameraFocusModeSharpness) {  // brightfield
        exposureDuration = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraExposureDurationBF"];
        isoSpeed = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraISOSpeedBF"];
    } else {  // fluorescence
        exposureDuration = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraExposureDurationFL"];
        isoSpeed = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CameraISOSpeedFL"];
    }

    // Limit ISO speed to camera's range
    isoSpeed = MAX(isoSpeed, self.device.activeFormat.minISO);
    isoSpeed = MIN(isoSpeed, self.device.activeFormat.maxISO);
    [self setExposureDuration:exposureDuration
                     ISOSpeed:isoSpeed];
}

- (void)_sendExposureReport
{
    // NSLog(@"Exposure duration: %3.3f; ISO speed: %3.3f", CMTimeGetSeconds(self.device.exposureDuration), self.device.ISO);
}

@end

