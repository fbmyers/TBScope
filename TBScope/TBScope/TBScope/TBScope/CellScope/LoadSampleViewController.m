//
//  LoadSampleViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "LoadSampleViewController.h"

@implementation LoadSampleViewController

@synthesize currentSlide,moviePlayer,videoView;

- (void) viewWillAppear:(BOOL)animated
{
    //localization
    self.navigationItem.title = NSLocalizedString(@"Load Sample Slide", nil);
    self.promptLabel.text = NSLocalizedString(@"Load the slide as shown below:", nil);
    [self.directionsLabel setText:NSLocalizedString(@"Wait for loading tray to come to a stop before inserting slide. Insert slide with sputum side up and gently push into machine. Click next. Slide will automatically load into position for image capture.", nil)];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSString *url   =   [[NSBundle mainBundle] pathForResource:@"slideloading" ofType:@"mp4"];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
    
    moviePlayer.fullscreen = NO;
    moviePlayer.allowsAirPlay = NO;
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayer.repeatMode = MPMovieRepeatModeOne;
    
    [moviePlayer.view setFrame:videoView.bounds];
    [videoView addSubview:moviePlayer.view];

    [moviePlayer play];
    
    
    //eject the tray
    
    for (int i=0;i<20;i++)
    {
        [[TBScopeHardware sharedHardware] moveStageWithDirection:CSStageDirectionUp
                                                         Steps:100
                                                  DisableAfter:NO];
        [NSThread sleepForTimeInterval:0.1];
    }
    [[TBScopeHardware sharedHardware] disableMotors];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CaptureViewController* cvc = (CaptureViewController*)[segue destinationViewController];
    cvc.currentSlide = self.currentSlide;
    cvc.doAnalysis = self.doAnalysis;
}

@end
