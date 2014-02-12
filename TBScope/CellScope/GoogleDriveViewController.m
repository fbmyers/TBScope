//
//  GoogleDriveViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 10/20/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "GoogleDriveViewController.h"

//#import "ViewController.h"

static NSString *const kKeychainItemName = @"CellScope";
static NSString *const kClientID = @"822665295778.apps.googleusercontent.com";
static NSString *const kClientSecret = @"mbDjzu2hKDW23QpNJXe_0Ukd";

//TODO: needs to be merged with GoogleDriveSync/context model (this should just be thin UI)

@implementation GoogleDriveViewController

@synthesize driveService;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the drive service & load existing credentials from the keychain if available
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Always display the camera UI.
    //[self showCamera];
    
    //if logged in, display current username and the logout button, else, load the login screen
    if ([self.driveService.authorizer canAuthorize]) {
        NSMutableString* s = [NSMutableString stringWithString:@"Logged in as: "];
        [s appendString:[self.driveService.authorizer userEmail]];
        self.usernameLabel.text = s;
        [self.loginButton setTitle:@"Log Out" forState:UIControlStateNormal];
    }
    else
    {
        self.usernameLabel.text = @"Not logged in to Google Drive";
        [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    }
}

- (IBAction)logInOut:(id)sender
{
    
    if ([self.driveService.authorizer canAuthorize]) {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@"CellScope"];
        [self viewDidAppear:NO];
    }
    else
    {
        
        [self.navigationController pushViewController:[self createAuthController] animated:YES];
        
    }
    
 }


// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle: @"Authentication Error"
                                           message: error.localizedDescription
                                          delegate: nil
                                 cancelButtonTitle: @"OK"
                                 otherButtonTitles: nil];
        [alert show];
        
        self.driveService.authorizer = nil;
    }
    else
    {
        self.driveService.authorizer = authResult;
    }
}

@end
