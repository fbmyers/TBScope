//
//  LoginViewController.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "LoginViewController.h"
#import "GoogleDriveViewController.h"

@implementation LoginViewController

@synthesize managedObjectContext,currentUser;
@synthesize usernameField,passwordField,invalidLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    
    NSLog(@"current language: %@" ,[[NSLocale preferredLanguages] objectAtIndex:0]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    usernameField.text = @"";
    passwordField.text = @"";
    invalidLogin.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Automated Tuberculosis Diagnostic System",nil);
    usernameField.placeholder = NSLocalizedString(@"username", nil);
    passwordField.placeholder = NSLocalizedString(@"password", nil);
    invalidLogin.text = NSLocalizedString(@"Invalid username or password", nil);
    
    [usernameField becomeFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BypassLogin"])
    {
        //BYPASS_LOGIN allows you to skip the login screen during debugging
        //it searches Core Data for the admin account, and sets currentUser to that account
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(username == 'admin')"];
        NSMutableArray* results = [CoreDataHelper searchObjectsForEntity:@"Users" withPredicate:pred andSortKey:@"username" andSortAscending:YES andContext:self.managedObjectContext];
        self.currentUser = (Users*)results[0];
        [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
    }
    
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
        NSMutableArray* results = [CoreDataHelper searchObjectsForEntity:@"Users" withPredicate:pred andSortKey:@"username" andSortAscending:YES andContext:self.managedObjectContext];
        
        if(results.count > 0) {
            //password verified, set currentUser to that user
            self.currentUser = (Users*)results[0];

            //Segue transition to next view
            [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
            
        }
        else {
            //username/password invalid, start over
            passwordField.text = @"";
            invalidLogin.hidden = NO;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
    MainMenuViewController *menu = (MainMenuViewController *)[[navController viewControllers] lastObject];
    
    // Pass Core Data and user context to next view
    menu.managedObjectContext = self.managedObjectContext;
    menu.currentUser = self.currentUser;
}

@end
