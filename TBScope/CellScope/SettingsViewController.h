//
//  SettingsViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Users.h"
#import "TBScopeData.h"

@interface SettingsViewController : UITableViewController


@property (strong, nonatomic) Users* currentUser;

@property (weak, nonatomic) IBOutlet UITextField* defaultLocation;
@property (weak, nonatomic) IBOutlet UIPickerView* language;
@property (weak, nonatomic) IBOutlet UITextField* dateFormat;
@property (weak, nonatomic) IBOutlet UITextField* cellscopeID;
@property (weak, nonatomic) IBOutlet UITextField* numFieldsPerSlide;
@property (weak, nonatomic) IBOutlet UITextField* patientIDFormat;
@property (weak, nonatomic) IBOutlet UITextField* maxNameLocationAddressLength;
@property (weak, nonatomic) IBOutlet UITextField* redThreshold;
@property (weak, nonatomic) IBOutlet UITextField* yellowThreshold;
@property (weak, nonatomic) IBOutlet UITextField* diagnosticThreshold;
@property (weak, nonatomic) IBOutlet UITextField* numPatchesToAverage;
@property (weak, nonatomic) IBOutlet UISwitch* doAnalysisByDefault;
@property (weak, nonatomic) IBOutlet UISwitch* bypassLogin;
@property (weak, nonatomic) IBOutlet UISwitch* substituteTBImage;
@property (weak, nonatomic) IBOutlet UITextField* tbImagePath;
@property (weak, nonatomic) IBOutlet UISwitch* resetCoreData;

- (IBAction)didPressResetSettings;

- (void)fetchValuesFromPreferences;
- (void)saveValuesToPreferences;

@end
