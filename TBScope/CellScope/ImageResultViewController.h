//
//  ImageResultViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "TBSlideViewer.h"


@interface ImageResultViewController : UIViewController

@property (strong,nonatomic) Slides* currentSlide;
@property (nonatomic) int currentImageIndex;

@property (weak, nonatomic) IBOutlet TBSlideViewer* slideViewer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fieldSelector;

- (void) loadImage:(int)index;

- (IBAction)didChangeFieldSelection:(id)sender;

@end
