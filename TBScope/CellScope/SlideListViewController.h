//
//  SlideListViewController.h
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Users.h"
#import "Slides.h"
#import "ResultsTabBarController.h"
#import "SlideListTableViewCell.h"

@interface SlideListViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong, nonatomic) NSMutableArray *slideListData;


@end
