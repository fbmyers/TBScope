//
//  CaptureViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "CameraScrollView.h"
#import "AnalysisViewController.h"




@interface CaptureViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>


@property (strong,nonatomic) Slides* currentSlide;


@property (weak, nonatomic) IBOutlet CameraScrollView* previewView;
@property (weak, nonatomic) IBOutlet UIButton* snapButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* analyzeButton;
@property (weak, nonatomic) IBOutlet UINavigationItem* navItem;

@property (strong, nonatomic) NSTimer* holdTimer;

@property (weak, nonatomic) IBOutlet UILabel* bleConnectionLabel;

@property (weak, nonatomic) IBOutlet UIButton *bfButton;
@property (weak, nonatomic) IBOutlet UIButton *flButton;
@property (weak, nonatomic) IBOutlet UIButton *aeButton;
@property (weak, nonatomic) IBOutlet UIButton *afButton;

@property (weak, nonatomic) IBOutlet UIView *controlPanelView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *autoFocusButton;
@property (weak, nonatomic) IBOutlet UIButton *autoScanButton;
@property (weak, nonatomic) IBOutlet UILabel *scanStatusLabel;

@property (weak, nonatomic) IBOutlet UISlider *intensitySlider;

@property (nonatomic) int currentField;

//TODO: this should all go in microscope automation model class
@property (nonatomic) CSStageDirection currentDirection; //TODO: handle backlashing
@property (nonatomic) CSStageSpeed currentSpeed;

- (IBAction)didPressCapture:(id)sender;

- (void)saveImageCallback;

- (IBAction)didTouchDownStageButton:(id)sender;
- (IBAction)didTouchUpStageButton:(id)sender;

- (IBAction)didPressAutoFocus:(id)sender;
- (IBAction)didPressAutoScan:(id)sender;


- (void) autofocus;
- (void) autoscan;

@end
