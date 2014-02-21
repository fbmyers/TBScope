//
//  GoogleDriveSync.m
//  TBScope
//
//  Created by Frankie Myers on 1/28/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "GoogleDriveSync.h"

static NSString *const kKeychainItemName = @"CellScope";
static NSString *const kClientID = @"822665295778.apps.googleusercontent.com";
static NSString *const kClientSecret = @"mbDjzu2hKDW23QpNJXe_0Ukd";


@implementation GoogleDriveSync


+ (id)sharedGDS {
    static GoogleDriveSync *newGDS = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newGDS = [[self alloc] init];
    });
    return newGDS;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        // Initialize the drive service & load existing credentials from the keychain if available
        self.driveService = [[GTLServiceDrive alloc] init];
        self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                             clientID:kClientID
                                                                                         clientSecret:kClientSecret];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImage:) name:@"UploadImage" object:nil];
        
    }

    return self;
}

- (BOOL) isLoggedIn {
    return [self.driveService.authorizer canAuthorize];
}

- (NSString*) userEmail
{
    return [self.driveService.authorizer userEmail];
}

- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject
{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
    [valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
    for (NSString *relationshipName in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if ([description deleteRule]!=2) //kind of a hack
            continue;
        if (![description isToMany]) {
            NSManagedObject *relationshipObject = [managedObject valueForKey:relationshipName];
            [valuesDictionary setObject:[self dataStructureFromManagedObject:relationshipObject] forKey:relationshipName];
            continue;
        }
        NSSet *relationshipObjects = [managedObject valueForKey:relationshipName];
        NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *relationshipObject in relationshipObjects) {
            [relationshipArray addObject:[self dataStructureFromManagedObject:relationshipObject]];
        }
        [valuesDictionary setObject:relationshipArray forKey:relationshipName];
    }
    return valuesDictionary;
}

- (NSArray*)dataStructuresFromManagedObjects:(NSArray*)managedObjects
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSManagedObject *managedObject in managedObjects) {
        [dataArray addObject:[self dataStructureFromManagedObject:managedObject]];
    }
    return dataArray;
}

- (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects
{
    NSArray *objectsArray = [self dataStructuresFromManagedObjects:managedObjects];
    NSError* err;
    NSData *jsonString = [[CJSONSerializer serializer] serializeArray:objectsArray error:&err];
    
    if (err) {
        NSLog([err description]);
    }
    
    return jsonString;
}

/*
- (NSManagedObject*)managedObjectFromStructure:(NSDictionary*)structureDictionary withManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
    [managedObject setValuesForKeysWithDictionary:structureDictionary];
    
    for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
        NSRelationshipDescription *description = [relationshipsByName objectForKey:relationshipName];
        if (![description isToMany]) {
            NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
            NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
            [managedObject setObject:childObject forKey:relationshipName];
            continue;
        }
        NSMutableSet *relationshipSet = [managedObject mutableSetForKey:relationshipName];
        NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
        for (NSDictionary *childStructureDictionary in relationshipArray) {
            NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
            [relationshipSet addObject:childObject];
        }
    }
    return managedObject;
}

- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSError *error = nil;
    NSArray *structureArray = [[CJSONDeserializer deserializer] deserializeAsArray:json error:&error];
    NSAssert2(error == nil, @"Failed to deserialize\n%@\n%@", [error localizedDescription], json);
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    for (NSDictionary *structureDictionary in structureArray) {
        [objectArray addObject:[self managedObjectFromStructure:structureDictionary withManagedObjectContext:moc]];
    }
    return [objectArray autorelease];
}
*/

- (void)uploadExam;
{

    if (self.examToUpload==nil)
        return;
    
    self.waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    GTLDriveFile *file = [GTLDriveFile object];
    
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@",
                                        [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                                        self.examToUpload.examID];
    
    
    file.title = fileName; //slide.patientID;
    file.descriptionProperty = @"Uploaded from CellScope";
    file.mimeType = @"application/json";
    
    NSArray* arrayToSerialize = [NSArray arrayWithObjects:self.examToUpload,nil];
    
    //NSData* data = [[slide description] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData* data = [self jsonStructureFromManagedObjects:arrayToSerialize];
    
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    //UIAlertView *waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
                      
                      //[waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                      if (error == nil)
                      {
                          self.examToUpload.googleDriveFileID = insertedFile.identifier;
                          [[[TBScopeData sharedData] managedObjectContext] save:nil];
                          
                          NSLog(@"File ID: %@", insertedFile.identifier); //TODO: might link this back to app
                          NSDictionary* info = [[NSDictionary alloc] initWithObjectsAndKeys:@0,@"slideNumber",@0,@"imageNumber",nil];
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadImage" object:self userInfo:info];
                      }
                      else
                      {
                          NSLog(@"An error occurred: %@", error);
                          [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                          dispatch_async(dispatch_get_main_queue(),
                                         ^{
                                             [self.waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                                         });
                      }
                      
                  }];
    
}


// Uploads a photo to Google Drive
- (void)uploadImage:(NSNotification*)notification
{
    
    int slideNum = [(NSNumber*)[notification.userInfo objectForKey:@"slideNumber"] intValue];
    int imageNum = [(NSNumber*)[notification.userInfo objectForKey:@"imageNumber"] intValue];
    
    NSLog(@"uploading slide %d, image %d",slideNum,imageNum);
    

    if (slideNum>=self.examToUpload.examSlides.count) //we are done...
    {
        NSLog(@"all images uploaded");
        //TODO: mark this exam as completely uploaded
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        [self showAlert:@"Google Drive" message:@"Slide Uploaded."];
        
        return;
    }
    else if (imageNum>=((Slides*)self.examToUpload.examSlides[slideNum]).slideImages.count) //this slide is done, move to next
    {
        NSDictionary* info = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:slideNum+1],@"slideNumber",@0,@"imageNumber",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadImage" object:self userInfo:info];
        
        return;
    }
    
    //TODO: this should be separate "getImage:(Images*) completionBlock^(UIImage* returnedImage)" method used in analysis, review, and upload
    //TODO: same handler for assetlib and bundle
    Images* currentImage = (Images*)((Slides*)self.examToUpload.examSlides[slideNum]).slideImages[imageNum];
    
    
    
    NSURL *aURL = [NSURL URLWithString:currentImage.path];
    if ([[aURL scheme] isEqualToString:@"assets-library"])
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             
             if (asset==nil)
                 NSLog(@"Could not load image");
             else
             {
                 //load the image
                 ALAssetRepresentation* rep = [asset defaultRepresentation];
                 CGImageRef iref = [rep fullResolutionImage];
                 UIImage* image = [UIImage imageWithCGImage:iref];
                 
                 rep = nil;
                 iref = nil;
                 
                 
                 GTLDriveFile *file = [GTLDriveFile object];
                 
                 NSString* fileName = [NSString stringWithFormat:@"%@ - %@ - %d-%d",
                                       [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                                       self.examToUpload.examID,
                                       slideNum,
                                       imageNum];
                 
                 file.title = fileName;
                 file.descriptionProperty = @"Uploaded from CellScope";
                 file.mimeType = @"image/png";
                 
                 NSData *data = UIImagePNGRepresentation((UIImage *)image);
                 GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
                 GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                                    uploadParameters:uploadParameters];
                 
                 dispatch_async(dispatch_get_main_queue(),
                ^{
                //[self.waitIndicator setMessage:[NSString stringWithFormat:@"Uploading image %d of %d...",imageNum+1,self.slideToUpload.slideImages.count]];
                });
                 
                 [self.driveService executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLDriveFile *insertedFile, NSError *error) {
                                   if (error == nil)
                                   {
                                       NSLog(@"File ID: %@", insertedFile.identifier);
                                       NSNumber *nextImageNumber = [NSNumber numberWithInt:(imageNum+1)];
                                       NSNumber *nextSlideNumber = [NSNumber numberWithInt:(slideNum)];
                                       NSDictionary* info = [[NSDictionary alloc] initWithObjectsAndKeys:nextSlideNumber,@"slideNumber",nextImageNumber,@"imageNumber",nil];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadImage" object:self userInfo:info];
                                   }
                                   else
                                   {
                                       NSLog(@"An error occurred: %@", error);
                                       [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                                       dispatch_async(dispatch_get_main_queue(),
                                                      ^{
                                                          [self.waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                                                      });
                                   }
                               }];
                 
             }
             

             
         }
                failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"failure loading image");
         }];
    }
    else //this is a file in the bundle (only necessary for demo images)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIImage* image = [UIImage imageNamed:currentImage.path];
                           
                           //this is bad...just copy and paste...need to build a common block here
                           GTLDriveFile *file = [GTLDriveFile object];
                           
                           NSString* fileName = [NSString stringWithFormat:@"%@ - %@ - %d-%d",
                                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                                                 self.examToUpload.examID,
                                                 slideNum,
                                                 imageNum];
                           
                           file.title = fileName;
                           file.descriptionProperty = @"Uploaded from CellScope";
                           file.mimeType = @"image/png";
                           
                           NSData *data = UIImagePNGRepresentation((UIImage *)image);
                           GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
                           
                           GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                                              uploadParameters:uploadParameters];
                           
                           //[self.waitIndicator setMessage:[NSString stringWithFormat:@"Uploading image %d of %d...",imageNum+1,self.slideToUpload.slideImages.count]];
                           
                           [self.driveService executeQuery:query
                                         completionHandler:^(GTLServiceTicket *ticket,
                                                             GTLDriveFile *insertedFile, NSError *error) {

                                             if (error == nil)
                                             {
                                                 NSLog(@"File ID: %@", insertedFile.identifier);
                                                 NSNumber *nextImageNumber = [NSNumber numberWithInt:(imageNum+1)];
                                                 NSNumber *nextSlideNumber = [NSNumber numberWithInt:(slideNum)];
                                                 NSDictionary* info = [[NSDictionary alloc] initWithObjectsAndKeys:nextSlideNumber,@"slideNumber",nextImageNumber,@"imageNumber",nil];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadImage" object:self userInfo:info];
                                             }
                                             else
                                             {
                                                 NSLog(@"An error occurred: %@", error);
                                                 [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                                                 dispatch_async(dispatch_get_main_queue(),
                                                                ^{
                                                                    [self.waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                                                                });
                                             }
                                         }];
                           
                       });
        
    }
    
    

}

// Helper for showing a wait indicator in a popup
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}

@end
