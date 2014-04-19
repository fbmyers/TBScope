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
    if (self.currentExam==nil)
        return;
    
    ///////////////////////////////////
    //localization
    self.navigationItem.title = NSLocalizedString(@"Review Exam", nil);
    self.examInfoLabel.text = NSLocalizedString(@"Exam Info", nil);
    self.examIDPromptLabel.text = NSLocalizedString(@"Exam ID", nil);
    self.locationPromptLabel.text = NSLocalizedString(@"Clinic", nil);
    self.userPromptLabel.text = NSLocalizedString(@"User", nil);
    self.cellscopeIDPromptLabel.text = NSLocalizedString(@"CellScope ID", nil);
    
    self.patientNamePromptLabel.text = NSLocalizedString(@"Name", nil);
    self.patientIDPromptLabel.text = NSLocalizedString(@"Patient ID", nil);
    self.patientAddressPromptLabel.text = NSLocalizedString(@"Patient Address", nil);
    self.patientGenderPromptLabel.text = NSLocalizedString(@"Gender", nil);
    self.patientDOBPromptLabel.text = NSLocalizedString(@"DOB", nil);
    self.patientHIVStatusPromptLabel.text = NSLocalizedString(@"HIV Status", nil);
    self.intakeNotesPromptLabel.text = NSLocalizedString(@"Intake Notes", nil);
    self.diagnosisNotesPromptLabel.text = NSLocalizedString(@"Diagnosis Notes", nil);
    [self.rescanButton1 setTitle:NSLocalizedString(@"Re-scan", nil) forState:UIControlStateNormal];
    [self.reanalyzeButton1 setTitle:NSLocalizedString(@"Re-analyze", nil) forState:UIControlStateNormal];
    
    self.dateCollectedPromptLabel1.text = NSLocalizedString(@"Collection Date", nil);
    self.dateScannedPromptLabel1.text = NSLocalizedString(@"Scan Date", nil);
    self.sputumQualityPromptLabel1.text = NSLocalizedString(@"Sputum Quality", nil);
    self.imageQualityPromptLabel1.text = NSLocalizedString(@"Image Quality", nil);
    self.fieldsPromptLabel1.text = NSLocalizedString(@"Fields", nil);
    self.numAFBAlgorithmPromptLabel1.text = NSLocalizedString(@"# AFB (Algorithm)", nil);
    self.numAFBConfirmedPromptLabel1.text = NSLocalizedString(@"# AFB (Confirmed)", nil);
    
    self.dateCollectedPromptLabel2.text = NSLocalizedString(@"Collection Date", nil);
    self.dateScannedPromptLabel2.text = NSLocalizedString(@"Scan Date", nil);
    self.sputumQualityPromptLabel2.text = NSLocalizedString(@"Sputum Quality", nil);
    self.imageQualityPromptLabel2.text = NSLocalizedString(@"Image Quality", nil);
    self.fieldsPromptLabel2.text = NSLocalizedString(@"Fields", nil);
    self.numAFBAlgorithmPromptLabel2.text = NSLocalizedString(@"# AFB (Algorithm)", nil);
    self.numAFBConfirmedPromptLabel2.text = NSLocalizedString(@"# AFB (Confirmed)", nil);
    [self.rescanButton2 setTitle:NSLocalizedString(@"Re-scan", nil) forState:UIControlStateNormal];
    [self.reanalyzeButton2 setTitle:NSLocalizedString(@"Re-analyze", nil) forState:UIControlStateNormal];
    
    self.dateCollectedPromptLabel3.text = NSLocalizedString(@"Collection Date", nil);
    self.dateScannedPromptLabel3.text = NSLocalizedString(@"Scan Date", nil);
    self.sputumQualityPromptLabel3.text = NSLocalizedString(@"Sputum Quality", nil);
    self.imageQualityPromptLabel3.text = NSLocalizedString(@"Image Quality", nil);
    self.fieldsPromptLabel3.text = NSLocalizedString(@"Fields", nil);
    self.numAFBAlgorithmPromptLabel3.text = NSLocalizedString(@"# AFB (Algorithm)", nil);
    self.numAFBConfirmedPromptLabel3.text = NSLocalizedString(@"# AFB (Confirmed)", nil);
    [self.rescanButton3 setTitle:NSLocalizedString(@"Re-scan", nil) forState:UIControlStateNormal];
    [self.reanalyzeButton3 setTitle:NSLocalizedString(@"Re-analyze", nil) forState:UIControlStateNormal];
    
    [self.gpsMapButton setTitle:NSLocalizedString(@"Map", nil) forState:UIControlStateNormal];
    [self.addSlideButton setTitle:NSLocalizedString(@"Add Slide", nil) forState:UIControlStateNormal];
    
    //date formatter
    NSDate* date;
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
    self.lastModifiedLabel.text = [df stringFromDate:[TBScopeData dateFromString:self.currentExam.dateModified]];
    
    /////////////////////////////
    //exam & patient info
    self.examIDLabel.text = self.currentExam.examID;
    self.locationLabel.text = self.currentExam.location;
    self.userLabel.text = self.currentExam.userName;
    self.cellscopeIDLabel.text = self.currentExam.cellscopeID;
    self.patientIDLabel.text = self.currentExam.patientID;
    self.patientNameLabel.text = self.currentExam.patientName;
    self.patientAddressLabel.text = self.currentExam.patientAddress;
    self.patientHIVStatusLabel.text = self.currentExam.patientHIVStatus;
    self.patientGenderLabel.text = self.currentExam.patientGender;
    
    [df setTimeStyle:NSDateFormatterNoStyle];
    self.patientDOBLabel.text = [df stringFromDate:[TBScopeData dateFromString:self.currentExam.patientDOB]];
    
    if ([self.currentExam.intakeNotes isEqualToString:@""])
        self.intakeNotesTextView.text = NSLocalizedString(@"NONE",nil);
    else
        self.intakeNotesTextView.text = self.currentExam.intakeNotes;
    self.diagnosisNotesTextView.text = self.currentExam.diagnosisNotes;

    //set textarea to look like textfield
    [[self.diagnosisNotesTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.diagnosisNotesTextView layer] setBorderWidth:1];
    [[self.diagnosisNotesTextView layer] setCornerRadius:10];
    
    //set address label so it vertically aligns text at the top
    CGSize labelSize = self.patientAddressLabel.bounds.size; //  CGSizeMake(250, 50);
    CGSize theStringSize = [self.patientAddressLabel.text sizeWithFont:self.patientAddressLabel.font constrainedToSize:labelSize lineBreakMode:self.patientAddressLabel.lineBreakMode];
    self.patientAddressLabel.frame = CGRectMake(self.patientAddressLabel.frame.origin.x, self.patientAddressLabel.frame.origin.y, theStringSize.width, theStringSize.height);
    
    /////////////////////////////
    // slide info
    
    int examDiagnosis = 0;

    //SLIDE 3
    if (self.currentExam.examSlides.count>2) {
        Slides* slide = (Slides*)self.currentExam.examSlides[2];
        
        date = [TBScopeData dateFromString:slide.dateCollected];
        self.dateCollectedLabel3.text = [df stringFromDate:date];
        date = [TBScopeData dateFromString:slide.dateScanned];
        self.dateScannedLabel3.text = [df stringFromDate:date];
        self.sputumQualityLabel3.text = NSLocalizedString(slide.sputumQuality, nil);
        self.imageQualityLabel3.text = NSLocalizedString(@"Not Evaluated", nil);
        self.numFieldsLabel3.text = [[NSString alloc] initWithFormat:@"%d",(int)slide.slideImages.count];
        
        //display diagnosis info
        if (slide.slideAnalysisResults!=nil)
        {
            self.numAFBAlgorithmLabel3.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBAlgorithm];
            self.numAFBConfirmedLabel3.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBManual];
            
            //helper function to set up score bar
            [self displayScore:slide.slideAnalysisResults
                 withScoreView:self.scoreView3
                   scoreMarker:self.scoreMarker3
                    scoreLabel:self.scoreLabel3];
            
            if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
                examDiagnosis += 100;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
                examDiagnosis += 10;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
                examDiagnosis += 1;
            
            self.addSlideButton.hidden = YES;
        }
        else
        {
            //self.scoreView3.hidden = YES;
            self.scoreMarker3.hidden = YES;
            self.scoreLabel3.hidden = YES;
            self.numAFBAlgorithmLabel3.hidden = YES;
            self.numAFBAlgorithmPromptLabel3.hidden = YES;
            self.numAFBConfirmedLabel3.hidden = YES;
            self.numAFBConfirmedPromptLabel3.hidden = YES;

        }
    }
    else
    {
        //hide this slide and move new button in place of it
        self.scoreMarker3.hidden = YES;
        self.scoreLabel3.hidden = YES;
        self.dateCollectedLabel3.hidden = YES;
        self.dateCollectedPromptLabel3.hidden = YES;
        self.dateScannedLabel3.hidden = YES;
        self.dateScannedPromptLabel3.hidden = YES;
        self.sputumQualityLabel3.hidden = YES;
        self.sputumQualityPromptLabel3.hidden = YES;
        self.imageQualityLabel3.hidden = YES;
        self.imageQualityPromptLabel3.hidden = YES;
        self.numFieldsLabel3.hidden = YES;
        self.fieldsPromptLabel3.hidden = YES;
        self.numAFBAlgorithmLabel3.hidden = YES;
        self.numAFBAlgorithmPromptLabel3.hidden = YES;
        self.numAFBConfirmedLabel3.hidden = YES;
        self.numAFBConfirmedPromptLabel3.hidden = YES;
        self.rescanButton3.hidden = YES;
        self.reanalyzeButton3.hidden = YES;
        
        //move the add slide button under this slide marker
        [self.addSlideButton setCenter:CGPointMake(self.scoreView3.center.x,self.addSlideButton.center.y)];
    }

    //SLIDE 2
    if (self.currentExam.examSlides.count>1) {
        Slides* slide = (Slides*)self.currentExam.examSlides[1];
        
        date = [TBScopeData dateFromString:slide.dateCollected];
        self.dateCollectedLabel2.text = [df stringFromDate:date];
        date = [TBScopeData dateFromString:slide.dateScanned];
        self.dateScannedLabel2.text = [df stringFromDate:date];
        self.sputumQualityLabel2.text = NSLocalizedString(slide.sputumQuality, nil);
        self.imageQualityLabel2.text = NSLocalizedString(@"Not Evaluated", nil);
        self.numFieldsLabel2.text = [[NSString alloc] initWithFormat:@"%d",(int)slide.slideImages.count];
        
        //display diagnosis info
        if (slide.slideAnalysisResults!=nil)
        {
            self.numAFBAlgorithmLabel2.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBAlgorithm];
            self.numAFBConfirmedLabel2.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBManual];
            
            //helper function to set up score bar
            [self displayScore:slide.slideAnalysisResults
                 withScoreView:self.scoreView2
                   scoreMarker:self.scoreMarker2
                    scoreLabel:self.scoreLabel2];
            
            if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
                examDiagnosis += 100;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
                examDiagnosis += 10;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
                examDiagnosis += 1;
            
        }
        else
        {
            //self.scoreView1.hidden = YES;
            self.scoreMarker2.hidden = YES;
            self.scoreLabel2.hidden = YES;
            self.numAFBAlgorithmLabel2.hidden = YES;
            self.numAFBAlgorithmPromptLabel2.hidden = YES;
            self.numAFBConfirmedLabel2.hidden = YES;
            self.numAFBConfirmedPromptLabel2.hidden = YES;

        }
    }
    else
    {
        //hide this slide and move new button in place of it
        self.scoreMarker2.hidden = YES;
        self.scoreLabel2.hidden = YES;
        self.dateCollectedLabel2.hidden = YES;
        self.dateCollectedPromptLabel2.hidden = YES;
        self.dateScannedLabel2.hidden = YES;
        self.dateScannedPromptLabel2.hidden = YES;
        self.sputumQualityLabel2.hidden = YES;
        self.sputumQualityPromptLabel2.hidden = YES;
        self.imageQualityLabel2.hidden = YES;
        self.imageQualityPromptLabel2.hidden = YES;
        self.numFieldsLabel2.hidden = YES;
        self.fieldsPromptLabel2.hidden = YES;
        self.numAFBAlgorithmLabel2.hidden = YES;
        self.numAFBAlgorithmPromptLabel2.hidden = YES;
        self.numAFBConfirmedLabel2.hidden = YES;
        self.numAFBConfirmedPromptLabel2.hidden = YES;
        self.rescanButton2.hidden = YES;
        self.reanalyzeButton2.hidden = YES;
        
        //move the add slide button under this slide marker
        [self.addSlideButton setCenter:CGPointMake(self.scoreView2.center.x,self.addSlideButton.center.y)];
    }
    
    //SLIDE 1
    if (self.currentExam.examSlides.count>0) {
        Slides* slide = (Slides*)self.currentExam.examSlides[0];
        
        date = [TBScopeData dateFromString:slide.dateCollected];
        self.dateCollectedLabel1.text = [df stringFromDate:date];
        date = [TBScopeData dateFromString:slide.dateScanned];
        self.dateScannedLabel1.text = [df stringFromDate:date];
        self.sputumQualityLabel1.text = NSLocalizedString(slide.sputumQuality, nil);
        self.imageQualityLabel1.text = NSLocalizedString(@"Not Evaluated", nil);
        self.numFieldsLabel1.text = [[NSString alloc] initWithFormat:@"%d",(int)slide.slideImages.count];
        
        //display diagnosis info
        if (slide.slideAnalysisResults!=nil)
        {
            self.numAFBAlgorithmLabel1.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBAlgorithm];
            self.numAFBConfirmedLabel1.text = [[NSString alloc] initWithFormat:@"%d",slide.slideAnalysisResults.numAFBManual];
            
            //helper function to set up score bar
            [self displayScore:slide.slideAnalysisResults
                 withScoreView:self.scoreView1
                   scoreMarker:self.scoreMarker1
                    scoreLabel:self.scoreLabel1];
            
            if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
                examDiagnosis += 100;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
                examDiagnosis += 10;
            else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
                examDiagnosis += 1;
            

        }
        else
        {
            //self.scoreView1.hidden = YES;
            self.scoreMarker1.hidden = YES;
            self.scoreLabel1.hidden = YES;
            self.numAFBAlgorithmLabel1.hidden = YES;
            self.numAFBAlgorithmPromptLabel1.hidden = YES;
            self.numAFBConfirmedLabel1.hidden = YES;
            self.numAFBConfirmedPromptLabel1.hidden = YES;

        }
    }
    else
    {
        //hide this slide and move new button in place of it
        self.scoreMarker1.hidden = YES;
        self.scoreLabel1.hidden = YES;
        self.dateCollectedLabel1.hidden = YES;
        self.dateCollectedPromptLabel1.hidden = YES;
        self.dateScannedLabel1.hidden = YES;
        self.dateScannedPromptLabel1.hidden = YES;
        self.sputumQualityLabel1.hidden = YES;
        self.sputumQualityPromptLabel1.hidden = YES;
        self.imageQualityLabel1.hidden = YES;
        self.imageQualityPromptLabel1.hidden = YES;
        self.numFieldsLabel1.hidden = YES;
        self.fieldsPromptLabel1.hidden = YES;
        self.numAFBAlgorithmLabel1.hidden = YES;
        self.numAFBAlgorithmPromptLabel1.hidden = YES;
        self.numAFBConfirmedLabel1.hidden = YES;
        self.numAFBConfirmedPromptLabel1.hidden = YES;
        self.rescanButton1.hidden = YES;
        self.reanalyzeButton1.hidden = YES;
        
        //move the add slide button under this slide marker
        [self.addSlideButton setCenter:CGPointMake(self.scoreView1.center.x,self.addSlideButton.center.y)];
    }

    //overall diagnosis
    //TODO: need to have a discussion about how this is defined, and maybe save it to the exam record itself (would make pushpining easier)
    if (examDiagnosis>=100) {
        self.analysisResultsLabel.text = NSLocalizedString(@"PATIENT IS POSITIVE FOR TUBERCULOSIS", nil);
        self.analysisResultsLabel.backgroundColor = [UIColor redColor];
    }
    else if (examDiagnosis>=20 || examDiagnosis==11 || examDiagnosis==10) {
        self.analysisResultsLabel.text = NSLocalizedString(@"PATIENT RESULTS ARE INDETERMINATE", nil);
        self.analysisResultsLabel.backgroundColor = [UIColor yellowColor];
    }
    else if (examDiagnosis==12 || examDiagnosis>=1) {
        self.analysisResultsLabel.text = NSLocalizedString(@"PATIENT IS NEGATIVE FOR TUBERCULOSIS", nil);
        self.analysisResultsLabel.backgroundColor = [UIColor greenColor];
    }
    else {
        self.analysisResultsLabel.text = NSLocalizedString(@"ANALYSIS HAS NOT BEEN PERFORMED", nil);
        self.analysisResultsLabel.backgroundColor = [UIColor lightGrayColor];
    }
    
    [TBScopeData CSLog:@"Slide diagnosis screen presented" inCategory:@"USER"];    
}

- (void) displayScore:(SlideAnalysisResults*)results
        withScoreView:(UIView*)scoreView
          scoreMarker:(UIImageView*)scoreMarker
        scoreLabel:(UILabel*)scoreLabel
{

    
    if ([results.diagnosis isEqualToString:@"POSITIVE"])
    {
        scoreLabel.backgroundColor = [UIColor redColor];
    }
    else if ([results.diagnosis isEqualToString:@"NEGATIVE"])
    {
        scoreLabel.backgroundColor = [UIColor greenColor];
    }
    else if ([results.diagnosis isEqualToString:@"INDETERMINATE"])
    {
        scoreLabel.backgroundColor = [UIColor yellowColor];
    }
    
    scoreView.backgroundColor = [UIColor redColor];
    //TODO: remove "redthreshold" from settings and just use yellow/diagnostic
    //TODO: if the user changes the diagnostic threshold, the slide will still say + but the colors won't be correct
    float yellowThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"YellowThreshold"];
    float redThreshold = [[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"];
    
    CGRect scoreBarRect;
    scoreBarRect = scoreView.bounds;
    scoreBarRect.size.width = scoreBarRect.size.width*redThreshold;
    UIView* yellowBar = [[UIView alloc] initWithFrame:scoreBarRect];
    yellowBar.backgroundColor = [UIColor yellowColor];
    [scoreView addSubview:yellowBar];
    scoreBarRect = scoreView.bounds;
    scoreBarRect.size.width = scoreBarRect.size.width*yellowThreshold;
    UIView* greenBar = [[UIView alloc] initWithFrame:scoreBarRect];
    greenBar.backgroundColor = [UIColor greenColor];
    [scoreView addSubview:greenBar];
    
    scoreBarRect = scoreView.bounds;
    CGFloat scoreMarkerX = scoreView.center.x-scoreBarRect.size.width/2 + scoreBarRect.size.width*results.score;
    
    [scoreMarker setCenter:CGPointMake(scoreMarkerX,scoreMarker.center.y)];
    [scoreLabel setCenter:CGPointMake(scoreMarkerX, scoreLabel.center.y)];
    
    scoreLabel.text = [[NSString alloc] initWithFormat:@"%3.2f",results.score*100];
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    //commit any notes added here
    if (![self.currentExam.diagnosisNotes isEqualToString:self.diagnosisNotesTextView.text])
    {
        self.currentExam.diagnosisNotes = self.diagnosisNotesTextView.text;
        
        [TBScopeData touchExam:self.currentExam];
        [[TBScopeData sharedData] saveCoreData];
    }

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReAnalyzeSegue"])
    {
        UIViewController <TBScopeViewControllerContext> *avc = [segue destinationViewController];
        avc.currentExam = self.currentExam;
        if (sender==self.reanalyzeButton1)
            avc.currentSlide = (Slides*)self.currentExam.examSlides[0];
        else if (sender==self.reanalyzeButton2)
            avc.currentSlide = (Slides*)self.currentExam.examSlides[1];
        else if (sender==self.reanalyzeButton3)
            avc.currentSlide = (Slides*)self.currentExam.examSlides[2];
       
    }
    else if ([segue.identifier isEqualToString:@"ReScanSegue"])
    {
        UIViewController <TBScopeViewControllerContext> *esvc = [segue destinationViewController];
        esvc.currentExam = self.currentExam;
        if (sender==self.rescanButton1)
            esvc.currentSlide = (Slides*)self.currentExam.examSlides[0];
        else if (sender==self.rescanButton1)
            esvc.currentSlide = (Slides*)self.currentExam.examSlides[1];
        else if (sender==self.rescanButton1)
            esvc.currentSlide = (Slides*)self.currentExam.examSlides[2];
    }
    else if ([segue.identifier isEqualToString:@"AddSlideSegue"])
    {
        UIViewController <TBScopeViewControllerContext> *esvc = [segue destinationViewController];
        esvc.currentExam = (Exams*)self.currentExam;
    }
    else if ([segue.identifier isEqualToString:@"MapSegue"]) {
        MapViewController* mvc = (MapViewController*)[segue destinationViewController];
        mvc.allowSelectingExams = NO;
        mvc.showOnlyCurrentExam = NO;
        mvc.currentExam = self.currentExam;
        mvc.delegate = nil;
        
        //[mvc showExamLocation:self.currentExam];
        
        //mvc.examLocation = [TBScopeData coordinatesFromString:self.currentExam.gpsLocation];
        
    }
}


@end
