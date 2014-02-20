//
//  CaptureViewController.h
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TBDiagnoser.h"
#import "Pictures.h"

@class CSUserContext;

@interface CaptureViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) CSUserContext *userContext;


//all the AVFoundation stuff
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoPreviewOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoHDOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;

//QUESTION: what is this?
@property (nonatomic, strong) CIContext *context;

//UI elements
@property (weak, nonatomic) IBOutlet UIView *previewLayer; //QUESTION: why are UI elements declared weak?
@property (weak, nonatomic) IBOutlet UIImageView *lastCaptured;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;


@property (strong,nonatomic) Pictures *picture;

//Classifier
@property (strong, nonatomic) TBDiagnoser *diagnoser;
@property (strong, nonatomic) ScoresAndCentroids *scoresAndCentroids;

- (IBAction)captureImage:(id)sender;

- (IBAction)closeCapture:(id)sender;

@end