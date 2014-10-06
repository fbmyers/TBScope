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
#import "MapViewController.h"

//#import "AnalysisViewController.h"  //causes circular dependance

@interface SlideDiagnosisViewController : UITableViewController

@property (strong,nonatomic) Exams* currentExam;


//exam info
@property (weak, nonatomic) IBOutlet UILabel* locationLabel;
@property (weak, nonatomic) IBOutlet UILabel* userLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastModifiedLabel;
@property (weak, nonatomic) IBOutlet UIButton *editExamButton;

//patient info
@property (weak, nonatomic) IBOutlet UILabel* patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientHIVStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientDOBLabel;
@property (weak, nonatomic) IBOutlet UILabel* patientGenderLabel;


//notes
@property (weak, nonatomic) IBOutlet UITextView* intakeNotesTextView;
@property (weak, nonatomic) IBOutlet UITextView* diagnosisNotesTextView;

//slide 1
@property (weak, nonatomic) IBOutlet UILabel *slideLabel1;
@property (weak, nonatomic) IBOutlet UIView* scoreView1;
@property (weak, nonatomic) IBOutlet UIImageView* scoreMarker1;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel1;
@property (weak, nonatomic) IBOutlet UILabel* dateCollectedLabel1;
@property (weak, nonatomic) IBOutlet UILabel* dateScannedLabel1;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityLabel1;
@property (weak, nonatomic) IBOutlet UILabel* imageQualityLabel1;
@property (weak, nonatomic) IBOutlet UILabel* numFieldsLabel1;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmLabel1;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedLabel1;
@property (weak, nonatomic) IBOutlet UIButton *rescanButton1;
@property (weak, nonatomic) IBOutlet UIButton *reanalyzeButton1;

//slide 2
@property (weak, nonatomic) IBOutlet UILabel *slideLabel2;
@property (weak, nonatomic) IBOutlet UIView* scoreView2;
@property (weak, nonatomic) IBOutlet UIImageView* scoreMarker2;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel2;
@property (weak, nonatomic) IBOutlet UILabel* dateCollectedLabel2;
@property (weak, nonatomic) IBOutlet UILabel* dateScannedLabel2;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityLabel2;
@property (weak, nonatomic) IBOutlet UILabel* imageQualityLabel2;
@property (weak, nonatomic) IBOutlet UILabel* numFieldsLabel2;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmLabel2;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedLabel2;
@property (weak, nonatomic) IBOutlet UIButton *rescanButton2;
@property (weak, nonatomic) IBOutlet UIButton *reanalyzeButton2;

//slide 3
@property (weak, nonatomic) IBOutlet UILabel *slideLabel3;
@property (weak, nonatomic) IBOutlet UIView* scoreView3;
@property (weak, nonatomic) IBOutlet UIImageView* scoreMarker3;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel3;
@property (weak, nonatomic) IBOutlet UILabel* dateCollectedLabel3;
@property (weak, nonatomic) IBOutlet UILabel* dateScannedLabel3;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityLabel3;
@property (weak, nonatomic) IBOutlet UILabel* imageQualityLabel3;
@property (weak, nonatomic) IBOutlet UILabel* numFieldsLabel3;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmLabel3;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedLabel3;
@property (weak, nonatomic) IBOutlet UIButton *rescanButton3;
@property (weak, nonatomic) IBOutlet UIButton *reanalyzeButton3;



//labels for localization
@property (weak, nonatomic) IBOutlet UILabel *examInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *analysisResultsLabel;

@property (weak, nonatomic) IBOutlet UILabel *examIDPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIDPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNamePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientAddressPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientGenderPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientDOBPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientHIVStatusPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastModifiedPromptLabel;

@property (weak, nonatomic) IBOutlet UILabel *intakeNotesPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisNotesPromptLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateCollectedPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *dateScannedPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *imageQualityPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *fieldsPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmPromptLabel1;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedPromptLabel1;

@property (weak, nonatomic) IBOutlet UILabel *dateCollectedPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dateScannedPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *imageQualityPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *fieldsPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmPromptLabel2;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedPromptLabel2;

@property (weak, nonatomic) IBOutlet UILabel *dateCollectedPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *dateScannedPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *sputumQualityPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *imageQualityPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *fieldsPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *numAFBAlgorithmPromptLabel3;
@property (weak, nonatomic) IBOutlet UILabel *numAFBConfirmedPromptLabel3;


@property (weak, nonatomic) IBOutlet UIButton *addSlideButton;
@property (weak, nonatomic) IBOutlet UIButton *gpsMapButton;


@end
