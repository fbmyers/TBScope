//
//  FollowUpViewController.h
//  TBScope
//
//  Created by Frankie Myers on 10/8/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBScopeData.h"

@interface FollowUpViewController : UIViewController

@property (strong,nonatomic) Exams* currentExam;


@property (weak, nonatomic) IBOutlet UILabel *znLabel;
@property (weak, nonatomic) IBOutlet UILabel *slide1Label;
@property (weak, nonatomic) IBOutlet UILabel *slide2Label;
@property (weak, nonatomic) IBOutlet UILabel *slide3Label;
@property (weak, nonatomic) IBOutlet UILabel *xpertMTBLabel;
@property (weak, nonatomic) IBOutlet UILabel *xpertRIFLabel;

@property (weak, nonatomic) IBOutlet UIButton *slide1NAButton;
@property (weak, nonatomic) IBOutlet UIButton *slide10Button;
@property (weak, nonatomic) IBOutlet UIButton *slide1ScantyButton;
@property (weak, nonatomic) IBOutlet UIButton *slide11Button;
@property (weak, nonatomic) IBOutlet UIButton *slide12Button;
@property (weak, nonatomic) IBOutlet UIButton *slide13Button;
@property (weak, nonatomic) IBOutlet UIButton *slide2NAButton;
@property (weak, nonatomic) IBOutlet UIButton *slide20Button;
@property (weak, nonatomic) IBOutlet UIButton *slide2ScantyButton;
@property (weak, nonatomic) IBOutlet UIButton *slide21Button;
@property (weak, nonatomic) IBOutlet UIButton *slide22Button;
@property (weak, nonatomic) IBOutlet UIButton *slide23Button;
@property (weak, nonatomic) IBOutlet UIButton *slide3NAButton;
@property (weak, nonatomic) IBOutlet UIButton *slide30Button;
@property (weak, nonatomic) IBOutlet UIButton *slide3ScantyButton;
@property (weak, nonatomic) IBOutlet UIButton *slide31Button;
@property (weak, nonatomic) IBOutlet UIButton *slide32Button;
@property (weak, nonatomic) IBOutlet UIButton *slide33Button;


@property (weak, nonatomic) IBOutlet UIButton *xpertNAButton;
@property (weak, nonatomic) IBOutlet UIButton *xpertNegativeButton;
@property (weak, nonatomic) IBOutlet UIButton *xpertPositiveButton;
@property (weak, nonatomic) IBOutlet UIButton *xpertIndeterminateButton;
@property (weak, nonatomic) IBOutlet UIButton *xpertSusceptibleButton;
@property (weak, nonatomic) IBOutlet UIButton *xpertResistantButton;

- (IBAction)didPressButton:(id)sender;

@end
