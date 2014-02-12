//
//  SlideDiagnosisViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/14/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "SlideDiagnosisViewController.h"

@implementation SlideDiagnosisViewController

@synthesize managedObjectContext,currentSlide,currentUser;

//TODO: look at memory mgmt behavior...will this always run?
- (void) viewWillAppear:(BOOL)animated
{
    
    //localization
    self.navigationItem.title = NSLocalizedString(@"Review Slide", nil);
    self.slideInfoLabel.text = NSLocalizedString(@"Slide Info", nil);
    self.analysisResultLabel.text = NSLocalizedString(@"Analysis Result", nil);
    self.dateCollectedPromptLabel.text = NSLocalizedString(@"Date", nil);
    self.namePromptLabel.text = NSLocalizedString(@"Name", nil);
    self.patientIDPromptLabel.text = NSLocalizedString(@"Patient ID", nil);
    self.slideNumPromptLabel.text = NSLocalizedString(@"Slide #", nil);
    self.readNumPromptLabel.text = NSLocalizedString(@"Read #", nil);
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
    
    //general slide info text fields
    NSDate* date;
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.currentSlide.datePrepared];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    NSString* datePreparedString = [dateFormatter stringFromDate:date];
    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.currentSlide.slideAnalysisResults.dateDiagnosed];
    NSString* dateDiagnosedString = [dateFormatter stringFromDate:date];
    
    self.dateCollectedLabel.text = datePreparedString;
    self.nameLabel.text = self.currentSlide.patientName;
    self.patientIDLabel.text = self.currentSlide.patientID;
    self.slideNumberLabel.text = [[NSString alloc] initWithFormat:@"%d",self.currentSlide.slideNumber];
    self.readNumberLabel.text = [[NSString alloc] initWithFormat:@"%d",self.currentSlide.readNumber];
    self.locationLabel.text = self.currentSlide.location;
    self.addressLabel.text = self.currentSlide.patientAddress;
    if ([self.currentSlide.notes isEqualToString:@""])
        self.intakeNotesTextView.text = NSLocalizedString(@"NONE",nil);
    else
        self.intakeNotesTextView.text = self.currentSlide.notes;
    self.userLabel.text = self.currentSlide.userName;
    self.dateAnalyzedLabel.text = dateDiagnosedString;
    
    
    self.numFieldsLabel.text = [[NSString alloc] initWithFormat:@"%d",self.currentSlide.slideImages.count];
    
    
    //display diagnosis info
    if (currentSlide.slideAnalysisResults==nil)
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
        
        if ([currentSlide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        {
            self.diagnosisLabel.text = NSLocalizedString(@"SLIDE IS POSITIVE FOR TUBERCULOSIS",nil);
            self.diagnosisLabel.backgroundColor = [UIColor redColor];
        }
        else if ([currentSlide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        {
            self.diagnosisLabel.text = NSLocalizedString(@"SLIDE IS NEGATIVE FOR TUBERCULOSIS",nil);
            self.diagnosisLabel.backgroundColor = [UIColor greenColor];
        }
        else if ([currentSlide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
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
        CGFloat scoreMarkerX = self.scoreView.center.x-scoreBarRect.size.width/2 + scoreBarRect.size.width*self.currentSlide.slideAnalysisResults.score;
        
        [self.scoreMarker setCenter:CGPointMake(scoreMarkerX,scoreMarkerY)];
    
        
        self.scoreLabel.text = [[NSString alloc] initWithFormat:@"%3.2f",self.currentSlide.slideAnalysisResults.score*100];
        self.imageQualityLabel.text = @"Not Evaluated";
        self.diagnosisNotesTextView.text = self.currentSlide.slideAnalysisResults.notes;
        
        
    }
    

    
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AnalysisSegue"])
    {
        UIViewController <TBScopeViewControllerContext> *avc = [segue destinationViewController];
        avc.managedObjectContext = self.managedObjectContext;
        avc.currentUser = self.currentUser;
        avc.currentSlide = self.currentSlide;
       
    }
}

- (IBAction)uploadButtonPressed:(id)sender
{
    GoogleDriveSync* gds = [[GoogleDriveSync alloc] init]; //put in singleton?
    gds.managedObjectContext = self.managedObjectContext;
    
    gds.slideToUpload = self.currentSlide;
    
    [gds uploadSlide];
    
}

@end
