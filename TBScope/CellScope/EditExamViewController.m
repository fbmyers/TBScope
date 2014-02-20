//
//  AssayParametersViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "EditExamViewController.h"


@implementation EditExamViewController

@synthesize currentExam;
@synthesize patientIDTextField,nameTextField,locationTextField,notesTextView,slideNumberTextField,readNumberTextField,addressTextField,userLabel,gpsLabel,gpsSpinner,dateLabel,doAnalysisSwitch;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //localization
    self.navigationItem.title = NSLocalizedString(@"Assay Parameters", nil);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Next", nil);
    self.nameLabel.text = NSLocalizedString(@"Name", nil);
    self.patientIDLabel.text = NSLocalizedString(@"Patient ID", nil);
    self.slideNumLabel.text = NSLocalizedString(@"Slide #", nil);
    self.readNumLabel.text = NSLocalizedString(@"Read #", nil);
    self.locationLabel.text = NSLocalizedString(@"Location", nil);
    self.patientAddressLabel.text = NSLocalizedString(@"Patient Address", nil);
    self.notesLabel.text = NSLocalizedString(@"Intake Notes", nil);
    self.runAnalysisLabel.text = NSLocalizedString(@"Run Analysis", nil);
    
    
    //match the textview to one of the textfields
    [[self.notesTextView layer] setBorderColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor];
    [[self.notesTextView layer] setBorderWidth:1];
    [[self.notesTextView layer] setCornerRadius:10];
    
    if (self.currentExam==nil)
    {
        // Set up a Exam entry to store in Core Data
        Exams* newExam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
        
        //newSlide.dateScanned = [NSDate timeIntervalSinceReferenceDate];
        newExam.userName = [[[TBScopeData sharedData] currentUser] username];
        newExam.gpsLocation = @"0,0";
        //newSlide.slideNumber = 1;
        
        self.currentExam = newExam;
    }
    
    //populate the form with data from currentSlide
    //note that we include this in viewWillAppear rather than viewDidLoad just in case downstream forms edit things
    self.nameTextField.text = self.currentExam.patientName;
    self.patientIDTextField.text = self.currentExam.patientID;
    self.addressTextField.text = self.currentExam.patientAddress;
    self.locationTextField.text = self.currentExam.location;
    self.notesLabel.text = self.currentExam.intakeNotes;
    self.gpsLabel.text = self.currentExam.gpsLocation;
    
    self.userLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User: %@", nil),self.currentExam.userName];
    
    doAnalysisSwitch.on = YES;

    /*
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.currentSlide.dateScanned];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]]; //TODO: move to preferences
    NSString* datePreparedString = [dateFormatter stringFromDate:date];
    dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date: %@", nil),datePreparedString];
    */
    
    //bring up keyboard and set focus on patient name field
    [self.nameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController])
    {
        //user pressed back, so roll back changes
        [[[TBScopeData sharedData] managedObjectContext] rollback];
    }
    else
    {
        //save changes to core data
        self.currentExam.patientName = nameTextField.text;
        self.currentExam.patientID = patientIDTextField.text;
        self.currentExam.patientAddress = addressTextField.text;
        //self.currentSlide.slideNumber = [slideNumberTextField.text intValue];
        //self.currentSlide.readNumber = [readNumberTextField.text intValue];
        self.currentExam.location = locationTextField.text;
        self.currentExam.intakeNotes = notesTextView.text;
        self.currentExam.gpsLocation = gpsLabel.text;
        
        // Commit to core data
        [[TBScopeData sharedData] saveCoreData];
        
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //perform final data validation before transitioning to slide loading/analysis
    NSString* alertMessage = @"";
    
    if (nameTextField.text.length==0)
    {
        alertMessage = NSLocalizedString(@"Patient name cannot be blank.",nil);
        [nameTextField becomeFirstResponder];
    }
    else if (patientIDTextField.text.length==0)
    {
        alertMessage = NSLocalizedString(@"Patient ID cannot be blank.",nil);
        [patientIDTextField becomeFirstResponder];
    }
    else if (![DataValidationHelper validateString:patientIDTextField.text
                                      withPattern:[[NSUserDefaults standardUserDefaults] stringForKey:@"PatientIDFormat"]])
    {
        alertMessage = NSLocalizedString(@"Patient ID is improperly formatted.",nil);
        [patientIDTextField becomeFirstResponder];
    }
    else if (slideNumberTextField.text.length==0)
    {
        alertMessage = NSLocalizedString(@"Slide number cannot be blank.",nil);
        [slideNumberTextField becomeFirstResponder];
    }
    else if (readNumberTextField.text.length==0)
    {
        alertMessage = NSLocalizedString(@"Read number cannot be blank.",nil);
        [readNumberTextField becomeFirstResponder];
    }
    
    if ([alertMessage isEqualToString:@""])
        return YES;
    else
    {
        //throw up a popup and tell the user what's wrong
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Error",nil) message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return NO;
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EditSlideViewController* esvc = (EditSlideViewController*)[segue destinationViewController];
    esvc.currentExam = self.currentExam;
    
    //lsvc.doAnalysis = doAnalysisSwitch.on; //TODO: remove this
}

//perform text field validation on a character-by-character basis
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //number-only fields
    if ((textField==slideNumberTextField) || (textField==readNumberTextField))
    {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; ++i)
        {
            unichar c = [string characterAtIndex:i];
            if (![numberCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        
        return YES;
    }
    //these fields should have a limited length
    else if (textField==patientIDTextField)
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        //int newLength = [textField.text length] + [string length] - range.length;
        //return (newLength > [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxPatientIDLength"]) ? NO : YES;
    }
    else if ((textField==nameTextField) || (textField==locationTextField) || (textField==addressTextField))
    {
        int newLength = [textField.text length] + [string length] - range.length;
        return (newLength > [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxNameLocationAddressLength"]) ? NO : YES;
    }
    else
        return YES;
}

//this will get called when return/next is pressed on any of the textfields
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    //get the next field (based on tag) and set focus on it
    int nextTag = [textField tag] + 1;
    UIView* nextField = [textField.superview viewWithTag:nextTag];
    if (nextField)
        [nextField becomeFirstResponder];

    return NO;
}

@end
