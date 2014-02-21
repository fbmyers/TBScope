//
//  SlideDiagnosisViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "SlideDiagnosisViewController.h"

@implementation SlideDiagnosisViewController

- (void) viewWillAppear:(BOOL)animated
{
    
    //localization
    self.navigationItem.title = NSLocalizedString(@"Review Slide", nil);
    self.slideInfoLabel.text = NSLocalizedString(@"Slide Info", nil);
    self.analysisResultLabel.text = NSLocalizedString(@"Analysis Result", nil);
    self.dateCollectedPromptLabel.text = NSLocalizedString(@"Date", nil);
    self.namePromptLabel.text = NSLocalizedString(@"Name", nil);
    self.patientIDPromptLabel.text = NSLocalizedString(@"Patient ID", nil);
    self.userPromptLabel.text = NSLocalizedString(@"User", nil);
    self.locationPromptLabel.text = NSLocalizedString(@"Location", nil);
    self.patientAddressPromptLabel.text = NSLocalizedString(@"Patient Address", nil);
    self.intakeNotesPromptLabel.text = NSLocalizedString(@"Intake Notes", nil);
    self.analysisDatePromptLabel.text = NSLocalizedString(@"Analysis Date", nil);
    self.slideScorePromptLabel.text = NSLocalizedString(@"Slide Score", nil);
    self.imageQualityPromptLabel.text = NSLocalizedString(@"Image Quality", nil);
    self.fieldsPromptLabel.text = NSLocalizedString(@"Fields", nil);
    self.diagnosisNotesPromptLabel.text = NSLocalizedString(@"Diagnosis Notes", nil);
    [self.rerunAnalysisButton setTitle:NSLocalizedString(@"Re-run Analysis", nil) forState:UIControlStateNormal];
    [self.uploadButton setTitle:NSLocalizedString(@"Upload", nil) forState:UIControlStateNormal];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Results", nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Images", nil)];
    
    //set textarea to look like textfield
    [[self.diagnosisNotesTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.diagnosisNotesTextView layer] setBorderWidth:1];
    [[self.diagnosisNotesTextView layer] setCornerRadius:10];
    
    //exam info
    self.examIDLabel.text = self.currentExam.examID;
    self.patientNameLabel.text = self.currentExam.patientName;
    self.patientIDLabel.text = self.currentExam.patientID;
    self.patientAddressLabel.text = self.currentExam.patientAddress;
    self.patientHIVStatusLabel.text = self.currentExam.patientHIVStatus;
    self.patientGenderLabel.text = self.currentExam.patientGender;
    self.locationLabel.text = self.currentExam.location;
    if ([self.currentExam.intakeNotes isEqualToString:@""])
        self.intakeNotesTextView.text = NSLocalizedString(@"NONE",nil);
    else
        self.intakeNotesTextView.text = self.currentExam.intakeNotes;
    self.diagnosisNotesTextView.text = self.currentExam.diagnosisNotes;
    self.userLabel.text = self.currentExam.userName;
    //TODO: remaining exam info
    
    
    //general slide info fields (SLIDE 1)
    Slides* slide1 = (Slides*)self.currentExam.examSlides[0];
    
    NSDate* date;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:slide1.dateCollected];
    NSString* dateCollectedString = [dateFormatter stringFromDate:date];
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:slide1.dateScanned];
    NSString* dateScannedString = [dateFormatter stringFromDate:date];
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:slide1.slideAnalysisResults.dateDiagnosed];
    NSString* dateDiagnosedString = [dateFormatter stringFromDate:date];
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.currentExam.patientDOB];
    NSString* dateDOB = [dateFormatter stringFromDate:date];
    
    self.dateCollectedLabel.text = dateCollectedString;
    self.dateScannedLabel.text = dateScannedString;
    self.dateAnalyzedLabel.text = dateDiagnosedString;
    self.numFieldsLabel.text = [[NSString alloc] initWithFormat:@"%d",slide1.slideImages.count];
    
    self.patientDOBLabel.text = dateDOB;

    
    //TODO: remaining slide properties
    
    //display diagnosis info
    if (slide1.slideAnalysisResults==nil)
    {
        self.diagnosisLabel.text = NSLocalizedString(@"ANALYSIS HAS NOT BEEN PERFORMED",nil);
        self.diagnosisLabel.backgroundColor = [UIColor lightGrayColor];
        self.scoreView.hidden = YES;
        self.scoreMarker.hidden = YES;
    }
    else
    {
        self.scoreView.hidden = NO;
        self.scoreMarker.hidden = NO;
        
        if ([slide1.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        {
            self.diagnosisLabel.text = NSLocalizedString(@"SLIDE IS POSITIVE FOR TUBERCULOSIS",nil);
            self.diagnosisLabel.backgroundColor = [UIColor redColor];
        }
        else if ([slide1.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        {
            self.diagnosisLabel.text = NSLocalizedString(@"SLIDE IS NEGATIVE FOR TUBERCULOSIS",nil);
            self.diagnosisLabel.backgroundColor = [UIColor greenColor];
        }
        else if ([slide1.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
        {
            self.diagnosisLabel.text = NSLocalizedString(@"SLIDE IS INDETERMINATE",nil);
            self.diagnosisLabel.backgroundColor = [UIColor yellowColor];
        }
        
        self.scoreView.backgroundColor = [UIColor redColor];
        //CGRect scoreBarRect = self.scoreView.bounds;
        //TODO: remove "redthreshold" from settings and just use yellow/diagnostic
        //TODO: if the user changes the diagnostic threshold, the slide will still say + but the colors won't be correct
        float yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
        float redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"];
        
        CGRect scoreBarRect;
        scoreBarRect = self.scoreView.bounds;
        scoreBarRect.size.width = scoreBarRect.size.width*redThreshold;
        UIView* yellowBar = [[UIView alloc] initWithFrame:scoreBarRect];
        yellowBar.backgroundColor = [UIColor yellowColor];
        [self.scoreView addSubview:yellowBar];
        scoreBarRect = self.scoreView.bounds;
        scoreBarRect.size.width = scoreBarRect.size.width*yellowThreshold;
        UIView* greenBar = [[UIView alloc] initWithFrame:scoreBarRect];
        greenBar.backgroundColor = [UIColor greenColor];
        [self.scoreView addSubview:greenBar];
        
        scoreBarRect = self.scoreView.bounds;
        CGFloat scoreMarkerY = self.scoreMarker.center.y;
        CGFloat scoreMarkerX = self.scoreView.center.x-scoreBarRect.size.width/2 + scoreBarRect.size.width*slide1.slideAnalysisResults.score;
        
        [self.scoreMarker setCenter:CGPointMake(scoreMarkerX,scoreMarkerY)];
    
        
        self.scoreLabel.text = [[NSString alloc] initWithFormat:@"%3.2f",slide1.slideAnalysisResults.score*100];
        self.imageQualityLabel.text = @"Not Evaluated";
        
    }
    
    //TODO: other two slides

    
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    //commit any notes added here
    self.currentExam.diagnosisNotes = self.diagnosisNotesTextView.text;
    
    // Commit to core data (for comments)
    [[[TBScopeData sharedData] managedObjectContext] save:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AnalysisSegue"])
    {
        UIViewController <TBScopeViewControllerContext> *avc = [segue destinationViewController];
        avc.currentSlide = (Slides*)self.currentExam.examSlides[0]; //TODO: other slides
       
    }
}

- (IBAction)uploadButtonPressed:(id)sender
{
    [[GoogleDriveSync sharedGDS] setExamToUpload:self.currentExam];
    
    [[GoogleDriveSync sharedGDS] uploadExam];
    
    
}

@end
