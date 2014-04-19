//
//  SlideListViewController.m
//  TBScope
//
//  Created by Frankie Myers on 11/10/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ExamListViewController.h"

//TODO: add Google Drive upload button
//TODO: add "sync'ed" field to each slide, so we only update those that have been modified

@implementation ExamListViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // react to google sync notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable)
                                                 name:@"GoogleSyncUpdate"
                                               object:nil];
    
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

- (void)updateTable
{
    
    //  Grab the data
    self.examListData = [CoreDataHelper getObjectsForEntity:@"Exams" withSortKey:@"dateModified" andSortAscending:NO andContext:[[TBScopeData sharedData] managedObjectContext]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //setup date/time formatters
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle:NSDateFormatterShortStyle];

    [self updateTable];
    
    [self setSyncIndicator];
    
    [TBScopeData CSLog:@"Exam list screen presented" inCategory:@"USER"];
    
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
    Exams* currentExam = [self.examListData objectAtIndex:indexPath.row];
    Slides* currentSlide1; Slides* currentSlide2; Slides* currentSlide3;
    if (currentExam.examSlides.count > 0)
        currentSlide1 = (Slides*)[currentExam.examSlides objectAtIndex:0];
    if (currentExam.examSlides.count > 1)
        currentSlide2 = (Slides*)[currentExam.examSlides objectAtIndex:1];
    if (currentExam.examSlides.count > 2)
        currentSlide3 = (Slides*)[currentExam.examSlides objectAtIndex:2];
    
    
    
    // Fill in the cell contents
    NSString* dateString;
    NSString* timeString;
    if (currentSlide1!=nil) {
        dateString = [self.dateFormatter stringFromDate:[TBScopeData dateFromString:currentSlide1.dateCollected]];
        timeString = [self.timeFormatter stringFromDate:[TBScopeData dateFromString:currentSlide1.dateCollected]];
        
    }
    else
    {
        dateString = @"N/A";
        timeString = @"";
    }
    
    cell.examIDLabel.text = currentExam.examID;
    cell.patientIDLabel.text = currentExam.patientID;
    cell.patientNameLabel.text = currentExam.patientName;
    cell.locationLabel.text = currentExam.location;
    cell.usernameLabel.text = currentExam.userName;
    cell.dateLabel.text = dateString;
    cell.timeLabel.text = timeString;
    
    cell.scoreLabel1.text = [NSString stringWithFormat:@"%3.1f",currentSlide1.slideAnalysisResults.score*100];
    [cell.scoreLabel1.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [cell.scoreLabel1.layer setBorderWidth:1];
    if (currentSlide1!=nil)
    {
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
    }
    else
    {
        cell.scoreLabel1.backgroundColor = [UIColor blackColor];

        cell.scoreLabel1.text = @"";
    }
    
    cell.scoreLabel2.text = [NSString stringWithFormat:@"%3.1f",currentSlide2.slideAnalysisResults.score*100];
    [cell.scoreLabel2.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [cell.scoreLabel2.layer setBorderWidth:1];
    if (currentSlide2!=nil)
    {
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
    }
    else
    {
        cell.scoreLabel2.backgroundColor = [UIColor blackColor];
        cell.scoreLabel2.text = @"";
    }
    
    cell.scoreLabel3.text = [NSString stringWithFormat:@"%3.1f",currentSlide3.slideAnalysisResults.score*100];
    [cell.scoreLabel3.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [cell.scoreLabel3.layer setBorderWidth:1];
    if (currentSlide3!=nil)
    {
        if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
            cell.scoreLabel3.backgroundColor = [UIColor redColor];
        else if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
            cell.scoreLabel3.backgroundColor = [UIColor greenColor];
        else if ([currentSlide3.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
            cell.scoreLabel3.backgroundColor = [UIColor yellowColor];
        else //algorithm hasn't run yet
        {
            cell.scoreLabel3.backgroundColor = [UIColor lightGrayColor];
            cell.scoreLabel3.text = @"N/A";
        }
    }
    else
    {
        cell.scoreLabel3.backgroundColor = [UIColor blackColor];
        cell.scoreLabel3.text = @"";
    }
    
    //figure out sync indicator color
    if (currentExam.googleDriveFileID!=nil) {
        cell.syncIcon.backgroundColor = [UIColor greenColor]; //default, fully synced
        
        for (Slides* sl in currentExam.examSlides)
            for (Images* im in sl.slideImages)
                  if (im.path==nil)
                     cell.syncIcon.backgroundColor = [UIColor purpleColor]; //some images pending download
        
        //NSDate* lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSyncDate"];
        //NSDate* examModifiedDate = [TBScopeData dateFromString:currentExam.dateModified];
        //if ([examModifiedDate timeIntervalSinceDate:lastSyncDate]>0)
        if (currentExam.synced==NO)
            cell.syncIcon.backgroundColor = [UIColor yellowColor]; //has been modified locally
    }
    else {
        cell.syncIcon.backgroundColor = [UIColor clearColor]; //default, hasn't synced at all
        
        for (Slides* sl in currentExam.examSlides)
            for (Images* im in sl.slideImages)
                if (im.googleDriveFileID!=nil)
                    cell.syncIcon.backgroundColor = [UIColor redColor]; //some images pending upload
    }
    
    
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
        //determine which exam was selected
        Exams* selectedExam;
        if ([sender isKindOfClass:[ExamListTableViewCell class]])
        {
            NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
            selectedExam = [self.examListData objectAtIndex:indexPath.row];
        }
        else if ([sender isKindOfClass:[Exams class]])
            selectedExam = (Exams*)sender;
        
        ResultsTabBarController *rtbc = (ResultsTabBarController*)[segue destinationViewController];
        [rtbc.navigationItem setRightBarButtonItems:nil];
        [rtbc.navigationItem setHidesBackButton:NO];
        rtbc.currentExam = selectedExam;
    }
    else if ([segue.identifier isEqualToString:@"MapSegue"]) {
        MapViewController* mvc = (MapViewController*)[segue destinationViewController];
        mvc.showOnlyCurrentExam = NO;
        mvc.allowSelectingExams = YES;
        mvc.currentExam = nil;
        mvc.delegate = self;
        
    }
}

- (void)mapView:(MapViewController*)sender didSelectExam:(Exams *)exam
{
    [self performSegueWithIdentifier:@"ResultsSegue" sender:exam];
    
}


@end
