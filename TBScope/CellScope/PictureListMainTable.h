//
//  PictureListMainTable.h
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSUserContext;

@interface PictureListMainTable : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CSUserContext *userContext;
@property (nonatomic, strong) NSMutableArray *pictureListData;

- (IBAction)logoutButtonPressed:(id)sender;

- (void)readDataForTable;

@end
