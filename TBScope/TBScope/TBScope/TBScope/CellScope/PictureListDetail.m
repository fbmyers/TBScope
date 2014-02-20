//
//  PictureListDetail.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "PictureListDetail.h"
//#import "UIImage+Resize.h"
#import "CaptureViewController.h"

@interface PictureListDetail ()

@end

@implementation PictureListDetail

@synthesize managedObjectContext;
@synthesize imagePicker;
@synthesize currentPicture;
@synthesize descriptionField;
@synthesize pictureField;
@synthesize titleField;

#pragma mark - Button actions

- (IBAction)editSaveButtonPressed:(id)sender {
    // If we are adding a new picture then create an entry
    if(!self.currentPicture) {
        self.currentPicture = (Pictures *)[NSEntityDescription insertNewObjectForEntityForName:@"Pictures" inManagedObjectContext:self.managedObjectContext];
    }
    
    // For both new and exisiting pictures, fill in the details from the form
    self.currentPicture.title = titleField.text;
    self.currentPicture.desc = descriptionField.text;
    
    if (pictureField.image)
    {
     //   UIImage *thumbnail = [pictureField.image thumbnailImage:80 transparentBorder:1 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
       // self.currentPicture.smallPicture = UIImagePNGRepresentation(thumbnail);
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to add new picture with error: %@", [error domain]);
        
    }
    
    // Automatically pop to previous view now that we're done adding
    [self.navigationController popViewControllerAnimated:YES];
    
}

// Pick an image from a photo album
- (IBAction)imageFromAlbum:(id)sender {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// Take an image with the camera
- (IBAction)imageFromCamera:(id)sender {
    //imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.delegate = self;
    //imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //[self presentViewController:imagePicker animated:YES completion:nil];
}

//  Resign the keyboard after Done is pressed when editing text fields
- (IBAction)resignKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Image Picker Delegate Methods

//  Dismiss the image picker on selection and use the resulting image in our ImageView
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [imagePicker dismissModalViewControllerAnimated:YES];
    [pictureField setImage:image];
}

//  On cancel, only dismiss the picker controller
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePicker dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (currentPicture)
    {
        titleField.text = currentPicture.title;
        descriptionField.text = currentPicture.desc;
        if([currentPicture smallPicture]) {
            [self.pictureField setImage:[UIImage imageWithData:currentPicture.smallPicture]];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CameraCapture"]) {
            
        CaptureViewController *cvc = (CaptureViewController*)[segue destinationViewController];
        //cvc.managedObjectContext = self.managedObjectContext;
    }
}

- (void)viewDidUnload
{
    [self setTitleField:nil];
    [self setDescriptionField:nil];
    [self setPictureField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
