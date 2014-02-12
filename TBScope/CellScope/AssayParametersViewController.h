//
//  AssayParametersViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Slides.h"
#import "Users.h"
#import "LoadSampleViewController.h"
#import "DataValidationHelper.h"

@interface AssayParametersViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong,nonatomic) Slides* currentSlide;

@property (weak, nonatomic) IBOutlet UITextField* nameTextField;
@property (weak, nonatomic) IBOutlet UITextField* patientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField* slideNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField* readNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField* locationTextField;
@property (weak, nonatomic) IBOutlet UITextField* addressTextField;
@property (weak, nonatomic) IBOutlet UITextView* notesTextView;

@property (weak, nonatomic) IBOutlet UILabel* userLabel;
@property (weak, nonatomic) IBOutlet UILabel* gpsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* gpsSpinner;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;

@property (weak, nonatomic) IBOutlet UISwitch* doAnalysisSwitch;



@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *slideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *readNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *runAnalysisLabel;

@end
