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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setStatusLabel)
                                                 name:@"StatusUpdated"
                                               object:nil];
}

- (void)setStatusLabel
{
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.text = [NSString stringWithFormat:@"Battery = %2.2fV\nTemperature = %2.1fC\nHumidity = %2.1f%%",
                             [[TBScopeHardware sharedHardware] batteryVoltage],
                             [[TBScopeHardware sharedHardware] temperature],
                             [[TBScopeHardware sharedHardware] humidity]];
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
    
    //localization
    [self.navigationItem setTitle:NSLocalizedString(@"Main Menu",nil)];
    self.loggedInAs.text = [NSString stringWithFormat:NSLocalizedString(@"Logged in as: %@",nil),[[[TBScopeData sharedData] currentUser] username]];
    self.syncLabel.text = NSLocalizedString(@"Syncing...", nil);
    self.bluetoothIndicator.text = NSLocalizedString(@"Bluetooth Connected", nil);
    
    self.cellscopeIDLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"];
    self.locationLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultLocation"];

    [TBScopeData CSLog:@"Main menu screen presented" inCategory:@"USER"];
    
    [self setSyncIndicator];
    [self setBTIndicator];
    [self setMenuPermissions];
    
    self.statusUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getStatusUpdate) userInfo:nil repeats:YES];
    

    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.statusUpdateTimer invalidate];
    self.statusUpdateTimer = nil;
}

- (void)getStatusUpdate
{
    [[TBScopeHardware sharedHardware] requestStatusUpdate];
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
    self.bluetoothIndicator.hidden = ![[TBScopeHardware sharedHardware] isConnected];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
   
    if([identifier isEqualToString:@"ScanSlideSegue"]) {
        if (![[TBScopeHardware sharedHardware] isConnected] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"AllowScanWithoutCellScope"]) {
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
