//
//  ImageResultViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Displays the images associated with a particular slide and allows the user to scroll through them one by one. This view controller presents each image within a TBSlideViewer, which allows panning and zooming of each image.

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "TBSlideViewer.h"
#import "ImageROIResultView.h"

@interface ImageResultViewController : UIViewController

@property (strong,nonatomic) Slides* currentSlide;
@property (nonatomic) int currentImageIndex;

@property (weak, nonatomic) IBOutlet TBSlideViewer* slideViewer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fieldSelector;
@property (weak, nonatomic) IBOutlet ImageROIResultView* roiGridView;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;

@property (strong,nonatomic) UIButton* imageViewModeButton;

- (void) loadImage:(int)index;

- (IBAction)didChangeFieldSelection:(id)sender;

- (IBAction)didPressArrow:(id)sender;

@end
