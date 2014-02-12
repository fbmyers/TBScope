//
//  LoadSampleViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CoreDataHelper.h"
#import "Users.h"
#import "Slides.h"
#import "CaptureViewController.h"

@interface LoadSampleViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong, nonatomic) Slides* currentSlide;

@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (nonatomic) BOOL doAnalysis;

@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UITextView *directionsLabel;

@end
