//
//  PictureListDetail.h
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Pictures.h"

@interface PictureListDetail : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Pictures *currentPicture;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UIImageView *pictureField;

@property (strong, nonatomic) UIImagePickerController* imagePicker;

- (IBAction)editSaveButtonPressed:(id)sender;
- (IBAction)imageFromAlbum:(id)sender;
- (IBAction)imageFromCamera:(id)sender;


@end
