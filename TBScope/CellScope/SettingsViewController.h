//
//  SettingsViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Presents all the user-configurable settings to the user.

#import <UIKit/UIKit.h>
#import "Users.h"
#import "TBScopeData.h"

@interface SettingsViewController : UITableViewController


@property (strong, nonatomic) Users* currentUser;

@property (weak, nonatomic) IBOutlet UITextField* defaultLocation;
@property (weak, nonatomic) IBOutlet UITextField* cellscopeID;
@property (weak, nonatomic) IBOutlet UITextField* numFieldsPerSlide;
@property (weak, nonatomic) IBOutlet UITextField* patientIDFormat;
@property (weak, nonatomic) IBOutlet UITextField* maxNameLocationAddressLength;
@property (weak, nonatomic) IBOutlet UITextField* redThreshold;
@property (weak, nonatomic) IBOutlet UITextField* yellowThreshold;
@property (weak, nonatomic) IBOutlet UITextField* diagnosticThreshold;
@property (weak, nonatomic) IBOutlet UITextField* numPatchesToAverage;
@property (weak, nonatomic) IBOutlet UITextField *syncInterval;
@property (weak, nonatomic) IBOutlet UISwitch *wifiOnlyButton;

@property (weak, nonatomic) IBOutlet UISwitch* doAnalysisByDefault;
@property (weak, nonatomic) IBOutlet UISwitch* bypassLogin;
@property (weak, nonatomic) IBOutlet UISwitch* resetCoreData;

@property (weak, nonatomic) IBOutlet UISwitch *autoLoadSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoScanSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoFocusSwitch;
@property (weak, nonatomic) IBOutlet UITextField *scanRows;
@property (weak, nonatomic) IBOutlet UITextField *scanColumns;
@property (weak, nonatomic) IBOutlet UITextField *fieldSpacing;
@property (weak, nonatomic) IBOutlet UITextField *refocusInterval;
@property (weak, nonatomic) IBOutlet UITextField *bfIntensity;
@property (weak, nonatomic) IBOutlet UITextField *fluorIntensity;
@property (weak, nonatomic) IBOutlet UISwitch *bypassDataEntrySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *initialBFFocus;



- (IBAction)didPressResetSettings;

- (void)fetchValuesFromPreferences;
- (void)saveValuesToPreferences;

@end
