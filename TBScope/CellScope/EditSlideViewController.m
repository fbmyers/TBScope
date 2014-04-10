//
//  EditSlideViewController.m
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "EditSlideViewController.h"

@interface EditSlideViewController ()

@end

@implementation EditSlideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.sputumQualityChoicesArray = [[NSMutableArray alloc] init];
    
    [self.sputumQualityChoicesArray  addObject:NSLocalizedString(@"GOOD",nil)];
    [self.sputumQualityChoicesArray  addObject:NSLocalizedString(@"BLOOD",nil)];
    [self.sputumQualityChoicesArray  addObject:NSLocalizedString(@"SALIVA",nil)];
    [self.sputumQualityChoicesArray  addObject:NSLocalizedString(@"BLOOD+SALIVA",nil)];
}

- (void) viewWillAppear:(BOOL)animated
{

    //localization
    self.navigationItem.title = NSLocalizedString(@"New Slide", nil);
    self.slideNumLabel.text = NSLocalizedString(@"Slide #", nil);
    self.dateCollectedLabel.text = NSLocalizedString(@"Date Collected", nil);
    self.sputumQualityLabel.text = NSLocalizedString(@"Sputum Quality", nil);
    
    //create a new slide if necessary (should pretty much always happen)
    //TODO: there is a bug if you go forward to slide loading, then back twice, then forward again
    if (self.currentSlide==nil)
    {
        if (self.currentExam.examSlides.count>3)
        {
            NSLog(@"already 3 slides");
            //TODO: error message (ask user to choose slide ot replace?)
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        Slides* newSlide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
        
        newSlide.slideNumber = self.currentExam.examSlides.count+1;
                
        NSString* nowStr = [TBScopeData stringFromDate:[NSDate date]];
        newSlide.dateCollected = nowStr;
        newSlide.dateScanned = nowStr; //switch to NSDate
        
        newSlide.sputumQuality = @"";
        
        self.currentSlide = newSlide;
    
    }
    
    //display slide settings
    self.examIDLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Exam ID: %@", nil),self.currentExam.examID];
    self.patientIDLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Patient ID: %@", nil),self.currentExam.patientID];
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Name: %@", nil),self.currentExam.patientName];
    
    //date scanned (today)
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    NSString* dateString = [df stringFromDate:[TBScopeData dateFromString:self.currentSlide.dateScanned]];
    self.dateScannedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date Scanned: %@", nil),dateString];
    
    UILabel* slideLabel = [[UILabel alloc] init];
    switch (self.currentSlide.slideNumber) {
        case 1:
            slideLabel = self.slide1Label;
            break;
        case 2:
            slideLabel = self.slide2Label;
            break;
        case 3:
            slideLabel = self.slide3Label;
            break;
        default:
            break;
    }
    [[slideLabel layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0].CGColor];
    [[slideLabel layer] setBorderWidth:2];
    [[slideLabel layer] setCornerRadius:10];
    
    
    //date picker for collection date
    [self.dateCollectedPicker setDate:[TBScopeData dateFromString:self.currentSlide.dateCollected]];
    [self.dateCollectedPicker setDatePickerMode:UIDatePickerModeDate];
    
    //self.sputumQualityPicker = ;
    if ([self.currentSlide.sputumQuality isEqualToString:@"GOOD"])
        [self.sputumQualityPicker selectRow:0 inComponent:0 animated:NO];
    else if ([self.currentSlide.sputumQuality isEqualToString:@"BLOOD"])
        [self.sputumQualityPicker selectRow:1 inComponent:0 animated:NO];
    else if ([self.currentSlide.sputumQuality isEqualToString:@"SALIVA"])
        [self.sputumQualityPicker selectRow:2 inComponent:0 animated:NO];
    else if ([self.currentSlide.sputumQuality isEqualToString:@"BLOOD+SALIVA"])
        [self.sputumQualityPicker selectRow:3 inComponent:0 animated:NO];

    [TBScopeData CSLog:@"Edit slide screen presented" inCategory:@"USER"];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController]) 
    {
        //self.currentSlide = nil;
    }
    else
    {
        
        NSString* sc;
        switch ([self.sputumQualityPicker selectedRowInComponent:0]) {
            case 0:
                sc = @"GOOD";
                break;
            case 1:
                sc = @"BLOOD";
                break;
            case 2:
                sc = @"SALIVA";
                break;
            case 3:
                sc = @"BLOOD+SALIVA";
                break;
            default:
                sc = @"";
                break;
        }
        self.currentSlide.sputumQuality = sc;

        self.currentSlide.dateCollected = [TBScopeData stringFromDate:self.dateCollectedPicker.date];
        
        //TODO: allow picking slide #?
        
        // Commit to core data
        [self.currentExam addExamSlidesObject:self.currentSlide];
        
        [TBScopeData touchExam:self.currentExam];
        [[TBScopeData sharedData] saveCoreData];
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LoadSampleViewController* lsvc = (LoadSampleViewController*)[segue destinationViewController];
    lsvc.currentSlide = self.currentSlide;
    
    //lsvc.doAnalysis = doAnalysisSwitch.on; //TODO: remove this
}

//picker view delegates

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.sputumQualityChoicesArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.sputumQualityChoicesArray objectAtIndex: row];
}

@end
