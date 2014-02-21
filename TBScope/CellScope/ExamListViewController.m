//
//  SlideListViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "ExamListViewController.h"

//TODO: add Google Drive upload button
//TODO: add "sync'ed" field to each slide, so we only update those that have been modified

@implementation ExamListViewController

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
    self.examListData = [CoreDataHelper getObjectsForEntity:@"Exams" withSortKey:@"examID" andSortAscending:NO andContext:[[TBScopeData sharedData] managedObjectContext]];
    
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
    return [self.examListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ExamListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Get the core data object we need to use to populate this table cell
    Exams* currentCell = [self.examListData objectAtIndex:indexPath.row];
    Slides* currentSlide1; Slides* currentSlide2; Slides* currentSlide3;
    if (currentCell.examSlides.count > 0)
        currentSlide1 = (Slides*)[currentCell.examSlides objectAtIndex:0];
    if (currentCell.examSlides.count > 1)
        currentSlide2 = (Slides*)[currentCell.examSlides objectAtIndex:1];
    if (currentCell.examSlides.count > 2)
        currentSlide3 = (Slides*)[currentCell.examSlides objectAtIndex:2];
    
    
    
    // Fill in the cell contents
    NSString* dateString;
    if (currentSlide1!=nil) {
        NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:currentSlide1.dateCollected];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
        dateString = [dateFormatter stringFromDate:date];
    }
    else
    {
        dateString = @"N/A";
    }
    
    
    cell.patientIDLabel.text = currentCell.patientID;
    cell.patientNameLabel.text = currentCell.patientName;
    cell.locationLabel.text = currentCell.location;
    cell.examIDLabel.text = currentCell.examID;
    
    
    cell.scoreLabel1.text = [NSString stringWithFormat:@"%3.2f",currentSlide1.slideAnalysisResults.score*100];
    
    if ([currentSlide1.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        cell.scoreLabel1.backgroundColor = [UIColor redColor];
    else if ([currentSlide1.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        cell.scoreLabel1.backgroundColor = [UIColor greenColor];
    else if ([currentSlide1.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
        cell.scoreLabel1.backgroundColor = [UIColor yellowColor];
    else
    {
        cell.scoreLabel1.backgroundColor = [UIColor lightGrayColor];
        cell.scoreLabel1.text = @"N/A";
    }

    cell.scoreLabel2.text = [NSString stringWithFormat:@"%3.2f",currentSlide2.slideAnalysisResults.score*100];
    
    if ([currentSlide2.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        cell.scoreLabel2.backgroundColor = [UIColor redColor];
    else if ([currentSlide2.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        cell.scoreLabel2.backgroundColor = [UIColor greenColor];
    else if ([currentSlide2.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
        cell.scoreLabel2.backgroundColor = [UIColor yellowColor];
    else
    {
        cell.scoreLabel2.backgroundColor = [UIColor lightGrayColor];
        cell.scoreLabel2.text = @"N/A";
    }
    
    cell.scoreLabel3.text = [NSString stringWithFormat:@"%3.2f",currentSlide3.slideAnalysisResults.score*100];
    
    if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
        cell.scoreLabel3.backgroundColor = [UIColor redColor];
    else if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
        cell.scoreLabel3.backgroundColor = [UIColor greenColor];
    else if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
        cell.scoreLabel3.backgroundColor = [UIColor yellowColor];
    else
    {
        cell.scoreLabel3.backgroundColor = [UIColor lightGrayColor];
        cell.scoreLabel3.text = @"N/A";
    }
    
    cell.usernameLabel.text = currentCell.userName;
    cell.dateLabel.text = dateString;
    
    return cell;
}

//TODO: should throw up a confirmation dialog box when user deletes a slide
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Exams* currentCell = [self.examListData objectAtIndex:indexPath.row];
        [[[TBScopeData sharedData] managedObjectContext] deleteObject:currentCell];
        
        // Commit
        [[[TBScopeData sharedData] managedObjectContext] save:nil];
        
        //remove from the in-memory array
        [self.examListData removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ResultsSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
        Exams* selectedExam = [self.examListData objectAtIndex:indexPath.row];
        
        ResultsTabBarController *rtbc = (ResultsTabBarController*)[segue destinationViewController];
        rtbc.currentExam = selectedExam;
    }
}



@end
