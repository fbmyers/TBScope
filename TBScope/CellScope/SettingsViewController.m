//
//  SettingsViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize currentUser;
@synthesize defaultLocation,language,dateFormat,cellscopeID,numFieldsPerSlide,patientIDFormat,maxNameLocationAddressLength,redThreshold,yellowThreshold,diagnosticThreshold,numPatchesToAverage,doAnalysisByDefault,bypassLogin,substituteTBImage,tbImagePath,resetCoreData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchValuesFromPreferences];
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
    self.dateFormat.text = [prefs stringForKey:@"DateFormat"];
    
    self.patientIDFormat.text = [[NSString alloc] initWithFormat:@"%@",[prefs stringForKey:@"PatientIDFormat"]];
    self.maxNameLocationAddressLength.text = [[NSString alloc] initWithFormat:@"%d",[prefs integerForKey:@"MaxNameLocationAddressLength"]];
    self.redThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"RedThreshold"]];
    self.yellowThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"YellowThreshold"]];
    self.diagnosticThreshold.text = [[NSString alloc] initWithFormat:@"%f",[prefs floatForKey:@"DiagnosticThreshold"]];
    self.tbImagePath.text = [prefs stringForKey:@"ExampleTBImageURL"];
    self.doAnalysisByDefault.on = [prefs boolForKey:@"DoAnalysisByDefault"];
    self.bypassLogin.on = [prefs boolForKey:@"BypassLogin"];
    self.substituteTBImage.on = [prefs boolForKey:@"RunWithExampleTBImage"];
    self.resetCoreData.on = [prefs boolForKey:@"ResetCoreDataOnStartup"];
    
}

- (void)saveValuesToPreferences
{
    NSLog(@"Saving preferences.");
    
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
    
    [prefs setValue:self.dateFormat.text forKey:@"DateFormat"];
    [prefs setValue:self.tbImagePath.text forKey:@"ExampleTBImageURL"];
    [prefs setValue:self.defaultLocation.text forKey:@"DefaultLocation"];
    
    [prefs setInteger:self.maxNameLocationAddressLength.text.integerValue forKey:@"MaxNameLocationAddressLength"];
    [prefs setInteger:self.numFieldsPerSlide.text.integerValue forKey:@"NumFieldsPerSlide"];
    [prefs setInteger:self.numPatchesToAverage.text.integerValue forKey:@"NumPatchesToAverage"];
    [prefs setFloat:self.diagnosticThreshold.text.floatValue forKey:@"DiagnosticThreshold"];
    
    [prefs setBool:self.doAnalysisByDefault.on forKey:@"DoAnalysisByDefault"];
    [prefs setBool:self.bypassLogin.on forKey:@"BypassLogin"];
    [prefs setBool:self.substituteTBImage.on forKey:@"RunWithExampleTBImage"];
    [prefs setBool:self.resetCoreData.on forKey:@"ResetCoreDataOnStartup"];
    
    
    if ([alertString isEqualToString:@""])
        [prefs synchronize];
    
}

@end
