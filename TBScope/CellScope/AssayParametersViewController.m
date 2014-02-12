//
//  AssayParametersViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "AssayParametersViewController.h"


@implementation AssayParametersViewController

@synthesize managedObjectContext,currentUser,currentSlide;
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
    
    if (self.currentSlide==nil)
    {
        // Set up a Slide entry to store in Core Data
        Slides* newSlide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
        
        newSlide.datePrepared = [NSDate timeIntervalSinceReferenceDate];
        newSlide.userName = self.currentUser.username;
        newSlide.gpsLocation = @"0,0";
        newSlide.slideNumber = 1;
        newSlide.readNumber = 1;
        
        self.currentSlide = newSlide;
    }
    
    //populate the form with data from currentSlide
    //note that we include this in viewWillAppear rather than viewDidLoad just in case downstream forms edit things
    nameTextField.text = self.currentSlide.patientName;
    patientIDTextField.text = self.currentSlide.patientID;
    addressTextField.text = self.currentSlide.patientAddress;
    slideNumberTextField.text = [[NSString alloc] initWithFormat:@"%d",self.currentSlide.slideNumber]; //TODO: replace with numeric fields
    readNumberTextField.text = [[NSString alloc] initWithFormat:@"%d",self.currentSlide.readNumber]; //TODO: replace with numeric fields
    locationTextField.text = self.currentSlide.location;
    notesTextView.text = self.currentSlide.notes;
    gpsLabel.text = self.currentSlide.gpsLocation;
    
    userLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User: %@", nil),self.currentSlide.userName];
    
    doAnalysisSwitch.on = YES;

    NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.currentSlide.datePrepared];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]]; //TODO: move to preferences
    NSString* datePreparedString = [dateFormatter stringFromDate:date];
    dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date: %@", nil),datePreparedString];
    
    //bring up keyboard and set focus on patient name field
    [nameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController])
    {
        //user pressed back, so roll back changes
        [self.managedObjectContext rollback];
    }
    else
    {
        //save changes to core data
        self.currentSlide.patientName = nameTextField.text;
        self.currentSlide.patientID = patientIDTextField.text;
        self.currentSlide.patientAddress = addressTextField.text;
        self.currentSlide.slideNumber = [slideNumberTextField.text intValue];
        self.currentSlide.readNumber = [readNumberTextField.text intValue];
        self.currentSlide.location = locationTextField.text;
        self.currentSlide.notes = notesTextView.text;
        self.currentSlide.gpsLocation = gpsLabel.text;
        
        // Commit to core data
        NSError *error;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Failed to commit to core data: %@", [error domain]);
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
    LoadSampleViewController* lsvc = (LoadSampleViewController*)[segue destinationViewController];
    lsvc.managedObjectContext = self.managedObjectContext;
    lsvc.currentUser = self.currentUser;
    lsvc.currentSlide = self.currentSlide;
    lsvc.doAnalysis = doAnalysisSwitch.on;
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
