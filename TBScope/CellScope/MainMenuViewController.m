//
//  MainMenuViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "MainMenuViewController.h"

@implementation MainMenuViewController

- (void)viewDidLoad
{
    //make the navigation bar pretty
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setSyncIndicator)
                                                 name:@"GoogleSyncStarted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setSyncIndicator)
                                                 name:@"GoogleSyncStopped"
                                               object:nil];
    
}


- (void)setSyncIndicator
{
    if ([[GoogleDriveSync sharedGDS] isSyncing]) {
        self.syncLabel.hidden = NO;
        [self.syncSpinner startAnimating];
    }
    else {
        self.syncLabel.hidden = YES;
        [self.syncSpinner stopAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.loggedInAs.text = [NSString stringWithFormat:NSLocalizedString(@"Current user: %@",nil),[[[TBScopeData sharedData] currentUser] username]];
    self.cellscopeIDLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"];
    self.locationLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultLocation"];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Main Menu",nil)];

    
    
    [TBScopeData CSLog:@"Main menu screen presented" inCategory:@"USER"];
    
    [self setSyncIndicator];
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
