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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //localization
    self.navigationItem.title = NSLocalizedString(@"New Exam", nil);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Next", nil);
    self.examIDLabel.text = NSLocalizedString(@"Exam ID", nil);
    self.patientIDLabel.text = NSLocalizedString(@"Patient ID", nil);
    self.nameLabel.text = NSLocalizedString(@"Name", nil);
    self.genderLabel.text = NSLocalizedString(@"Gender", nil);
    self.dobLabel.text = NSLocalizedString(@"DOB", nil);
    self.clinicLabel.text = NSLocalizedString(@"Clinic", nil);
    self.addressLabel.text = NSLocalizedString(@"Address", nil);
    self.hivStatusLabel.text = NSLocalizedString(@"HIV Status", nil);
    self.intakeNotesLabel.text = NSLocalizedString(@"Intake Notes", nil);
    [self.mapButton setTitle:NSLocalizedString(@"Map", nil) forState:UIControlStateNormal];
    
    //match the textview to one of the textfields
    [[self.intakeNotesTextView layer] setBorderColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor];
    [[self.intakeNotesTextView layer] setBorderWidth:1];
    [[self.intakeNotesTextView layer] setCornerRadius:10];
    
    //if this is a new exam, set up the entry in core data
    if (self.currentExam==nil)
    {
        //we don't want to sync this new exam until its details have been entered
        [[GoogleDriveSync sharedGDS] setSyncEnabled:NO];
        
        Exams* newExam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
        
        newExam.userName = [[[TBScopeData sharedData] currentUser] username];
        newExam.cellscopeID = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"];
        newExam.bluetoothUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeBTUUID"];
        newExam.ipadMACAddress = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        newExam.ipadName = [[UIDevice currentDevice] name];
        newExam.location = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultLocation"];
        
        //[[[TBScopeData sharedData] locationManager] startUpdatingLocation];
        CLLocationCoordinate2D location = [[[[TBScopeData sharedData] locationManager] location] coordinate];
        newExam.gpsLocation = [TBScopeData stringFromCoordinates:location];

        self.currentExam = newExam;
    }
    
    //if the form is being shown for editing an existing exam (and not for initial scanning, then don't show next button)
    if (self.isNewExam==NO)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Exam", nil);
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    //populate the form with data from currentExam
    self.examIDTextField.text = self.currentExam.examID;
    self.patientIDTextField.text = self.currentExam.patientID;
    self.nameTextField.text = self.currentExam.patientName;
    self.genderTextField.text = self.currentExam.patientGender;
    self.clinicTextField.text = self.currentExam.location;
    self.addressTextField.text = self.currentExam.patientAddress;
    self.hivStatusTextField.text = self.currentExam.patientHIVStatus;
    self.intakeNotesTextView.text = self.currentExam.intakeNotes;
    
    if (self.currentExam.gpsLocation==nil) {
        self.gpsLabel.text = NSLocalizedString(@"NO GPS", nil);
    }
    else
    {
        self.gpsLabel.text = NSLocalizedString(@"GPS OK", nil);
    }
    
    self.userLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User: %@", nil),self.currentExam.userName];
    self.cellscopeIDLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CellScope ID: %@", nil),[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    NSString* birthDateString = [df stringFromDate:[TBScopeData dateFromString:self.currentExam.patientDOB]];
    self.dobTextField.text = birthDateString;
    
    //date picker for DOB
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    comps.day = 0; comps.month = 1; comps.year = 1980;
    [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
    [datePicker addTarget:self action:@selector(updateDOBField:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.dobTextField setInputView:datePicker];
    
    //bring up keyboard and set focus on patient name field
    [self.examIDTextField becomeFirstResponder];
    
    [TBScopeData CSLog:@"Edit exam screen presented" inCategory:@"USER"];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BypassDataEntry"]) {
        self.examIDTextField.text = @"1234";
        self.patientIDTextField.text = @"1234";
        self.nameTextField.text = @"Test Slide";
        
        [self performSegueWithIdentifier:@"NewSlideSegue" sender:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController] && self.isNewExam==YES)
    {
        //user pressed back, so don't save this exam
        [[[TBScopeData sharedData] managedObjectContext] rollback];
    }
    else
    {
        //save changes to core data
        self.currentExam.examID = self.examIDTextField.text;
        self.currentExam.patientName = self.nameTextField.text;
        self.currentExam.patientID = self.patientIDTextField.text;
        self.currentExam.patientGender = self.genderTextField.text;
        self.currentExam.patientHIVStatus = self.hivStatusTextField.text;
        self.currentExam.patientAddress = self.addressTextField.text;
        self.currentExam.location = self.clinicTextField.text;
        self.currentExam.intakeNotes = self.intakeNotesTextView.text;
        self.currentExam.diagnosisNotes = @"";
        
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
        self.currentExam.patientDOB = [TBScopeData stringFromDate:[df dateFromString:self.dobTextField.text]];
        
        [TBScopeData touchExam:self.currentExam];
        [[TBScopeData sharedData] saveCoreData];
    }
    
    [[GoogleDriveSync sharedGDS] setSyncEnabled:YES];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"NewSlideSegue"]) {

        //perform final data validation before transitioning to slide loading/analysis
        NSString* alertMessage = @"";
        
        if (self.examIDTextField.text.length==0)
        {
            alertMessage = NSLocalizedString(@"Exam ID cannot be blank.",nil);
            [self.examIDTextField becomeFirstResponder];
        }
        else if (![TBScopeData validateString:self.examIDTextField.text
                                  withPattern:[[NSUserDefaults standardUserDefaults] stringForKey:@"ExamIDFormat"]])
        {
            alertMessage = NSLocalizedString(@"Exam ID is invalid.",nil);
            [self.examIDTextField becomeFirstResponder];
        }
        else if (![TBScopeData validateString:self.patientIDTextField.text
                                  withPattern:[[NSUserDefaults standardUserDefaults] stringForKey:@"PatientIDFormat"]])
        {
            alertMessage = NSLocalizedString(@"Patient ID is invalid.",nil);
            [self.patientIDTextField becomeFirstResponder];
        }
        else if (self.nameTextField.text.length==0)
        {
            alertMessage = NSLocalizedString(@"Patient name cannot be blank.",nil);
            [self.nameTextField becomeFirstResponder];
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
    else
        return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewSlideSegue"]) {
        EditSlideViewController* esvc = (EditSlideViewController*)[segue destinationViewController];
        esvc.currentExam = self.currentExam;
    }
    else if ([segue.identifier isEqualToString:@"MapSegue"]) {
        MapViewController* mvc = (MapViewController*)[segue destinationViewController];
        mvc.allowSelectingExams = NO;
        mvc.showOnlyCurrentExam = NO;
        mvc.currentExam = self.currentExam;
        mvc.delegate = nil;
        
        
    }
}

-(void)updateDOBField:(id)sender
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    UIDatePicker *picker = (UIDatePicker*)sender;
    self.dobTextField.text = [df stringFromDate:picker.date];
}

//perform text field validation on a character-by-character basis
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField==self.patientIDTextField)
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        
    }
    else if (textField==self.examIDTextField)
    {

    }
    else if ((textField==self.nameTextField) || (textField==self.clinicTextField) || (textField==self.addressTextField))
    {
        return ([newString length] > [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxNameLocationAddressLength"]) ? NO : YES;
    }
    else if (textField==self.genderTextField)
    {
        return ([newString isEqualToString:@""]
            || [newString isEqualToString:NSLocalizedString(@"M", nil)]
            || [newString isEqualToString:NSLocalizedString(@"F", nil)]
            || [newString isEqualToString:NSLocalizedString(@"U", nil)]);
        
    }
    else if (textField==self.hivStatusTextField)
    {
        return ([newString isEqualToString:@""]
                || [newString isEqualToString:NSLocalizedString(@"P", nil)]
                || [newString isEqualToString:NSLocalizedString(@"N", nil)]
                || [newString isEqualToString:NSLocalizedString(@"U", nil)]);
    }
    if (textField==self.dobTextField)
    {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.\\/-"];
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
