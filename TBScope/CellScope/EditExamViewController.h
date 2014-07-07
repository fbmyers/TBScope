//
//  AssayParametersViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"

#import "EditSlideViewController.h"
#import "MapViewController.h"

#import "GoogleDriveSync.h"

@interface EditExamViewController : UITableViewController <UITextFieldDelegate>

@property (strong,nonatomic) Exams* currentExam;

@property (nonatomic) BOOL isNewExam;

//exam fields
@property (weak, nonatomic) IBOutlet UITextField* examIDTextField;
@property (weak, nonatomic) IBOutlet UITextField* patientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField* nameTextField;
@property (weak, nonatomic) IBOutlet UITextField* genderTextField;
@property (weak, nonatomic) IBOutlet UITextField* dobTextField;
@property (weak, nonatomic) IBOutlet UITextField* clinicTextField;
@property (weak, nonatomic) IBOutlet UITextField* addressTextField;
@property (weak, nonatomic) IBOutlet UITextField* hivStatusTextField;
@property (weak, nonatomic) IBOutlet UITextView* intakeNotesTextView;

@property (weak, nonatomic) IBOutlet UILabel* userLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* gpsLabel;

//localization
@property (weak, nonatomic) IBOutlet UILabel* examIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* genderLabel;
@property (weak, nonatomic) IBOutlet UILabel* dobLabel;
@property (weak, nonatomic) IBOutlet UILabel* clinicLabel;
@property (weak, nonatomic) IBOutlet UILabel* addressLabel;
@property (weak, nonatomic) IBOutlet UILabel* hivStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel* intakeNotesLabel;


@end
