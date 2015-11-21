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
    
    self.maxAFFailures.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"MaxAFFailures"]];
    self.bfFocusThreshold.text = [[NSString alloc] initWithFormat:@"%2.2f",[prefs floatForKey:@"BFFocusThreshold"]];
    self.flFocusThreshold.text = [[NSString alloc] initWithFormat:@"%2.2f",[prefs floatForKey:@"FLFocusThreshold"]];
    self.initialBFStackSize.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"InitialBFFocusStackSize"]];
    self.initialBFStepHeight.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"InitialBFFocusStepSize"]];
    self.initialBFRetryAttempts.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"InitialBFFocusRetryAttempts"]];
    self.initialBFRetryStackMultiplier.text = [[NSString alloc] initWithFormat:@"%2.2f",[prefs floatForKey:@"InitialBFFocusRetryStackMultiplier"]];
    
    self.bfRefocusStackSize.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"BFRefocusStackSize"]];
    self.bfRefocusStepHeight.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"BFRefocusStepSize"]];
    self.bfRefocusRetryAttempts.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"BFRefocusRetryAttempts"]];
    self.bfRefocusRetryStackMultiplier.text = [[NSString alloc] initWithFormat:@"%2.2f",[prefs floatForKey:@"BFRefocusRetryStackMultiplier"]];
    
    self.flRefocusStackSize.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"FLRefocusStackSize"]];
    self.flRefocusStepHeight.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"FLRefocusStepSize"]];
    self.flRefocusRetryAttempts.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"FLRefocusRetryAttempts"]];
    self.flRefocusRetryStackMultiplier.text = [[NSString alloc] initWithFormat:@"%2.2f",[prefs floatForKey:@"FLRefocusRetryStackMultiplier"]];

    self.cameraExposureDurationBF.text    = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraExposureDurationBF"]];
    self.cameraISOSpeedBF.text            = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraISOSpeedBF"]];
    self.cameraExposureDurationFL.text    = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraExposureDurationFL"]];
    self.cameraISOSpeedFL.text            = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraISOSpeedFL"]];
    self.cameraWhiteBalanceRedGain.text   = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraWhiteBalanceRedGain"]];
    self.cameraWhiteBalanceGreenGain.text = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraWhiteBalanceGreenGain"]];
    self.cameraWhiteBalanceBlueGain.text  = [[NSString alloc] initWithFormat:@"%d", (int)[prefs floatForKey:@"CameraWhiteBalanceBlueGain"]];

    self.stageSettlingTime.text = [[NSString alloc] initWithFormat:@"%2.3f",[prefs floatForKey:@"StageSettlingTime"]];
    self.focusSettlingTime.text = [[NSString alloc] initWithFormat:@"%2.3f",[prefs floatForKey:@"FocusSettlingTime"]];
    self.stageStepDuration.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"StageStepInterval"]];
    self.focusStepDuration.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"FocusStepInterval"]];
    
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
    [prefs setFloat:self.redThreshold.text.floatValue forKey:@"RedThreshold"];
    [prefs setFloat:self.yellowThreshold.text.floatValue forKey:@"YellowThreshold"];
    
    [prefs setBool:self.doAnalysisByDefault.on forKey:@"DoAnalysisByDefault"];
    [prefs setBool:self.bypassLogin.on forKey:@"BypassLogin"];
    [prefs setBool:self.resetCoreData.on forKey:@"ResetCoreDataOnStartup"];
    [prefs setBool:self.wifiOnlyButton.on forKey:@"WifiSyncOnly"];
    
    [prefs setBool:self.autoScanSwitch.on forKey:@"DoAutoScan"];
    [prefs setBool:self.autoFocusSwitch.on forKey:@"DoAutoFocus"];
    [prefs setBool:self.autoLoadSwitch.on forKey:@"DoAutoLoadSlide"];
    [prefs setBool:self.initialBFFocus.on forKey:@"AutoScanInitialFocus"];
    [prefs setBool:self.bypassDataEntrySwitch.on forKey:@"BypassDataEntry"];
    
    [prefs setInteger:self.scanColumns.text.integerValue forKey:@"AutoScanCols"];
    [prefs setInteger:self.scanRows.text.integerValue forKey:@"AutoScanRows"];
    [prefs setInteger:self.fieldSpacing.text.integerValue forKey:@"AutoScanStepsBetweenFields"];
    [prefs setInteger:self.refocusInterval.text.integerValue forKey:@"AutoScanFocusInterval"];
    [prefs setInteger:self.bfIntensity.text.integerValue forKey:@"AutoScanBFIntensity"];
    [prefs setInteger:self.fluorIntensity.text.integerValue forKey:@"AutoScanFluorescentIntensity"];
    
    [prefs setInteger:self.maxAFFailures.text.integerValue forKey:@"MaxAFFailures"];
    [prefs setFloat:self.bfFocusThreshold.text.floatValue forKey:@"BFFocusThreshold"];
    [prefs setFloat:self.flFocusThreshold.text.floatValue forKey:@"FLFocusThreshold"];
    
    [prefs setInteger:self.initialBFStackSize.text.integerValue forKey:@"InitialBFFocusStackSize"];
    [prefs setInteger:self.initialBFStepHeight.text.integerValue forKey:@"InitialBFFocusStepSize"];
    [prefs setInteger:self.initialBFRetryAttempts.text.integerValue forKey:@"InitialBFFocusRetryAttempts"];
    [prefs setFloat:self.initialBFRetryStackMultiplier.text.floatValue forKey:@"InitialBFFocusRetryStackMultiplier"];
    
    [prefs setInteger:self.bfRefocusStackSize.text.integerValue forKey:@"BFRefocusStackSize"];
    [prefs setInteger:self.bfRefocusStepHeight.text.integerValue forKey:@"BFRefocusStepSize"];
    [prefs setInteger:self.bfRefocusRetryAttempts.text.integerValue forKey:@"BFRefocusRetryAttempts"];
    [prefs setFloat:self.bfRefocusRetryStackMultiplier.text.floatValue forKey:@"BFRefocusRetryStackMultiplier"];
    
    [prefs setInteger:self.flRefocusStackSize.text.integerValue forKey:@"FLRefocusStackSize"];
    [prefs setInteger:self.flRefocusStepHeight.text.integerValue forKey:@"FLRefocusStepSize"];
    [prefs setInteger:self.flRefocusRetryAttempts.text.integerValue forKey:@"FLRefocusRetryAttempts"];
    [prefs setFloat:self.flRefocusRetryStackMultiplier.text.floatValue forKey:@"FLRefocusRetryStackMultiplier"];

    [prefs setInteger:self.cameraExposureDurationBF.text.integerValue forKey:@"CameraExposureDurationBF"];
    [prefs setInteger:self.cameraISOSpeedBF.text.integerValue forKey:@"CameraISOSpeedBF"];
    [prefs setInteger:self.cameraExposureDurationFL.text.integerValue forKey:@"CameraExposureDurationFL"];
    [prefs setInteger:self.cameraISOSpeedFL.text.integerValue forKey:@"CameraISOSpeedFL"];
    [prefs setInteger:self.cameraWhiteBalanceRedGain.text.integerValue forKey:@"CameraWhiteBalanceRedGain"];
    [prefs setInteger:self.cameraWhiteBalanceGreenGain.text.integerValue forKey:@"CameraWhiteBalanceGreenGain"];
    [prefs setInteger:self.cameraWhiteBalanceBlueGain.text.integerValue forKey:@"CameraWhiteBalanceBlueGain"];
    
    [prefs setInteger:self.focusStepDuration.text.integerValue forKey:@"FocusStepInterval"];
    [prefs setInteger:self.stageStepDuration.text.integerValue forKey:@"StageStepInterval"];
    [prefs setFloat:self.focusSettlingTime.text.floatValue forKey:@"FocusSettlingTime"];
    [prefs setFloat:self.stageSettlingTime.text.floatValue forKey:@"StageSettlingTime"];
    
    
    if ([alertString isEqualToString:@""])
        [prefs synchronize];
    
}

@end
