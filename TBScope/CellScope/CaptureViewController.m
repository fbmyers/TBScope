//
//  CaptureViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CaptureViewController.h"

BOOL _FLOn=NO;
BOOL _BFOn=NO;
BOOL _isAborting=NO;
BOOL _isWaitingForFocusConfirmation=NO;

@implementation CaptureViewController

@synthesize currentSlide,snapButton,analyzeButton,bleConnectionLabel,holdTimer;

@synthesize previewView;

- (void)viewDidLoad
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    //localization
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Next", nil);    
    [self.bfButton setTitle:NSLocalizedString(@"BF Off",nil) forState:UIControlStateNormal];
    [self.flButton setTitle:NSLocalizedString(@"FL Off",nil) forState:UIControlStateNormal];
    //[self.aeButton setTitle:NSLocalizedString(@"AE On",nil) forState:UIControlStateNormal];
    [self.afButton setTitle:NSLocalizedString(@"AF On",nil) forState:UIControlStateNormal];
    self.bleConnectionLabel.text = NSLocalizedString(@"Not Connected", nil);
    self.analyzeButton.title = NSLocalizedString(@"Analyze",nil);
    [self.fastSlowButton setTitle:NSLocalizedString(@"Fast",nil) forState:UIControlStateNormal];
    
    //setup the camera view
    [previewView setupCamera];
    [previewView setBouncesZoom:NO];
    [previewView setBounces:NO];
    [previewView setMaximumZoomScale:10.0];
    [previewView zoomExtents]; //TODO: doesn't seem to be working right
    
    self.currentField = 0; //reset the field counter
    [self updatePrompt];
    self.snapButton.enabled = YES;
    self.snapButton.alpha = 1.0;
    
    self.analyzeButton.enabled = NO;
    self.analyzeButton.tintColor = [UIColor grayColor];
    
    [previewView setAutoresizesSubviews:NO];  //TODO: necessary?
    
    [previewView setFocusLock:YES];
    [previewView setExposureLock:YES];
    
    self.analyzeButton.enabled = NO;
    
    //TODO: i'd rather do this as a delegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageCallback) name:@"ImageCaptured" object:nil];

    //if this slide is being rescanned, delete old images/results
    for (Images* im in self.currentSlide.slideImages) {
        [[[TBScopeData sharedData] managedObjectContext] deleteObject:im];
    }
    if (self.currentSlide.slideAnalysisResults!=nil)
        [[[TBScopeData sharedData] managedObjectContext] deleteObject:self.currentSlide.slideAnalysisResults];
    [[TBScopeData sharedData] saveCoreData];
    
    [[TBScopeHardware sharedHardware] setDelegate:self];
    
    self.currentSpeed = CSStageSpeedFast;
    
    _isAborting = NO;
    
    self.controlPanelView.hidden = NO;
    self.leftButton.hidden = NO;
    self.rightButton.hidden = NO;
    self.downButton.hidden = NO;
    self.upButton.hidden = NO;
    self.autoFocusButton.hidden = NO;
    self.autoScanButton.hidden = NO;
    self.scanStatusLabel.hidden = YES;
    self.abortButton.hidden = YES;
    
    [TBScopeData CSLog:@"Capture screen presented" inCategory:@"USER"];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DoAutoScan"]) {
        [NSThread sleepForTimeInterval:1];
        [self didPressAutoScan:nil];
    }
    else
    {
        [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionSlideCenter];
    }
}

- (void)didPressAbort:(id)sender
{
    _isAborting = YES;
}

- (void)updatePrompt
{
    if (self.currentField<[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"])
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Capture Field %d of %d",nil),self.currentField+1,[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]];
    else
        self.navigationItem.title = NSLocalizedString(@"Capture Complete",nil);
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"AnalysisSegue"]) {
        AnalysisViewController *avc = (AnalysisViewController*)[segue destinationViewController];
        avc.currentSlide = self.currentSlide;
        
        //eject slide
        [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionLoading];
        
        //draw it back in (after user removes slide)
        [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionHome];
    
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
   
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
    
    [self.previewView stopPreview];
    
    [self.previewView takeDownCamera];
    
    [self.previewView.session stopRunning];
    
}

- (void)abortCapture
{
    
    [[self navigationController] popViewControllerAnimated:YES];
    _isAborting = NO;
}

- (void)didPressCapture:(id)sender
{
    if (previewView.previewRunning)
    {
        [previewView grabImage];
    }
    else
    {
        [previewView startPreview];
        self.analyzeButton.enabled = NO;
    }
    
}



- (void)saveImageCallback
{
    
    [TBScopeData CSLog:@"Snapped an image" inCategory:@"CAPTURE"];
    
    UIImage* image = previewView.lastCapturedImage; //[self convertImageToGrayScale:previewView.lastCapturedImage];
    
    
    //Crop the circle out of it
    image = [ImageQualityAnalyzer maskCircleFromImage:image];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            [TBScopeData CSLog:@"Error saving image to asset library" inCategory:@"CAPTURE"];
        }
        else {
            Images* newImage = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
            newImage.path = assetURL.absoluteString;
            newImage.fieldNumber = self.currentField+1;
            newImage.metadata = previewView.lastImageMetadata;
            [self.currentSlide addSlideImagesObject:newImage];
            
            // Commit to core data
            [TBScopeData touchExam:self.currentSlide.exam];
            [[TBScopeData sharedData] saveCoreData];
            
            self.currentField++;

            [self updatePrompt];
            
            if (self.currentField==[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]) {
                //done
                self.snapButton.enabled = NO;
                self.snapButton.alpha = 0.4;
                self.analyzeButton.enabled = YES;
                self.analyzeButton.tintColor = [UIColor whiteColor];
            }
            
            [TBScopeData CSLog:[NSString stringWithFormat:@"Saved image for %@ - %d-%d, to filename: %@",
                                               self.currentSlide.exam.examID,
                                               self.currentSlide.slideNumber,
                                               newImage.fieldNumber,
                                               newImage.path]
                    inCategory:@"CAPTURE"];
            
            
        }
    }];

}

- (IBAction)didPressSlideCenter:(id)sender
{
    [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionSlideCenter];
}

- (IBAction)didTouchDownStageButton:(id)sender
{
    if (holdTimer)
    {
        [holdTimer invalidate];
        holdTimer = nil;
    }
    
    UIButton* buttonPressed = (UIButton*)sender;
    
    //TODO: refactor this to use sender, rather than tags
    if (buttonPressed.tag==1) //up
        self.currentDirection = CSStageDirectionLeft;
    else if (buttonPressed.tag==2) //down
        self.currentDirection = CSStageDirectionRight;
    else if (buttonPressed.tag==3) //left
        self.currentDirection = CSStageDirectionUp;
    else if (buttonPressed.tag==4) //right
        self.currentDirection = CSStageDirectionDown;
    else if (buttonPressed.tag==5) //z+
        self.currentDirection = CSStageDirectionFocusUp;
    else if (buttonPressed.tag==6) //z-
        self.currentDirection = CSStageDirectionFocusDown;
    
    
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveStage:) userInfo:nil repeats:YES];
    
}

- (IBAction)didPressManualFocusDown:(id)sender
{
    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusDown
                                                StepInterval:500
                                                       Steps:20
                                                 StopOnLimit:YES
                                                DisableAfter:NO];
}

- (IBAction)didPressManualFocusUp:(id)sender
{
    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                StepInterval:500
                                                       Steps:20
                                                 StopOnLimit:YES
                                                DisableAfter:NO];
}

- (IBAction)didPressManualFocusOk:(id)sender
{
    [[TBScopeHardware sharedHardware] disableMotors];
    [NSThread sleepForTimeInterval:0.1];
    _isWaitingForFocusConfirmation = NO;
}

- (void) toggleBF:(BOOL)on
{
    if (on)
    {
        int intensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultBFIntensity"];
        self.intensitySlider.hidden = NO;
        self.intensityLabel.hidden = NO;
        [self.intensitySlider setValue:(float)intensity/255];
        [self.intensityLabel setText:[NSString stringWithFormat:@"%d",intensity]];
        
        self.intensitySlider.tintColor = [UIColor greenColor];
        self.intensityLabel.textColor = [UIColor greenColor];
        
        [previewView setExposureLock:NO];
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:intensity];
        [NSThread sleepForTimeInterval:2.0];
        [previewView setExposureLock:YES];
        
        [self.bfButton setTitle:NSLocalizedString(@"BF On",nil) forState:UIControlStateNormal];
        [self.bfButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else
    {
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
        [self.bfButton setTitle:NSLocalizedString(@"BF Off",nil) forState:UIControlStateNormal];
        [self.bfButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.intensitySlider.hidden = YES;
        self.intensityLabel.hidden = YES;
        
    }

}

- (void) toggleFL:(BOOL)on
{
    if (on)
    {
        int intensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultFLIntensity"];
        self.intensitySlider.hidden = NO;
        self.intensityLabel.hidden = NO;
        [self.intensitySlider setValue:(float)intensity/255];
        [self.intensityLabel setText:[NSString stringWithFormat:@"%d",intensity]];
        
        self.intensitySlider.tintColor = [UIColor blueColor];
        self.intensityLabel.textColor = [UIColor blueColor];
        
        
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:intensity];
        [self.flButton setTitle:NSLocalizedString(@"FL On",nil) forState:UIControlStateNormal];
        [self.flButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else
    {
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
        [self.flButton setTitle:NSLocalizedString(@"FL Off",nil) forState:UIControlStateNormal];
        [self.flButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.intensitySlider.hidden = YES;
        self.intensityLabel.hidden = YES;
    }
}

- (IBAction)intensitySliderDidChange:(id)sender
{
    if (_BFOn)
    {
        int intensity = self.intensitySlider.value*255;
        [self.intensityLabel setText:[NSString stringWithFormat:@"%d",intensity]];
        [[NSUserDefaults standardUserDefaults] setInteger:intensity forKey:@"DefaultBFIntensity"];
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:intensity];
    }
    else if (_FLOn)
    {
        int intensity = self.intensitySlider.value*255;
        [self.intensityLabel setText:[NSString stringWithFormat:@"%d",intensity]];
        [[NSUserDefaults standardUserDefaults] setInteger:intensity forKey:@"DefaultFLIntensity"];
        [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:intensity];
    }
}


- (IBAction)didTouchUpStageButton:(id)sender
{
    UIButton* buttonPressed = (UIButton*)sender;

    static BOOL AEOn=YES;
    static BOOL AFOn=YES;
    
    if (buttonPressed.tag==7) //BF
    {
        if (_FLOn) {
            [self toggleFL:NO];
            _FLOn = NO;
        }

        _BFOn = !_BFOn;
        [self toggleBF:_BFOn];
        
    }
    else if (buttonPressed.tag==8) //FL
    {
        if (_BFOn) {
            [self toggleBF:NO];
            _BFOn = NO;
        }
        _FLOn = !_FLOn;
        [self toggleFL:_FLOn];
    }
    else if (buttonPressed.tag==9) //AE
    {
        if (AEOn)
        {
            [previewView setExposureLock:YES];
            [buttonPressed setTitle:NSLocalizedString(@"AE Off",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [previewView setExposureLock:NO];
            [buttonPressed setTitle:NSLocalizedString(@"AE On",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        AEOn = !AEOn;
    }
    else if (buttonPressed.tag==10) //AF
    {
        if (AFOn)
        {
            [previewView setFocusLock:YES];
            [buttonPressed setTitle:NSLocalizedString(@"AF Off",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [previewView setFocusLock:NO];
            [buttonPressed setTitle:NSLocalizedString(@"AF On",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        AFOn = !AFOn;
    }
    else //stage control button
    {
        [holdTimer invalidate];
        holdTimer = nil;
        [[TBScopeHardware sharedHardware] disableMotors];
    }
}

//this function gets called whenever a stage move has completed, regardless of what initiated the move
- (void) tbScopeStageMoveDidCompleteWithXLimit:(BOOL)xLimit YLimit:(BOOL)yLimit ZLimit:(BOOL)zLimit;
{
    NSLog(@"move completed x=%d y=%d z=%d",xLimit,yLimit,zLimit);
}

//timer function
-(void) moveStage:(NSTimer *)timer
{
    if (self.currentSpeed==CSStageSpeedSlow)
        [[TBScopeHardware sharedHardware] moveStageWithDirection:self.currentDirection StepInterval:500 Steps:20 StopOnLimit:YES DisableAfter:NO];
    else if (self.currentSpeed==CSStageSpeedFast)
        [[TBScopeHardware sharedHardware] moveStageWithDirection:self.currentDirection StepInterval:100 Steps:100 StopOnLimit:YES DisableAfter:NO];
}

- (void) didReceiveMemoryWarning
{
    self.previewView.lastCapturedImage = nil;
    [TBScopeData CSLog:@"CaptureViewController received memory warning" inCategory:@"MEMORY"];
}

- (void)didPressFastSlow:(id)sender
{
    if (self.currentSpeed==CSStageSpeedFast)
    {
        self.currentSpeed = CSStageSpeedSlow;
        [self.fastSlowButton setTitle:NSLocalizedString(@"Slow",0) forState:UIControlStateNormal];
        [self.fastSlowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        self.currentSpeed = CSStageSpeedFast;
        [self.fastSlowButton setTitle:NSLocalizedString(@"Fast",0) forState:UIControlStateNormal];
        [self.fastSlowButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
    }
}

- (IBAction)didPressAutoFocus:(id)sender;
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self autoFocusWithStackSize:20
                       stepsPerSlice:80];
        
        [self autoFocusWithStackSize:10
                       stepsPerSlice:20];
        
    });
}

- (IBAction)didPressAutoScan:(id)sender;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self autoscanWithCols:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanCols"]
                          Rows:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanRows"]
            stepsBetweenFields:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanStepsBetweenFields"]
                 focusInterval:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanFocusInterval"]
                   bfIntensity:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanBFIntensity"]
                   flIntensity:[[NSUserDefaults standardUserDefaults] integerForKey:@"AutoScanFluorescentIntensity"]];
    });
}


//this algorithm will go numSteps/2 up, then numSteps down, then back up to a maximum of numSteps+1 (backlash)
- (BOOL) autoFocusWithStackSize:(int)stackSize
                    stepsPerSlice:(int)stepsPerSlice
{
    int state = 1;
    double maxFocus = 0;
    double minFocus = 0;
    int currentCycle = 0;
    int numCyclesToGoBack = 0;
    int numIterationsRemaining = 3;
    
    while (state!=0) {

        //check if abort button pressed
        if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return YES; }
        
        switch (state) {
            case 1: //reset
                state = 0;
                maxFocus = 0;
                minFocus = previewView.currentImageQuality.movingAverageSharpness;
                currentCycle = 0;
                numCyclesToGoBack = 0;
                state = 2;
                break;
            case 2: //backup
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                            StepInterval:500
                                                                   Steps:ceil(stepsPerSlice*stackSize/2)
                                                             StopOnLimit:YES
                                                            DisableAfter:NO];
                [[TBScopeHardware sharedHardware] waitForStage];
                [NSThread sleepForTimeInterval:0.4];
                state = 3;
                break;
            case 3: //scan forward
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusDown
                                                            StepInterval:500
                                                                   Steps:stepsPerSlice
                                                             StopOnLimit:YES
                                                            DisableAfter:NO];
                [[TBScopeHardware sharedHardware] waitForStage];
                [NSThread sleepForTimeInterval:0.4];
                if (previewView.currentImageQuality.movingAverageSharpness > maxFocus)
                {
                    maxFocus = previewView.currentImageQuality.movingAverageSharpness;
                    numCyclesToGoBack = 0;
                    //maxPosition = currentPosition;
                }
                else
                    numCyclesToGoBack++;
                
                if (previewView.currentImageQuality.movingAverageSharpness < minFocus)
                    minFocus = previewView.currentImageQuality.movingAverageSharpness;
                
                currentCycle++;
                if (currentCycle>=stackSize) {
                    currentCycle = 0;
                    state = 4;
                }
                break;
            case 4: //move back to maxfocus position
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                            StepInterval:500
                                                                   Steps:stepsPerSlice*numCyclesToGoBack
                                                             StopOnLimit:YES
                                                            DisableAfter:NO];
                
                [[TBScopeHardware sharedHardware] waitForStage];
                [NSThread sleepForTimeInterval:0.4];
                
                //if maxFocus wasn't significantly better than minFocus OR if current focus isn't at least 90% of maxFocs, start at this point and do another iteration
                if ((maxFocus/minFocus)<FOCUS_IMPROVEMENT_THRESHOLD) {
                    if (numIterationsRemaining>0) {
                        numIterationsRemaining--;
                        stackSize = ceil(stackSize*1.5);
                        state = 1;
                    }
                    else {
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Could not auto focus. minFocus=%lf, maxFocus=%lf",minFocus,maxFocus] inCategory:@"CAPTURE"];
                        [[TBScopeHardware sharedHardware] disableMotors];
                        return NO;
                    }
                }
                else
                {
                    [TBScopeData CSLog:[NSString stringWithFormat:@"Autofocused with minFocus=%lf, maxFocus=%lf",minFocus,maxFocus] inCategory:@"CAPTURE"];
                    state = 0; //done
                    [[TBScopeHardware sharedHardware] disableMotors];
                    return YES;
                }
                break;
            default:
                break;
        }
        NSLog(@"currentCycle=%d currentFocus=%f, maxFocus=%f",currentCycle,previewView.currentImageQuality.movingAverageSharpness,maxFocus);
    }
    [[TBScopeHardware sharedHardware] disableMotors];
    return YES;
}

- (void) manualFocusWithFL:(int)flIntensity BF:(int)bfIntensity
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Please Re-focus", nil);
        self.manualScanFocusDown.hidden = NO;
        self.manualScanFocusUp.hidden = NO;
        self.manualScanFocusOk.hidden = NO;

    });
    
    self.currentSpeed = CSStageSpeedSlow;
    
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:flIntensity]; 
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:bfIntensity]; //little bit of BF helps w/ focus
    
    _isWaitingForFocusConfirmation = YES;
    while (_isWaitingForFocusConfirmation && !_isAborting)
        [NSThread sleepForTimeInterval:0.1];
    
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){

        self.manualScanFocusDown.hidden = YES;
        self.manualScanFocusUp.hidden = YES;
        self.manualScanFocusOk.hidden = YES;
    });
}

- (void) autoscanWithCols:(int)numCols
                     Rows:(int)numRows
       stepsBetweenFields:(long)stepsBetween
            focusInterval:(int)focusInterval
              bfIntensity:(int)bfIntensity
              flIntensity:(int)flIntensity
{
                   
    [TBScopeData CSLog:@"Autoscanning..." inCategory:@"CAPTURE"];
    
    //setup UI
    dispatch_async(dispatch_get_main_queue(), ^(void){
    self.controlPanelView.hidden = YES;
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    self.downButton.hidden = YES;
    self.upButton.hidden = YES;
    self.intensitySlider.hidden = YES;
    self.intensityLabel.hidden = YES;
    self.autoFocusButton.hidden = YES;
    self.autoScanButton.hidden = YES;
    self.scanStatusLabel.hidden = NO;
    self.abortButton.hidden = NO;
    self.autoScanProgressBar.hidden = NO;
    self.autoScanProgressBar.progress = 0;
    self.scanStatusLabel.text = NSLocalizedString(@"Moving to slide center...", nil);
        
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    });
    
    //starting conditions
    [previewView setExposureLock:NO];
    [previewView setFocusLock:YES];
    [self toggleBF:NO];
    [self toggleFL:NO];
    [NSThread sleepForTimeInterval:0.1];
    
    //TODO: take picture of test target
    
    
    //move to slide center
    [[TBScopeHardware sharedHardware] moveToPosition:CSStagePositionSlideCenter];
    [[TBScopeHardware sharedHardware] waitForStage];
    
    //check if abort button pressed
    if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return; }
    
    
    //move to first position in grid
    //backup in both X and Y by half the row/col distance
    int xSteps = (numCols/2)*stepsBetween;
    int ySteps = (numRows/2)*stepsBetween;
    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionUp StepInterval:100 Steps:ySteps StopOnLimit:YES DisableAfter:YES];
    [[TBScopeHardware sharedHardware] waitForStage];
    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionLeft StepInterval:100 Steps:xSteps StopOnLimit:YES DisableAfter:YES];
    [[TBScopeHardware sharedHardware] waitForStage];
    
    //check if abort button pressed
    if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return; }
    
    //do auto exposure
    //turn on BF and wait for exposure to settle
    NSLog(@"auto expose");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Exposure Calibration...", nil);});
    [previewView setExposureLock:NO];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:bfIntensity];
    [NSThread sleepForTimeInterval:2.0];
    [previewView setExposureLock:YES];
    
    //focus in BF with wide range first
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoScanInitialFocus"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.scanStatusLabel.text = NSLocalizedString(@"Initial Focusing...", nil);});
        
        [self autoFocusWithStackSize:40
                       stepsPerSlice:80];
    }
    
    
    //check if abort button pressed
    if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return; }
    
    int yDir;
    //x iterator
    for (int i=0; i<numCols; i++) {
        
        //figure out which way y is moving
        if ((i%2)==0) //even, move down
            yDir = CSStageDirectionDown;
        else //odd, move up
            yDir = CSStageDirectionUp;
        
        //backlash compensation
        [[TBScopeHardware sharedHardware] moveStageWithDirection:yDir
                                                    StepInterval:100
                                                           Steps:BACKLASH_STEPS
                                                     StopOnLimit:YES
                                                    DisableAfter:YES];
        [[TBScopeHardware sharedHardware] waitForStage];
        
        
        //y iterator
        for (int j=0; j<numRows; j++) {
            int fieldNum = i*numRows + j;
            NSLog(@"scanning field #%d",fieldNum);
            
            //check if abort button pressed
            if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return; }
            
            //re-focus, if necessary
            if ((fieldNum%focusInterval)==0) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DoAutoFocus"]) {
                    
                    NSLog(@"auto focus");
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        self.scanStatusLabel.text = NSLocalizedString(@"Focusing...", nil);});
                    
                    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
                    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:bfIntensity];
                    
                    [NSThread sleepForTimeInterval:0.1];
                    
                    //auto focus, coarse and fine
                    BOOL focusSuccess1; BOOL focusSuccess2;
                    focusSuccess1 = [self autoFocusWithStackSize:20
                                   stepsPerSlice:80];

                    focusSuccess2 = [self autoFocusWithStackSize:10
                                       stepsPerSlice:20];
                    
                    if (!focusSuccess1 || !focusSuccess2)
                        [self manualFocusWithFL:flIntensity BF:1];
                    else
                    {
                        //the fluorescence seems to have a systematic offset of about 20 steps UP relative to BF
                        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                    StepInterval:100
                                                                           Steps:20
                                                                     StopOnLimit:YES
                                                                    DisableAfter:YES];
                        [[TBScopeHardware sharedHardware] waitForStage];
                    }
                        
                    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:flIntensity];
                    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
                    [NSThread sleepForTimeInterval:0.1];
                    
                    
                }
                else //manual focus
                {
                    [self manualFocusWithFL:flIntensity BF:1];
                }

                
                //switch back to FL
                //[[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0]; //might want this to be different
                //[[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:flIntensity];
                //[NSThread sleepForTimeInterval:1];
            }
            
            //check if abort button pressed
            if (_isAborting) { dispatch_async(dispatch_get_main_queue(), ^(void){[self abortCapture];}); return; }
            
            //take an image
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.scanStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Acquiring image %d of %d...", nil),fieldNum+1,numRows*numCols];
                self.autoScanProgressBar.progress = (float)fieldNum/(numRows*numCols);
            });
            [NSThread sleepForTimeInterval:0.5];
            [self didPressCapture:nil];
            [NSThread sleepForTimeInterval:0.5];
            

            [[TBScopeHardware sharedHardware] moveStageWithDirection:yDir
                                                        StepInterval:100
                                                               Steps:stepsBetween
                                                         StopOnLimit:YES
                                                        DisableAfter:YES];
            [[TBScopeHardware sharedHardware] waitForStage];
            
        }
        
        //move stage in x (next column)
        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionRight
                                                    StepInterval:100
                                                           Steps:stepsBetween
                                                     StopOnLimit:YES
                                                    DisableAfter:YES];
        [[TBScopeHardware sharedHardware] waitForStage];
    }
    
    //turn off BF and turn on FL
    NSLog(@"lights off");
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Acquisition complete...", nil);
        
        //do analysis
        [self performSegueWithIdentifier:@"AnalysisSegue" sender:self];
        
        //reenable buttons
        self.controlPanelView.hidden = NO;
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
        self.downButton.hidden = NO;
        self.upButton.hidden = NO;
        self.autoFocusButton.hidden = NO;
        self.autoScanButton.hidden = NO;
        self.scanStatusLabel.hidden = YES;
        self.abortButton.hidden = YES;
        self.autoScanProgressBar.hidden = YES;
    });
    
}

@end
