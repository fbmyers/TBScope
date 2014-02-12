//
//  MainMenuViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "MainMenuViewController.h"

@implementation MainMenuViewController

@synthesize currentUser,managedObjectContext;
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
    
    loggedInAs.text = [NSString stringWithFormat:NSLocalizedString(@"Logged in as: %@",nil),currentUser.username];
    [self.navigationItem setTitle:NSLocalizedString(@"Main Menu",nil)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ScanSlideSegue"])
    {
        AssayParametersViewController* apvc = (AssayParametersViewController*)[segue destinationViewController];
        
        apvc.managedObjectContext = self.managedObjectContext;
        apvc.currentUser = self.currentUser;
        apvc.currentSlide = nil;
    }
    else if ([segue.identifier isEqualToString:@"ReviewResultsSegue"])
    {
        SlideListViewController* slvc = (SlideListViewController*)[segue destinationViewController];
        slvc.managedObjectContext = self.managedObjectContext;
        slvc.currentUser = self.currentUser;
        
    }
    else if ([segue.identifier isEqualToString:@"ConfigurationSegue"])
    {
        ConfigurationViewController* cvc = (ConfigurationViewController*)[segue destinationViewController];
        cvc.currentUser = self.currentUser;
    }
    
}


- (void)didPressLogout:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    currentUser = nil;
}

@end
