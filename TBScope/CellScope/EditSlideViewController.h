//
//  EditSlideViewController.h
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Allows the user to specify basic info associated with a particular slide including sputum quality, collection date.

#import <UIKit/UIKit.h>
#import "TBScopeHardware.h"
#import "TBScopeData.h"

#import "LoadSampleViewController.h"

@interface EditSlideViewController : UIViewController <UIPickerViewDelegate, TBScopeViewControllerContext>

@property (strong,nonatomic) Exams* currentExam;
@property (strong,nonatomic) Slides* currentSlide;
@property (strong,nonatomic) NSMutableArray* sputumQualityChoicesArray;

//localization
@property (weak, nonatomic) IBOutlet UILabel *slideNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *sputumQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCollectedLabel;

@property (weak, nonatomic) IBOutlet UILabel *examIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *slide1Label;
@property (weak, nonatomic) IBOutlet UILabel *slide2Label;
@property (weak, nonatomic) IBOutlet UILabel *slide3Label;
@property (weak, nonatomic) IBOutlet UILabel *dateScannedLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *dateCollectedPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sputumQualityPicker;


@end
