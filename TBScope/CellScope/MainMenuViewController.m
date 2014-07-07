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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBTIndicator)
                                                 name:@"BluetoothConnected"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBTIndicator)
                                                 name:@"BluetoothDisconnected"
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
    [self setBTIndicator];
    [self setMenuPermissions];
}

- (void)setMenuPermissions
{
    NSString* accessLevel = [[[TBScopeData sharedData] currentUser] accessLevel];
    if ([accessLevel isEqualToString:@"ADMIN"]) {
        self.configurationButton.enabled = YES;
        self.scanSlideButton.enabled = YES;
    }
    else if ([accessLevel isEqualToString:@"USER"]) {
        self.configurationButton.enabled = NO;
        self.scanSlideButton.enabled = YES;
    }
    

}

- (void)setBTIndicator
{
    self.bluetoothIndicator.hidden = ![[[TBScopeHardware sharedHardware] ble] isConnected];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
   
    if([identifier isEqualToString:@"ScanSlideSegue"]) {
        if (![[[TBScopeHardware sharedHardware] ble] isConnected] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"AllowScanWithoutCellScope"]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CellScope Not Connected", nil)
                                                             message:NSLocalizedString(@"Please ensure Bluetooth is enabled and CellScope is powered on.",nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                   otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = 1;
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ScanSlideSegue"])
    {
        EditExamViewController* eevc = (EditExamViewController*)[segue destinationViewController];
        eevc.currentExam = nil;
        eevc.isNewExam = YES;
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
