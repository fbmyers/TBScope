//
//  SlideDiagnosisViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TBScopeData.h"
#import "TBScopeHardware.h"
#import "TBScopeViewControllerContext.h" //??
#import "GoogleDriveSync.h"

//#import "AnalysisViewController.h"  //causes circular dependance

@interface SlideDiagnosisViewController : UITableViewController

@property (strong,nonatomic) Exams* currentExam;


// UI elements for presenting a diagnosis to the patient
@property (weak, nonatomic) IBOutlet UILabel* dateCollectedLabel;
@property (weak, nonatomic) IBOutlet UILabel* examIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientHIVStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientDOBLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel* locationLabel;
@property (weak, nonatomic) IBOutlet UILabel* addressLabel;


@property (weak, nonatomic) IBOutlet UITextView* intakeNotesTextView;
@property (weak, nonatomic) IBOutlet UILabel* userLabel;
@property (weak, nonatomic) IBOutlet UILabel* diagnosisLabel;
@property (weak, nonatomic) IBOutlet UIView* scoreView;
@property (weak, nonatomic) IBOutlet UIImageView* scoreMarker;
@property (weak, nonatomic) IBOutlet UILabel* dateAnalyzedLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateScannedLabel;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel* imageQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel* numFieldsLabel;
@property (weak, nonatomic) IBOutlet UITextView* diagnosisNotesTextView;
//@property (weak, nonatomic) IBOutlet MKMapView* mapView;


- (IBAction)uploadButtonPressed:(id)sender;

//labels for localization
@property (weak, nonatomic) IBOutlet UILabel *analysisResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *slideInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCollectedPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *namePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIDPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientAddressPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *intakeNotesPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *analysisDatePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *slideScorePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageQualityPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldsPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisNotesPromptLabel;

@property (weak, nonatomic) IBOutlet UIButton *rerunAnalysisButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;


@end
