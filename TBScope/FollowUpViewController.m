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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.slide1NAButton setTitle:NSLocalizedString(@"N/A",nil) forState:UIControlStateNormal];
    //...
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
    }
    else if (sender==self.xpertResistantButton || sender==self.xpertSusceptibleButton) {
        
        [self.xpertResistantButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.xpertSusceptibleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        UIButton* btnPressed = (UIButton*)sender;
        [btnPressed setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    
}

@end
