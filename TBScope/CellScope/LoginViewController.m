//
//  LoginViewController.m
//  CellScope
//
//  Created by UC Berkeley Fletcher Lab on 8/19/12.
//  Copyright (c) 2012 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "LoginViewController.h"
#import "GoogleDriveViewController.h"

@implementation LoginViewController

@synthesize usernameField,passwordField,invalidLogin;


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setSyncIndicator)
                                                 name:@"GoogleSyncStarted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setSyncIndicator)
                                                 name:@"GoogleSyncStopped"
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
    
    usernameField.text = @"";
    passwordField.text = @"";
    invalidLogin.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Automatic Tuberculosis Diagnostic System",nil);
    usernameField.placeholder = NSLocalizedString(@"username", nil);
    passwordField.placeholder = NSLocalizedString(@"password", nil);
    invalidLogin.text = NSLocalizedString(@"Invalid username or password", nil);
    
    self.cellscopeIDLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"];
    self.locationLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultLocation"];
    
    [usernameField becomeFirstResponder];
    
    [self setSyncIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    
    //TODO: have this populate textfields and call resignAndLogin
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BypassLogin"])
    {
        //BYPASS_LOGIN allows you to skip the login screen during debugging
        //it searches Core Data for the admin account, and sets currentUser to that account
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(username == 'admin')"];
        NSMutableArray* results = [CoreDataHelper searchObjectsForEntity:@"Users" withPredicate:pred andSortKey:@"username" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
        [[TBScopeData sharedData] setCurrentUser:(Users*)results[0]];
        [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
        
        [TBScopeData CSLog:@"Login bypassed" inCategory:@"USER"];
    }
    else
        [TBScopeData CSLog:@"Login screen presented" inCategory:@"USER"];
    
    //GoogleDriveViewController *viewController = [[GoogleDriveViewController alloc] init];
    //[self presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)resignAndLogin:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    
    // Check the tag. If this is the username field, jump to the password field
    if (tf.tag == 1) {
        [passwordField becomeFirstResponder];
    }
    // Otherwise we pressed done on the password field, and want to attempt login
    else {
        [sender resignFirstResponder]; //this clears the keyboard
        
        // Setup the search criteria for checking whether password is correct
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(username == %@ && password == %@)", usernameField.text, passwordField.text];
        
        // search the users database
        NSMutableArray* results = [CoreDataHelper searchObjectsForEntity:@"Users" withPredicate:pred andSortKey:@"username" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
        
        if(results.count > 0) {
            //password verified, set currentUser to that user
            [[TBScopeData sharedData] setCurrentUser:(Users*)results[0]];

            //Segue transition to next view
            [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
            [TBScopeData CSLog:[NSString stringWithFormat:@"Successful login for username: %@",usernameField.text] inCategory:@"USER"];
            
        }
        else {
            [TBScopeData CSLog:[NSString stringWithFormat:@"Invalid uesrname/password combo, username entered: %@",usernameField.text] inCategory:@"USER"];
            //username/password invalid, start over
            passwordField.text = @"";
            invalidLogin.hidden = NO;
            

        }
    }
}

@end
