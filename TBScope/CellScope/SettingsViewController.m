//
//  SettingsViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchValuesFromPreferences];
    
    [TBScopeData CSLog:@"Settings screen presented" inCategory:@"USER"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveValuesToPreferences];
}

- (IBAction)didPressResetSettings
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    //TODO: add "are you sure" popup
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [prefs removePersistentDomainForName:appDomain];
    
    //override the default for resetting the database
    [prefs setBool:NO forKey:@"ResetCoreDataOnStartup"];
    [prefs synchronize];
    
    [self fetchValuesFromPreferences];
}

- (void)fetchValuesFromPreferences
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    self.cellscopeID.text = [prefs stringForKey:@"CellScopeID"];
    self.numFieldsPerSlide.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"NumFieldsPerSlide"]];
    self.numPatchesToAverage.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"NumPatchesToAverage"]];
    self.defaultLocation.text = [prefs stringForKey:@"DefaultLocation"];
    //self.language = [prefs stringForKey:@"Language"];
    
    self.patientIDFormat.text = [[NSString alloc] initWithFormat:@"%@",[prefs stringForKey:@"PatientIDFormat"]];
    self.maxNameLocationAddressLength.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"MaxNameLocationAddressLength"]];
    self.redThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"RedThreshold"]];
    self.yellowThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"YellowThreshold"]];
    self.diagnosticThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"DiagnosticThreshold"]];
    self.doAnalysisByDefault.on = [prefs boolForKey:@"DoAnalysisByDefault"];
    self.bypassLogin.on = [prefs boolForKey:@"BypassLogin"];
    self.resetCoreData.on = [prefs boolForKey:@"ResetCoreDataOnStartup"];
    
    self.syncInterval.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"SyncInterval"]];
    self.wifiOnlyButton.on = [prefs boolForKey:@"WifiSyncOnly"];
    
    self.autoFocusSwitch.on = [prefs boolForKey:@"DoAutoFocus"];
    self.autoLoadSwitch.on = [prefs boolForKey:@"DoAutoLoadSlide"];
    self.autoScanSwitch.on = [prefs boolForKey:@"DoAutoScan"];
    self.scanColumns.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanCols"]];
    self.scanRows.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanRows"]];
    self.fieldSpacing.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanStepsBetweenFields"]];
    self.refocusInterval.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanFocusInterval"]];
    self.bfIntensity.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanBFIntensity"]];
    self.fluorIntensity.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanFluorescentIntensity"]];
    
    self.bypassDataEntrySwitch.on = [prefs boolForKey:@"BypassDataEntry"];
    self.initialBFFocus.on = [prefs boolForKey:@"AutoScanInitialFocus"];
}

- (void)saveValuesToPreferences
{
    
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString* alertString = @"";
    
    //TODO: add some data validation for each field and finish with all the fields...
    if (self.cellscopeID.text.length==0)
        alertString = @"CellScope ID cannot be blank.";
    else
        [prefs setValue:self.cellscopeID.text forKey:@"CellScopeID"];

    if (self.patientIDFormat.text.length==0)
        alertString = @"Patient ID format cannot be blank.";
    else
        [prefs setValue:self.patientIDFormat.text forKey:@"PatientIDFormat"];
    
    [prefs setValue:self.defaultLocation.text forKey:@"DefaultLocation"];
    
    [prefs setInteger:self.maxNameLocationAddressLength.text.integerValue forKey:@"MaxNameLocationAddressLength"];
    [prefs setInteger:self.numFieldsPerSlide.text.integerValue forKey:@"NumFieldsPerSlide"];
    [prefs setInteger:self.numPatchesToAverage.text.integerValue forKey:@"NumPatchesToAverage"];
    [prefs setInteger:self.syncInterval.text.integerValue forKey:@"SyncInterval"];
    
    [prefs setFloat:self.diagnosticThreshold.text.floatValue forKey:@"DiagnosticThreshold"];
    
    [prefs setBool:self.doAnalysisByDefault.on forKey:@"DoAnalysisByDefault"];
    [prefs setBool:self.bypassLogin.on forKey:@"BypassLogin"];
    [prefs setBool:self.resetCoreData.on forKey:@"ResetCoreDataOnStartup"];
    [prefs setBool:self.wifiOnlyButton.on forKey:@"WifiSyncOnly"];
    
    [prefs setBool:self.autoScanSwitch.on forKey:@"DoAutoScan"];
    [prefs setBool:self.autoFocusSwitch.on forKey:@"DoAutoFocus"];
    [prefs setBool:self.autoLoadSwitch.on forKey:@"DoAutoLoadSlide"];
    [prefs setBool:self.initialBFFocus.on forKey:@"AutoScanInitialFocus"];
    [prefs setBool:self.bypassDataEntrySwitch.on forKey:@"BypassDataEntry"];
    
    /*
    self.scanColumns.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanCols"]];
    self.scanRows.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanRows"]];
    self.fieldSpacing.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanStepsBetweenFields"]];
    self.refocusInterval.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanFocusInterval"]];
    self.bfIntensity.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanBFIntensity"]];
    self.fluorIntensity.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"AutoScanFluorescentIntensity"]];
    */
    
    [prefs setInteger:self.scanColumns.text.integerValue forKey:@"AutoScanCols"];
    [prefs setInteger:self.scanRows.text.integerValue forKey:@"AutoScanRows"];
    [prefs setInteger:self.fieldSpacing.text.integerValue forKey:@"AutoScanStepsBetweenFields"];
    [prefs setInteger:self.refocusInterval.text.integerValue forKey:@"AutoScanFocusInterval"];
    [prefs setInteger:self.bfIntensity.text.integerValue forKey:@"AutoScanBFIntensity"];
    [prefs setInteger:self.fluorIntensity.text.integerValue forKey:@"AutoScanFluorescentIntensity"];
    
    
    if ([alertString isEqualToString:@""])
        [prefs synchronize];
    
}

@end
