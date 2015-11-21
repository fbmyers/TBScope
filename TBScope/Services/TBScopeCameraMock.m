//
//  TBScopeCameraMock.m
//  TBScope
//
//  Created by Jason Ardell on 9/30/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeCameraMock.h"
#import "TBScopeHardware.h"

@interface TBScopeCameraMock ()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;
@property (nonatomic) ImageQuality currentImageQuality;
@property (nonatomic, strong) NSTimer *imageQualityTimer;
@property (nonatomic) BOOL isFocusLocked;
@property (nonatomic) BOOL isExposureLocked;
@end

@implementation TBScopeCameraMock

@synthesize currentFocusMetric,
            focusMode,
            isPreviewRunning,
            lastCapturedImage,
            lastImageMetadata;

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
    [self _log:@"setUpCamera"];

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
    AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
    dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [dataOutput setSampleBufferDelegate:self queue:queue];
    
    [self startPreview];

    // Fire off periodic image quality reports
    self.imageQualityTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                              target:self
                                                            selector:@selector(_fireImageQualityReport)
                                                            userInfo:nil
                                                             repeats:YES];
}

- (void)setFocusLock:(BOOL)locked
{
    [self _log:@"setFocusLock"];

    self.isFocusLocked = locked;
}

- (void)setExposureLock:(BOOL)locked
{
    [self _log:@"setExposureLock"];

    self.isExposureLocked = locked;
}

- (void)setExposureDuration:(int)milliseconds
                   ISOSpeed:(int)isoSpeed
{
    [self _log:@"setExposureDuration:ISOSpeed:"];
}

-(void)setWhiteBalanceRed:(int)redGain
                    Green:(int)greenGain
                     Blue:(int)blueGain
{
    [self _log:@"setWhiteBalanceRed:Green:Blue:"];
}

- (void)captureImage
{
    [self _log:@"captureImage"];

    // Update lastCapturedImage with mock images
    NSString *fileName;
    if (self.focusMode == TBScopeCameraFocusModeSharpness) {  // BF
        fileName = @"bf_mock";
    } else {  // FL
        fileName = @"fl_mock";
    }
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"jpg"];
    self.lastCapturedImage = [UIImage imageWithContentsOfFile:filePath];

    // Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageCaptured" object:nil];
}

- (void)clearLastCapturedImage
{
    [self _log:@"clearLastCapturedImage"];

    self.lastCapturedImage = nil;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer
{
    [self _log:@"captureVideoPreviewLayer"];

    return [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
}

- (void)startPreview
{
    [self _log:@"startPreview"];

    if (!self.isPreviewRunning)
    {
        [self.session startRunning];
        self.isPreviewRunning = YES;
    }
}

- (void)stopPreview
{
    [self _log:@"stopPreview"];

    if (self.isPreviewRunning)
    {
        [self.session stopRunning];
        self.isPreviewRunning = NO;
    }
}

- (void)takeDownCamera
{
    [self _log:@"takeDownCamera"];

    // Cancel periodic image quality reports
    [self.imageQualityTimer invalidate];
    self.imageQualityTimer = nil;

    [self stopPreview];
    AVCaptureInput* input2 = [self.session.inputs objectAtIndex:0];
    [self.session removeInput:input2];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[self.session.outputs objectAtIndex:0];
    [self.session removeOutput:output];
    self.session = nil;
}

#pragma mark - private methods

- (void)_fireImageQualityReport
{
    int focusedZPosition = 18120;
    int currentZPosition = [[TBScopeHardware sharedHardware] zPosition];
    double currentFocus = MAX(0.0, ABS(focusedZPosition - currentZPosition)*-1.0+1000.0);

    ImageQuality iq;
    iq.normalizedGraylevelVariance = 0;
    iq.varianceOfLaplacian = 0;
    iq.modifiedLaplacian = 0;
    iq.tenengrad1 = 0;
    iq.tenengrad3 = currentFocus;
    iq.tenengrad9 = 0;
    iq.movingAverageSharpness = 0;
    iq.movingAverageContrast = 0;
    iq.entropy = 0;
    iq.maxVal = 0;
    iq.contrast = 0;
    iq.greenContrast = currentFocus;

    self.currentImageQuality = iq;
    if (self.focusMode == TBScopeCameraFocusModeSharpness) {
        self.currentFocusMetric = iq.tenengrad3;
    } else if (self.focusMode == TBScopeCameraFocusModeContrast) {
        self.currentFocusMetric = iq.contrast;
    }
    
    NSValue *iqAsObject = [NSValue valueWithBytes:&iq objCType:@encode(ImageQuality)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageQualityReportReceived"
                                                        object:self
                                                      userInfo:@{ @"ImageQuality": iqAsObject }];
}

- (void)_log:(NSString *)message
{
    NSLog(@"%@ >> %@", @"Camera Mock", message);
}

@end
