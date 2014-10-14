//
//  FollowUpViewController.m
//  TBScope
//
//  Created by Frankie Myers on 10/8/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "FollowUpViewController.h"

@interface FollowUpViewController ()

@end

@implementation FollowUpViewController

BOOL _hasChanges = NO;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.znLabel setText:NSLocalizedString(@"ZN", nil)];
    [self.xpertMTBLabel setText:NSLocalizedString(@"GeneXpert MTB", nil)];
    [self.xpertRIFLabel setText:NSLocalizedString(@"GeneXpert RIF", nil)];
    [self.slide1Label setText:[NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),1]];
    [self.slide2Label setText:[NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),2]];
    [self.slide3Label setText:[NSString stringWithFormat:NSLocalizedString(@"Slide %d", nil),3]];
    
    [self.slide1NAButton setTitle:NSLocalizedString(@"N/A",nil) forState:UIControlStateNormal];
    [self.slide2NAButton setTitle:NSLocalizedString(@"N/A",nil) forState:UIControlStateNormal];
    [self.slide3NAButton setTitle:NSLocalizedString(@"N/A",nil) forState:UIControlStateNormal];
    [self.xpertNAButton setTitle:NSLocalizedString(@"N/A",nil) forState:UIControlStateNormal];
    [self.slide1ScantyButton setTitle:NSLocalizedString(@"Scanty",nil) forState:UIControlStateNormal];
    [self.slide2ScantyButton setTitle:NSLocalizedString(@"Scanty",nil) forState:UIControlStateNormal];
    [self.slide3ScantyButton setTitle:NSLocalizedString(@"Scanty",nil) forState:UIControlStateNormal];
    [self.xpertNegativeButton setTitle:NSLocalizedString(@"Negative",nil) forState:UIControlStateNormal];
    [self.xpertPositiveButton setTitle:NSLocalizedString(@"Positive",nil) forState:UIControlStateNormal];
    [self.xpertIndeterminateButton setTitle:NSLocalizedString(@"Indeterminate",nil) forState:UIControlStateNormal];
    [self.xpertSusceptibleButton setTitle:NSLocalizedString(@"Susceptible",nil) forState:UIControlStateNormal];
    [self.xpertResistantButton setTitle:NSLocalizedString(@"Resistant",nil) forState:UIControlStateNormal];
    
    self.slide1NAButton.hidden = !(self.currentExam.examSlides.count>0);
    self.slide1ScantyButton.hidden = !(self.currentExam.examSlides.count>0);
    self.slide10Button.hidden = !(self.currentExam.examSlides.count>0);
    self.slide11Button.hidden = !(self.currentExam.examSlides.count>0);
    self.slide12Button.hidden = !(self.currentExam.examSlides.count>0);
    self.slide13Button.hidden = !(self.currentExam.examSlides.count>0);
    
    self.slide2NAButton.hidden = !(self.currentExam.examSlides.count>1);
    self.slide2ScantyButton.hidden = !(self.currentExam.examSlides.count>1);
    self.slide20Button.hidden = !(self.currentExam.examSlides.count>1);
    self.slide21Button.hidden = !(self.currentExam.examSlides.count>1);
    self.slide22Button.hidden = !(self.currentExam.examSlides.count>1);
    self.slide23Button.hidden = !(self.currentExam.examSlides.count>1);

    self.slide3NAButton.hidden = !(self.currentExam.examSlides.count>2);
    self.slide3ScantyButton.hidden = !(self.currentExam.examSlides.count>2);
    self.slide30Button.hidden = !(self.currentExam.examSlides.count>2);
    self.slide31Button.hidden = !(self.currentExam.examSlides.count>2);
    self.slide32Button.hidden = !(self.currentExam.examSlides.count>2);
    self.slide33Button.hidden = !(self.currentExam.examSlides.count>2);
    
    NSString* stringVal;
    
    stringVal = self.currentExam.examFollowUpData.slide1ZNResult;
    if (stringVal==nil)
        [self.slide1NAButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"0"])
        [self.slide10Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"SCANTY"])
        [self.slide1ScantyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"1+"])
        [self.slide11Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"2+"])
        [self.slide12Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"3+"])
        [self.slide13Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];

    stringVal = self.currentExam.examFollowUpData.slide2ZNResult;
    if (stringVal==nil)
        [self.slide2NAButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"0"])
        [self.slide20Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"SCANTY"])
        [self.slide2ScantyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"1+"])
        [self.slide21Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"2+"])
        [self.slide22Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"3+"])
        [self.slide23Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
    stringVal = self.currentExam.examFollowUpData.slide3ZNResult;
    if (stringVal==nil)
        [self.slide3NAButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"0"])
        [self.slide30Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"SCANTY"])
        [self.slide3ScantyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"1+"])
        [self.slide31Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"2+"])
        [self.slide32Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"3+"])
        [self.slide33Button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
    stringVal = self.currentExam.examFollowUpData.xpertMTBResult;
    if (stringVal==nil)
        [self.xpertNAButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"+"])
        [self.xpertPositiveButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"-"])
        [self.xpertNegativeButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"?"])
        [self.xpertIndeterminateButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];

    self.xpertResistantButton.hidden = ![stringVal isEqualToString:@"+"];
    self.xpertSusceptibleButton.hidden = ![stringVal isEqualToString:@"+"];
    self.xpertRIFLabel.hidden = ![stringVal isEqualToString:@"+"];
    
    stringVal = self.currentExam.examFollowUpData.xpertRIFResult;
    if ([stringVal isEqualToString:@"S"])
        [self.xpertSusceptibleButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([stringVal isEqualToString:@"R"])
        [self.xpertResistantButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
    _hasChanges = NO;
    
    [TBScopeData CSLog:@"Follow-up data screen presented" inCategory:@"USER"];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    if (_hasChanges)
    {
        if (self.currentExam.examFollowUpData==nil) {
            FollowUpData* fud = (FollowUpData*)[NSEntityDescription insertNewObjectForEntityForName:@"FollowUpData" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
            self.currentExam.examFollowUpData = fud;
        }
        
        NSString* stringVal;
        
        stringVal = nil;
        if (self.slide10Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"0";
        else if (self.slide1ScantyButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"SCANTY";
        else if (self.slide11Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"1+";
        else if (self.slide12Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"2+";
        else if (self.slide13Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"3+";
        self.currentExam.examFollowUpData.slide1ZNResult = stringVal;
        
        stringVal = nil;
        if (self.slide20Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"0";
        else if (self.slide2ScantyButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"SCANTY";
        else if (self.slide21Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"1+";
        else if (self.slide22Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"2+";
        else if (self.slide23Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"3+";
        self.currentExam.examFollowUpData.slide2ZNResult = stringVal;
        
        stringVal = nil;
        if (self.slide30Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"0";
        else if (self.slide3ScantyButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"SCANTY";
        else if (self.slide31Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"1+";
        else if (self.slide32Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"2+";
        else if (self.slide33Button.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"3+";
        self.currentExam.examFollowUpData.slide3ZNResult = stringVal;
        
        stringVal = nil;
        if (self.xpertNegativeButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"-";
        else if (self.xpertPositiveButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"+";
        else if (self.xpertIndeterminateButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"?";
        self.currentExam.examFollowUpData.xpertMTBResult = stringVal;
        
        stringVal = nil;
        if (self.xpertSusceptibleButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"S";
        else if (self.xpertResistantButton.titleLabel.textColor==[UIColor yellowColor])
            stringVal = @"R";
        self.currentExam.examFollowUpData.xpertRIFResult = stringVal;
        
        [TBScopeData touchExam:self.currentExam];
        [[TBScopeData sharedData] saveCoreData];
    }
    
}

- (IBAction)didPressButton:(id)sender
{
    if (sender==self.slide1NAButton || sender==self.slide10Button || sender==self.slide1ScantyButton || sender==self.slide11Button || sender==self.slide12Button || sender==self.slide13Button) {
        
        [self.slide1NAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide10Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide1ScantyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide11Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide12Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide13Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
        //self.currentExam.followUpData.slide1ZN = btnPressed.tag;
        
    }
    else if (sender==self.slide2NAButton || sender==self.slide20Button || sender==self.slide2ScantyButton || sender==self.slide21Button || sender==self.slide22Button || sender==self.slide23Button) {
        
        [self.slide2NAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide20Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide2ScantyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide21Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide22Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide23Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];

    }
    else if (sender==self.slide3NAButton || sender==self.slide30Button || sender==self.slide3ScantyButton || sender==self.slide31Button || sender==self.slide32Button || sender==self.slide33Button) {
        
        [self.slide3NAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide30Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide3ScantyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide31Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide32Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.slide33Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
    }
    else if (sender==self.xpertNAButton || sender==self.xpertNegativeButton || sender==self.xpertPositiveButton || sender==self.xpertIndeterminateButton) {
        
        [self.xpertNAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.xpertNegativeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.xpertPositiveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.xpertIndeterminateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
        self.xpertResistantButton.hidden = !(btnPressed==self.xpertPositiveButton);
        self.xpertSusceptibleButton.hidden = !(btnPressed==self.xpertPositiveButton);
        self.xpertRIFLabel.hidden = !(btnPressed==self.xpertPositiveButton);
        
    }
    else if (sender==self.xpertResistantButton || sender==self.xpertSusceptibleButton) {
        
        [self.xpertResistantButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.xpertSusceptibleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    
    _hasChanges = YES;
}

@end
