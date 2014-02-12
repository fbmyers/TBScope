//
//  CaptureViewController.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "CaptureViewController.h"
#import "UIImage+Resize.h"

#import "CSUserContext.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "ResultsViewController.h"
#import "AnalysisViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

@synthesize managedObjectContext;
@synthesize previewLayer;
@synthesize lastCaptured;
@synthesize spinningWheel;
@synthesize session;
@synthesize device;
@synthesize input;
@synthesize videoPreviewOutput, videoHDOutput, stillOutput;
@synthesize diagnoser, scoresAndCentroids;

@synthesize picture;

@synthesize context = _context;

// Make sure that context is only initiated one time
- (CIContext *)context
{
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    
    return _context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Setup the AV foundation capture session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Setup image preview layer
    CALayer *viewLayer = self.previewLayer.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];

    captureVideoPreviewLayer.frame = viewLayer.bounds;
    [viewLayer addSublayer:captureVideoPreviewLayer];
    
    // Setup still image output
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];
    
    
    // Add session input and output
    [self.session addInput:self.input];
    [self.session addOutput:self.stillOutput];
    
    [self.session startRunning];
    
    
    // Setup classifier (does this make sense here?)
    self.diagnoser = [[TBDiagnoser alloc] init]; //TODO: change name (TBImageProcessor)
    self.diagnoser.managedObjectContext = self.managedObjectContext;
    
}

-(IBAction) captureImage:(id)sender;
{
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
    
	NSLog(@"about to request a capture from: %@", stillOutput);
	[stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         UIImage* thumbnail = [image thumbnailImage:80.0 transparentBorder:1.0 cornerRadius:1.0 interpolationQuality:kCGInterpolationDefault];
         
         // Set the last captured image preview thumbnail
         self.lastCaptured.image = thumbnail;
         
         // Set up a Pictures entry to store in Core Data
         picture = (Pictures *)[NSEntityDescription insertNewObjectForEntityForName:@"Pictures" inManagedObjectContext:self.managedObjectContext];
         
         // Save the image to the camera roll
         if ([self.userContext.sharing isEqualToString:@"Camera Roll"]) {
             // Request to save the image to camera roll
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             
             [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                 if (error) {
                     NSLog(@"Error writing image to photo album");
                 }
                 else {
                     picture.path = assetURL.absoluteString;
                 }
             }];
         }
         
         // Set the picture properties
         picture.title = @"Default";
         picture.desc = @"No description";
         picture.date = [NSDate date];
         picture.user = self.userContext.username;
         picture.sharing = self.userContext.sharing;
         picture.smallPicture = UIImagePNGRepresentation(thumbnail);
         
         
         //FBM - run SVM analysis on this image if the "analyze" button was pressed
         UIBarButtonItem *btn = (UIBarButtonItem *)sender;
         
         if (btn.tag == 2) {
             //do analysis
             
             NSLog(@"starting analysis");

             
                 [self performSegueWithIdentifier:@"AnalysisSegue" sender:sender];

             


         }
         
         if (![self.managedObjectContext save:&error]) {
             NSLog(@"Failed to add new picture with error: %@", [error domain]);
         }
     }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"AnalysisSegue"]) {

        
        NSLog(@"path = %@", picture.path);
        
        AnalysisViewController *avc = (AnalysisViewController*)[segue destinationViewController];
        avc.userContext = self.userContext;
        avc.managedObjectContext = self.managedObjectContext;
        avc.picture = picture;
        
    }
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Handle error saving image to camera roll
    if (error != NULL) {
        NSLog(@"Error saving picture to camera rolll");
    }
}

- (IBAction)closeCapture:(id)sender {
    // Close the AV Capture session
    [self.session stopRunning];
    
    // Dismiss the view controller
    [self dismissModalViewControllerAnimated:YES];
}

     - (void)viewDidUnload
{
    [self setPreviewLayer:nil];
    [self setLastCaptured:nil];
    [self setLastCaptured:nil];
    [self setLastCaptured:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIDevice* thisDevice = [UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        // Rotate the user interface for cell scope image capture
        if(interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

@end
