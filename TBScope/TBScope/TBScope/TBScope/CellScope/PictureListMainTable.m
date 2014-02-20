//
//  PictureListMainTable.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "PictureListMainTable.h"
//#import "PhotoViewController.h"
#import "CoreDataHelper.h"
#import "Pictures.h"
#import "CaptureViewController.h"
#import "AnalysisViewController.h"

@interface PictureListMainTable ()

@end

@implementation PictureListMainTable

@synthesize managedObjectContext;
@synthesize pictureListData;

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
    // Repopulate the array with new table data
    [self readDataForTable];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)readDataForTable
{    
    //  Grab the data
    self.pictureListData = [CoreDataHelper getObjectsForEntity:@"Pictures" withSortKey:@"title" andSortAscending:YES andContext:managedObjectContext];
    
    //  Force table refresh
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CapturePicture"]) {
        // Get a reference to the capture view
        CaptureViewController *cvc = (CaptureViewController*)[segue destinationViewController];
        //cvc.userContext = self.userContext;
        //cvc.managedObjectContext = self.managedObjectContext;
    }
    
    if([segue.identifier isEqualToString:@"AnalyzePicture"]) {
        NSLog(@"Hello world");

        
        // Get the row we selected in the table view
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];

        Pictures* pic = (Pictures*)[self.pictureListData objectAtIndex:selectedIndex];
        
        //this is the URL of an actual TB slide (downloaded from Neil's scope)
        //it will be piped in to the algorithm when the 1st image in the list is selected
        if (selectedIndex==0)
        {
            [pic setPath:@"assets-library://asset/asset.TIF?id=9056B581-0AD1-43A3-B7F5-20DCE03F0A27&ext=TIF"];
        }
        
        NSLog(@"path = %@", pic.path);
        
        AnalysisViewController *avc = (AnalysisViewController*)[segue destinationViewController];
        //avc.userContext = self.userContext;
        //avc.managedObjectContext = self.managedObjectContext;
        //avc.picture = pic;
        
        /* TODO: implement PVC, allow user to zoom/pan on image
        // Get a reference to our detail view
        PhotoViewController *pvc = (PhotoViewController*)[segue destinationViewController];
        
        // Pass the managed object context to the destination view controller
        pvc.managedObjectContext = self.managedObjectContext;
        
        //TODO: load this image into photoviewcontroller, with metadata, etc.
        //TODO: move the analysis option to PVC, rather than right here
         */
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pictureListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the core data object we need to use to populate this table cell
    Pictures *currentCell = [pictureListData objectAtIndex:indexPath.row];
    
    // Fill in the cell contents
    cell.detailTextLabel.text = currentCell.desc;
                           
    // Format the current date
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    cell.textLabel.text = dateString;
    
    // If a picture exists, then use it
    if([currentCell smallPicture]) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = [UIImage imageWithData:[currentCell smallPicture]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Swipe to delete has been used. Remove the table item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get a reference to the table item in our data array
        Pictures *itemToDelete = [self.pictureListData objectAtIndex:indexPath.row];
        
        // Delete the item in Core Data
        [self.managedObjectContext deleteObject:itemToDelete];
        
        // Remove the item from our array
        [pictureListData removeObjectAtIndex:indexPath.row];
        
        // Commit the deletion in Core Data
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to delete picture item with error: %@", [error domain]);
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
