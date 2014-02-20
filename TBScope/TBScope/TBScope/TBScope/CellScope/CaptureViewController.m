//
//  CaptureViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CaptureViewController.h"

@implementation CaptureViewController

@synthesize currentSlide,snapButton,analyzeButton,bleConnectionLabel,holdTimer;

@synthesize previewView;
//@synthesize imagePath;

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
    [self.aeButton setTitle:NSLocalizedString(@"AE On",nil) forState:UIControlStateNormal];
    [self.afButton setTitle:NSLocalizedString(@"AF On",nil) forState:UIControlStateNormal];
    self.bleConnectionLabel.text = NSLocalizedString(@"Not Connected", nil);
    
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
    
    
    self.snapButton.titleLabel.text = @"Snap";
    
    if (self.doAnalysis)
        self.analyzeButton.title = NSLocalizedString(@"Analyze",nil);
    else
        self.analyzeButton.title = NSLocalizedString(@"Done",nil);
    
    self.analyzeButton.enabled = NO;
    
    //TODO: i'd rather do this as a delegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageCallback) name:@"ImageCaptured" object:nil];

    

    
}


- (void)updatePrompt
{
    if (self.currentField<[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"])
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Capture Field %d of %d",nil),self.currentField+1,[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]];
    else
        self.navigationItem.title = NSLocalizedString(@"Capture Complete",nil);
    
}



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AnalysisSegue"])
    {
        if (self.doAnalysis)
        {
            return YES;
        }
        else
        {
            [[self navigationController] popToRootViewControllerAnimated:YES];
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"AnalysisSegue"]) {
        AnalysisViewController *avc = (AnalysisViewController*)[segue destinationViewController];
        avc.currentSlide = self.currentSlide;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
    
    [self.previewView stopPreview];
    
    [self.previewView takeDownCamera];
    
    
    if ([self isMovingFromParentViewController])
    {
        //user pressed back, so roll back changes
        [[[TBScopeData sharedData] managedObjectContext] rollback];
    }
    else
    {
        // Commit to core data
        NSError *error;
        if (![[[TBScopeData sharedData] managedObjectContext] save:&error])
            NSLog(@"Failed to commit to core data: %@", [error domain]);
    }
    
    [self.previewView.session stopRunning];
    
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
    UIImage* image = previewView.lastCapturedImage; //[self convertImageToGrayScale:previewView.lastCapturedImage];
    
    NSLog(@"did get image");
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Error writing image to photo album");
        }
        else {
            Images* newImage = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
            newImage.path = assetURL.absoluteString;
            newImage.fieldNumber = self.currentField;
            newImage.metadata = previewView.lastImageMetadata;
            [self.currentSlide addSlideImagesObject:newImage]; //TODO: rollback if they discard a frame
            
            self.currentField++;
            
            self.analyzeButton.enabled = NO;
            self.analyzeButton.tintColor = [UIColor grayColor];
            
            [self updatePrompt];
            if (self.currentField==[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]) {
                //done
                self.snapButton.enabled = NO;
                self.snapButton.alpha = 0.4;
                self.analyzeButton.enabled = YES;
                self.analyzeButton.tintColor = [UIColor blueColor];
            }
            
            NSLog(@"did save");
        }
    }];
    
    /*
    //probably don't need this
    [previewView stopPreview];
    self.snapButton.titleLabel.text = @"Retry";
    self.analyzeButton.enabled = YES; //have this enable the button w/ >N images
    self.nextFieldButton.hidden = NO;
    */
}

- (IBAction)didTouchDownStageButton:(id)sender
{
    if (holdTimer)
    {
        [holdTimer invalidate];
        holdTimer = nil;
    }
    
    UIButton* buttonPressed = (UIButton*)sender;
    
    if (buttonPressed.tag==1) //up
        self.currentDirection = CSStageDirectionUp;
    else if (buttonPressed.tag==2) //down
        self.currentDirection = CSStageDirectionDown;
    else if (buttonPressed.tag==3) //left
        self.currentDirection = CSStageDirectionLeft;
    else if (buttonPressed.tag==4) //right
        self.currentDirection = CSStageDirectionRight;
    else if (buttonPressed.tag==5) //z+
        self.currentDirection = CSStageDirectionFocusUp;
    else if (buttonPressed.tag==6) //z-
        self.currentDirection = CSStageDirectionFocusDown;
    
    self.currentSpeed = CSStageSpeedFast;
    
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveStage:) userInfo:nil repeats:YES];
    
}

- (IBAction)didTouchUpStageButton:(id)sender
{
    UIButton* buttonPressed = (UIButton*)sender;

    static BOOL BFOn=NO;
    static BOOL FLOn=NO;
    static BOOL AEOn=YES;
    static BOOL AFOn=YES;
    
    if (buttonPressed.tag==7) //BF
    {
        if (BFOn)
        {
            [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
            [buttonPressed setTitle:NSLocalizedString(@"BF Off",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        else
        {
            [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:70];
            [buttonPressed setTitle:NSLocalizedString(@"BF On",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        BFOn = !BFOn;
        
    }
    else if (buttonPressed.tag==8) //FL
    {
        if (FLOn)
        {
            [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
            [buttonPressed setTitle:NSLocalizedString(@"FL Off",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        else
        {
            [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:255];
            [buttonPressed setTitle:NSLocalizedString(@"FL On",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        FLOn = !FLOn;
    }
    else if (buttonPressed.tag==9) //AE
    {
        if (AEOn)
        {
            [previewView setExposureLock:YES];
            [buttonPressed setTitle:NSLocalizedString(@"AE Off",nil) forState:UIControlStateNormal];
            [buttonPressed setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
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
            [buttonPressed setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
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
        self.currentSpeed = CSStageSpeedStopped;
    }
}



//timer function
-(void) moveStage:(NSTimer *)timer
{
    if (self.currentSpeed==CSStageSpeedSlow)
        [[TBScopeHardware sharedHardware] moveStageWithDirection:self.currentDirection Steps:20 DisableAfter:NO];
    else if (self.currentSpeed==CSStageSpeedFast)
        [[TBScopeHardware sharedHardware] moveStageWithDirection:self.currentDirection Steps:100 DisableAfter:NO];
}

- (void) didReceiveMemoryWarning
{
    NSLog(@"captureviewcontroller did receive mem warning");
    self.previewView.lastCapturedImage = nil;
}

//FSM for autofocusing

- (IBAction)didPressAutoFocus:(id)sender;
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self autofocus];
    });
}

- (IBAction)didPressAutoScan:(id)sender;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self autoscan];
    });
}


#define NUM_BACKUP_CYCLES 5
#define BACKUP_STEP_SIZE 200
#define NUM_FORWARD_CYCLES 41 //adding 1 for backlash
#define FORWARD_STEP_SIZE 50
#define NUM_FINE_STEP_CYCLES 102 //adding 2 for backlash
#define FINE_STEP_SIZE 20


- (void) autofocus
{
    int state = 1;
    
    int maxFocus = 0;
    //int maxPosition = 0; //deprecated
    int currentCycle = 0;
    
    while (state!=0) {

        switch (state) {
            case 1: //reset
                state = 0;
                maxFocus = 0;
                state = 2;
                break;
            case 2: //backup
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                 Steps:BACKUP_STEP_SIZE
                                                          DisableAfter:NO];
                [NSThread sleepForTimeInterval:0.1];
                currentCycle++;
                if (currentCycle>NUM_BACKUP_CYCLES) {
                    currentCycle = 0;
                    state = 3;
                }
                break;
            case 3:
                [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusDown
                                                                 Steps:FORWARD_STEP_SIZE
                                                          DisableAfter:NO];
                [NSThread sleepForTimeInterval:0.2];
                if (previewView.currentFocusValue > maxFocus)
                {
                    maxFocus = previewView.currentFocusValue;
                    //maxPosition = currentPosition;
                }
                currentCycle++;
                if (currentCycle>NUM_FORWARD_CYCLES) {
                    currentCycle = 0;
                    state = 4;
                }
                break;
            case 4: //move back to maxFocus (within 5%)
                currentCycle++;
                if (currentCycle>NUM_FINE_STEP_CYCLES) {
                    currentCycle = 0;
                    maxFocus = 0;
                    state = 1; //restart
                }
                

                if (previewView.currentFocusValue < round(0.95*maxFocus)) {
                    [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionFocusUp
                                                                     Steps:FINE_STEP_SIZE/2
                                                              DisableAfter:NO];
                    [NSThread sleepForTimeInterval:0.2];
                }
                else {
                    state = 0; //done
                }

                break;
            default:
                break;
        }
        NSLog(@"currentCycle=%d currentFocus=%d, maxFocus=%d",currentCycle,previewView.currentFocusValue,maxFocus);
    }
    
}

- (void) autoscan
{
    //wait for BLE to connect
    
    //disable all buttons
    dispatch_async(dispatch_get_main_queue(), ^(void){
    self.controlPanelView.hidden = YES;
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    self.downButton.hidden = YES;
    self.upButton.hidden = YES;
    self.autoFocusButton.hidden = YES;
    self.autoScanButton.hidden = YES;
    self.scanStatusLabel.hidden = NO;
    });
    
    //starting conditions
    [previewView setExposureLock:NO];
    [previewView setFocusLock:NO];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
    [NSThread sleepForTimeInterval:0.1];
    
    //draw in tray to start point
    NSLog(@"draw in tray");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Loading sample...", nil);});
    for (int i=0;i<30;i++)
    {
        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionDown
                                                         Steps:100
                                                  DisableAfter:NO];
        [NSThread sleepForTimeInterval:0.1];
    }
    [[TBScopeHardware sharedHardware] disableMotors];
    
    //turn on BF and wait for exposure to settle
    NSLog(@"BF on");
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:70];
    [NSThread sleepForTimeInterval:2.0];
    
    //set exposure lock and focus lock
    NSLog(@"exposure/focus lock");
    [previewView setExposureLock:YES];
    [previewView setFocusLock:YES];
    [NSThread sleepForTimeInterval:1.0];
    
    //do autofocus
    NSLog(@"autofocus");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Focusing...", nil);});
    [self autofocus];
    
    //turn off BF and turn on FL
    NSLog(@"BF on");
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:255];
    
    [NSThread sleepForTimeInterval:0.2];
    
    //acquire 5 fields
    for (int fieldNumber=0; fieldNumber<[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]; fieldNumber++)
    {
        //take an image
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.scanStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Acquiring image %d of %d...", nil),fieldNumber+1,[[NSUserDefaults standardUserDefaults] integerForKey:@"NumFieldsPerSlide"]];});
        
        [self didPressCapture:nil];
        [NSThread sleepForTimeInterval:3.0];
        
        //move
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.scanStatusLabel.text = NSLocalizedString(@"Next field...", nil);});
        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionDown
                                                         Steps:200
                                                  DisableAfter:YES];
        [NSThread sleepForTimeInterval:1.0];
    
    }
    
    //turn off BF and turn on FL
    NSLog(@"lights off");
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDBrightfield Level:0];
    [[TBScopeHardware sharedHardware] setMicroscopeLED:CSLEDFluorescent Level:0];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.scanStatusLabel.text = NSLocalizedString(@"Acquisition complete...", nil);});
    
    //eject slide
    for (int i=0;i<60;i++)
    {
        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionUp
                                                         Steps:100
                                                  DisableAfter:NO];
        [NSThread sleepForTimeInterval:0.1];
    }
    [[TBScopeHardware sharedHardware] disableMotors];
    

    dispatch_async(dispatch_get_main_queue(), ^(void){
        
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
    });
    
}

@end
