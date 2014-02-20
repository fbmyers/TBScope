//
//  GoogleDriveViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 10/20/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GoogleDriveSync.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface GoogleDriveViewController : UIViewController

@property (nonatomic, retain) GTLServiceDrive *driveService; //TODO: make this a singleton
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction) logInOut:(id)sender;

@end
