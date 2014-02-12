//
//  MainMenuViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Users.h"
#import "AssayParametersViewController.h"
#import "SlideListViewController.h"
#import "ConfigurationViewController.h"

@interface MainMenuViewController : UIViewController

@property (strong, nonatomic) Users* currentUser;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel* loggedInAs;

- (IBAction)didPressLogout:(id)sender;

@end
