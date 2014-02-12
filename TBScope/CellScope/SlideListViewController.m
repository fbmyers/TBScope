//
//  SlideListViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "SlideListViewController.h"

//TODO: add Google Drive upload button
//TODO: add "sync'ed" field to each slide, so we only update those that have been modified

@implementation SlideListViewController

@synthesize managedObjectContext,currentUser,slideListData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //  Grab the data
    self.slideListData = [CoreDataHelper getObjectsForEntity:@"Slides" withSortKey:@"datePrepared" andSortAscending:NO andContext:self.managedObjectContext];
    
    //  Force table refresh
    [self.tableView reloadData];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.slideListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SlideListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //if(cell == nil) {
    //    cell = [[SlideListTableViewCell alloc] init reuseIdentifier:CellIdentifier];
    //}
    
    // Get the core data object we need to use to populate this table cell
    Slides* currentCell = [slideListData objectAtIndex:indexPath.row];
    
    // Fill in the cell contents
    //TODO: make this a custom prototype cell and lay these out better
    
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:currentCell.datePrepared];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    NSString* dateString = [dateFormatter stringFromDate:date];
    
    //NSString* topstring = [[NSString alloc] initWithFormat:@"%@-S%d-R%d, %@",currentCell.patientID,currentCell.slideNumber,currentCell.readNumber,currentCell.patientName];
    //NSString* botstring = [[NSString alloc] initWithFormat:@"%@, %@, %@",currentCell.userName,currentCell.location,dateString];
    
    cell.patientIDLabel.text = currentCell.patientID;
    cell.patientNameLabel.text = currentCell.patientName;
    cell.locationLabel.text = currentCell.location;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%3.2f",currentCell.slideAnalysisResults.score*100];
    if ([currentCell.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        cell.scoreLabel.backgroundColor = [UIColor redColor];
    else if ([currentCell.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        cell.scoreLabel.backgroundColor = [UIColor greenColor];
    else if ([currentCell.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
        cell.scoreLabel.backgroundColor = [UIColor yellowColor];
    else
    {
        cell.scoreLabel.backgroundColor = [UIColor lightGrayColor];
        cell.scoreLabel.text = @"N/A";
    }
    
    cell.usernameLabel.text = currentCell.userName;
    cell.dateLabel.text = dateString;
    
    //cell.textLabel.text = topstring;
    //cell.detailTextLabel.text = botstring;
    
    return cell;
}

//TODO: should throw up a confirmation dialog box when user deletes a slide
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Slides* currentCell = [slideListData objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:currentCell];
        
        // Commit
        [self.managedObjectContext save:nil];
        
        //remove from the in-memory array
        [self.slideListData removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ResultsSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
        Slides* selectedSlide = [slideListData objectAtIndex:indexPath.row];
        
        ResultsTabBarController *rtbc = (ResultsTabBarController*)[segue destinationViewController];
        rtbc.managedObjectContext = self.managedObjectContext;
        rtbc.currentSlide = selectedSlide;
        rtbc.currentUser = self.currentUser;
    }
}



@end
