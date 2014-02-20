//
//  MainMenuViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "MainMenuViewController.h"

@implementation MainMenuViewController

@synthesize loggedInAs;

- (void)viewDidLoad
{
    //make the navigation bar pretty
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    loggedInAs.text = [NSString stringWithFormat:NSLocalizedString(@"Logged in as: %@",nil),[[[TBScopeData sharedData] currentUser] username]];
    [self.navigationItem setTitle:NSLocalizedString(@"Main Menu",nil)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ScanSlideSegue"])
    {
        EditExamViewController* eevc = (EditExamViewController*)[segue destinationViewController];
        eevc.currentExam = nil;
    }
    else if ([segue.identifier isEqualToString:@"ReviewResultsSegue"])
    {

        
    }
    else if ([segue.identifier isEqualToString:@"ConfigurationSegue"])
    {

    }
    
}


- (void)didPressLogout:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[TBScopeData sharedData] setCurrentUser:nil]; //TODO: log via singleton
}

@end
