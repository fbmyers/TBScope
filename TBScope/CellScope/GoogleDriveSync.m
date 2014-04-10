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

//deprecated
static BOOL previousSyncHadNoChanges = NO; //to start, we assume things are NOT in sync
static NSDate* previousSyncDate = nil;

BOOL _hasAttemptedLogUpload;

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
        self.driveService.shouldFetchNextPages = YES;
        
        self.examUploadQueue = [[NSMutableArray alloc] init];
        self.examDownloadQueue = [[NSMutableArray alloc] init];
        self.imageUploadQueue = [[NSMutableArray alloc] init];
        self.imageDownloadQueue = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImage:) name:@"UploadImage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        
        self.syncEnabled = YES;
    }

    return self;
}


- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {[TBScopeData CSLog:@"No Connection" inCategory:@"NETWORK"];}
    else if (remoteHostStatus == ReachableViaWiFi) {[TBScopeData CSLog:@"WiFi Connected" inCategory:@"NETWORK"];}
    else if (remoteHostStatus == ReachableViaWWAN) {[TBScopeData CSLog:@"Cell WWAN Connected" inCategory:@"NETWORK"];}
    
}

- (BOOL) isOkToSync
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WifiSyncOnly"])
        return ([self.reachability currentReachabilityStatus]==ReachableViaWiFi
             && [self isLoggedIn]);
    else
        return ([self.reachability currentReachabilityStatus]!=NotReachable
                && [self isLoggedIn]);
}

- (BOOL) isLoggedIn {
    return [self.driveService.authorizer canAuthorize];
}

- (NSString*) userEmail
{
    return [self.driveService.authorizer userEmail];
}

- (void)doSync
{
    [TBScopeData CSLog:@"Checking if we should sync..." inCategory:@"SYNC"];
    
    //previousSyncHadNoChanges keeps track of whether any changes are added to the upload/download queues as a result of this doSync call.
    //note that since the modified date comparison requires an asynchronous call to google drive, it's not possible to loop
    //through all exams and say at the end whether all are in sync. So this will be determined the NEXT time doSync is called
    
    //TODO: same thread sleep trick as below? do a few retries, or make it check constantly? or put doSync in the reachability notification
    _hasAttemptedLogUpload = NO;
    
    if (self.syncEnabled==NO || [self isOkToSync]==NO) {
        [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncRetryInterval"] target:self selector:@selector(doSync) userInfo:nil repeats:NO];
        [TBScopeData CSLog:@"Google Drive unreachable or sync disabled. Cannot build queue. `Will retry." inCategory:@"SYNC"];
        
        return;
    }
    
                    [TBScopeData CSLog:[NSString stringWithFormat:@"Sync initiated with Google Drive account: %@",[self userEmail]]
                        inCategory:@"SYNC"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStarted" object:nil];
                
                NSPredicate* pred; NSMutableArray* results;
                
                /////////////////////////
                //push images
                [TBScopeData CSLog:@"Fetching new images from core data." inCategory:@"SYNC"];
                
                pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID = nil) && (path != nil)"];
                results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                for (Images* im in results)
                {
                    if ([self.imageUploadQueue indexOfObject:im]==NSNotFound) //if it's not already in the queue
                    {
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Adding image #%d from slide #%d from exam %@ to upload queue",im.fieldNumber,im.slide.slideNumber,im.slide.exam.examID]
                                inCategory:@"SYNC"];
                        
                        //NSLog(@"adding image #%d from slide #%d from exam %@ to upload queue",im.fieldNumber,im.slide.slideNumber,im.slide.exam.examID);
                        [self.imageUploadQueue addObject:im];
                        //previousSyncHadNoChanges = NO;
                    }
                }
                
                /////////////////////////
                //push exams
                [TBScopeData CSLog:@"Fetching new/modified exams from core data." inCategory:@"SYNC"];
                
                //TODO: it probably makes more sense to just store a "hasUpdates" flag in CD. this gets set whenever exam changes, reset when its uploaded. then can do away w/ previousSyncHadNoChanges
                pred = [NSPredicate predicateWithFormat:@"(synced == NO) || (googleDriveFileID = nil)"];
                results = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                for (Exams* ex in results)
                {
                    if ([self.examUploadQueue indexOfObject:ex]==NSNotFound) //if it's not already in the queue
                    {
                        if (ex.googleDriveFileID==nil)
                        {
                            [TBScopeData CSLog:[NSString stringWithFormat:@"Adding new exam %@ to upload queue. local timestamp: %@",ex.examID,ex.dateModified]
                             inCategory:@"SYNC"];
                            
                            [self.examUploadQueue addObject:ex];
                            //previousSyncHadNoChanges = NO;
                        }
                        else //exam exists on both client and server, so check dates
                        {
                            //get modified date on server
                            GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:ex.googleDriveFileID];
                            [self executeQueryWithTimeout:query
                                          completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *file, NSError *error) {
                                              if (error==nil) {
                                                  if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]>0)
                                                  {
                                                      
                                                      [TBScopeData CSLog:[NSString stringWithFormat:@"Adding modified exam %@ to upload queue. server timestamp: %@, local timestamp: %@",ex.examID,[TBScopeData stringFromDate:file.modifiedDate.date],ex.dateModified]
                                                              inCategory:@"SYNC"];
                                                      
                                                      [self.examUploadQueue addObject:ex];
                                                      previousSyncHadNoChanges = NO;
                                                  }
                                              }
                                              else if (error.code==404) //the file referenced by this exam isn't present on server, so remove this google drive ID
                                              {
                                                  [TBScopeData CSLog:@"Requested JSON file doesn't exist in Google Drive (error 404), so removing this reference."
                                                          inCategory:@"SYNC"];
                     
                                                  ex.googleDriveFileID = nil;
                                                  [[TBScopeData sharedData] saveCoreData];
                                              }
                                              else {
                                                  [TBScopeData CSLog:[NSString stringWithFormat:@"An error occured while querying Google Drive: %@",error.description]
                                                          inCategory:@"SYNC"];
                                                  NSLog(@"an error occured: %@",[error description]);
                                                  //previousSyncHadNoChanges = NO;
                                              }
                                              
                                              
                                          }
                                             errorHandler:^(NSError* error){
                                                 NSLog(@"Query couldn't be executed.");
                                             }];

                        }
                    } //next exam
                }
                
                /////////////////////////
                //pull exams
                //get all exams on server
                [TBScopeData CSLog:@"Fetching new/modified exams from Google Drive." inCategory:@"SYNC"];
                
                GTLQueryDrive *query = [GTLQueryDrive queryForFilesList]; //THIS QUERY IS NOT DOWNLOADING FILES THAT WEREN'T UPLOADED FROM APP...WHY!!???
                
                //the problem with fetching only GD records since this ipad's last sync date is if they were modified before this date but uploaded after, this would not pick them up
                //simplest solution is to just check ALL the JSON objects in GD, but that will cause more network chatter. not sure a straightforward workaround.
                
                //if (ONLY_CHECK_RECORDS_SINCE_LAST_FULL_SYNC)
                //    query.q = [NSString stringWithFormat:@"modifiedDate > '%@' and mimeType='application/json'",[GTLDateTime dateTimeWithDate:lastFullSync timeZone:[NSTimeZone systemTimeZone]].RFC3339String];
                //else
                    query.q = @"mimeType='application/json'";

                query.includeDeleted = false;
                query.includeSubscribed = true;
                
                [self executeQueryWithTimeout:query
                              completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files,
                                                  NSError *error) {
                                  if (error == nil) {
                                      [TBScopeData CSLog:[NSString stringWithFormat:@"Fetched %ld exam JSON files from Google Drive.",(long)files.items.count]
                                              inCategory:@"SYNC"];
                                      for (GTLDriveFile* file in files)
                                      {
                                          if ([self.examDownloadQueue indexOfObject:file]==NSNotFound) //not already in the queue
                                          {
                                              //check if there is a corresponding record in CD for this googleFileID
                                              NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)", file.identifier];
                                              NSArray* result = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                                              if (result.count==0)
                                              {
                                                  
                                                  [TBScopeData CSLog:[NSString stringWithFormat:@"Adding new exam %@ to download queue. server timestamp: %@",file.title,file.modifiedDate.date]
                                                          inCategory:@"SYNC"];
                                                  [self.examDownloadQueue addObject:file];
                                                  //previousSyncHadNoChanges = NO;
                                              }
                                              else
                                              {
                                                  Exams* ex = (Exams*)result[0];
                                                  if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]<0) {
                                                      
                                                      [TBScopeData CSLog:[NSString stringWithFormat:@"Adding modified exam %@ to download queue. server timestamp: %@, local timestamp: %@",file.title,[TBScopeData stringFromDate:file.modifiedDate.date],ex.dateModified]
                                                              inCategory:@"SYNC"];
                                                      
                                                      [self.examDownloadQueue addObject:file];
                                                      //previousSyncHadNoChanges = NO;
                                                  }
                                              }
                                          }
                                      }
                                  } else {
                                      NSLog(@"An error occurred: %@", [error description]);
                                      //previousSyncHadNoChanges = NO;
                                  }
                              }
                                 errorHandler:^(NSError* error) {
                                     NSLog(@"Query couldn't be executed");
                                 }];
                
                /////////////////////////
                //pull images
                //search CD for images with empty path
                [TBScopeData CSLog:@"Fetching new images from Google Drive." inCategory:@"SYNC"];
                
                pred = [NSPredicate predicateWithFormat:@"(path = nil) && (googleDriveFileID != nil)"];
                results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                for (Images* im in results)
                {
                    if ([self.imageDownloadQueue indexOfObject:im]==NSNotFound)
                    {
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Adding image #%d from slide #%d from exam %@ to download queue",im.fieldNumber,im.slide.slideNumber,im.slide.exam.examID]
                                inCategory:@"SYNC"];
                        
                        [self.imageDownloadQueue addObject:im];
                        //previousSyncHadNoChanges = NO;
                    }
                }
                
                
    
    
    //start processing queues. this will start 5s later because we want to make sure the server has a chance to respond to the requests made above (and all the queues become populated)
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(processTransferQueues) userInfo:nil repeats:NO];
    
}

//uploads/downloads the next item in the upload queue
- (void)processTransferQueues
{
    void (^completionBlock)() = ^{
        //remove previous item from queue
        if (self.imageUploadQueue.count>0)
            [self.imageUploadQueue removeObjectAtIndex:0];
        else if (self.examUploadQueue.count>0)
            [self.examUploadQueue removeObjectAtIndex:0];
        else if (self.examDownloadQueue.count>0)
            [self.examDownloadQueue removeObjectAtIndex:0];
        else if (self.imageDownloadQueue.count>0)
            [self.imageDownloadQueue removeObjectAtIndex:0];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncUpdate" object:nil];
        
        //if (self.syncEnabled) //check syncEnabled again (in case user has transitioned into editing an exam)
        [self processTransferQueues];
    };
    
    //TODO: maybe refactor this to be a single completion block w/ error returned as parameter
    void (^errorBlock)(NSError*) = ^(NSError* error){
        NSLog(@"error occured while processing queue (network error?)");
        NSLog(@"%@",[error description]);
        //previousSyncHadNoChanges = NO;
        completionBlock();
    };
    
    //if network unreachable or sync disabled, call this function again later (it will pick up where it left off)
    //this is ideal for short-term network drops, since it means we don't have to go through the whole doSync process again
    //when it reconnects
    if (self.syncEnabled==NO || [self isOkToSync]==NO) {
            [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncRetryInterval"] target:self selector:@selector(processTransferQueues) userInfo:nil repeats:NO];
        [TBScopeData CSLog:@"Google Drive unreachable or sync disabled while processing queue. Will retry." inCategory:@"SYNC"];
        
        return;
    }
    
    
    NSLog(@"Checking for network connection");
    //maybe check for syncEnabled && isSyncOk and infinite loop if not (with thread sleep of ~1 min)
    
    NSLog(@"Processing next item in sync queue...");
    if (self.imageUploadQueue.count>0 && self.syncEnabled) {
        [self uploadImage:(Images*)self.imageUploadQueue[0]
        completionHandler:completionBlock
             errorHandler:errorBlock];
    }
    else if (self.examUploadQueue.count>0 && self.syncEnabled) {
        [self uploadExam:(Exams*)self.examUploadQueue[0]
       completionHandler:completionBlock
            errorHandler:errorBlock];
    }
    else if (self.examDownloadQueue.count>0 && self.syncEnabled) {
        [self downloadExam:(GTLDriveFile*)self.examDownloadQueue[0]
         completionHandler:completionBlock
              errorHandler:errorBlock];
    }
    else if (self.imageDownloadQueue.count>0 && self.syncEnabled) {
        [self downloadImage:(Images*)self.imageDownloadQueue[0]
          completionHandler:completionBlock
               errorHandler:errorBlock];
    }
    else if (_hasAttemptedLogUpload==NO && self.syncEnabled)
    {
        [self uploadLogWithCompletionHandler:completionBlock errorHandler:errorBlock];
        _hasAttemptedLogUpload = YES;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStopped" object:nil];
        NSLog(@"upload/download queues empty or sync disabled");
        
        //if (previousSyncHadNoChanges) {
            
            //schedule the next sync iteration some time in the future (note: might want to make this some kind of service which runs based on OS notifications)
            [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncInterval"] target:self selector:@selector(doSync) userInfo:nil repeats:NO];
        //}
        //else //previous iteration resulted in changes, so run another sync to make sure there are no remaining updates
        //{
            //immediately run another sync operation (don't call directly b/c could lead to excessive stack growth)
            //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doSync) userInfo:nil repeats:NO];
        //}
    }
    

}

// Uploads a photo to Google Drive and sets the local googleFileID to the fileID provided by google
- (void)uploadImage:(Images*)image completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    if (image.googleDriveFileID==nil) {
        NSLog(@"UPLOADING IMAGE #%d FROM SLIDE #%d FROM EXAM %@",image.fieldNumber,image.slide.slideNumber,image.slide.exam.examID);

        //load the image
        [TBScopeData getImage:image resultBlock:^(UIImage* im, NSError* error)
         {
             if (error==nil)
             {
                 //create a google file object from this image
                 GTLDriveFile *file = [GTLDriveFile object];
                 file.title = [NSString stringWithFormat:@"%@ - %@ - %d-%d.png",
                               image.slide.exam.cellscopeID,
                               image.slide.exam.examID,
                               image.slide.slideNumber,
                               image.fieldNumber];
                 file.descriptionProperty = @"Uploaded from CellScope";
                 file.mimeType = @"image/png";
                 file.modifiedDate = [GTLDateTime dateTimeWithRFC3339String:image.slide.exam.dateModified];
                 NSData *data = UIImagePNGRepresentation((UIImage *)im);
                 GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data
                                                                                              MIMEType:file.mimeType];
                 GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                                    uploadParameters:uploadParameters];
                 query.setModifiedDate = YES;
                 
                 //execute upload query
                 //MAJOR PROBLEM: all my executeQuery calls depend on the completionHandler getting called, so completionBlock() can get called and queue can continue. But google doesn't call this if the operation doesn't complete (network unavailable). So...could create my own timeout thing.
                 [self executeQueryWithTimeout:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLDriveFile *insertedFile, NSError *error) {
                                   
                       if (error == nil)
                       {
                           //save this fileID to CD, but don't change modified date of exam
                           image.googleDriveFileID = insertedFile.identifier;
                           [[TBScopeData sharedData] saveCoreData];
                           
                           NSLog(@"Uploaded image file name: %@, ID: %@", insertedFile.title, insertedFile.identifier);

                           completionBlock();
                       }
                       else
                           errorBlock(error); //likely over google drive quota or network error
                   }
                                  errorHandler:^(NSError* error){
                                      errorBlock(error);
                                  }];
                 
                 
                 
             }
             else
                 errorBlock(error); //likely local file not found
        }];
    }
    else
    {
        NSLog(@"this image has already been uploaded");
        completionBlock();
    }
    
}

//upload an exam (either new or modified) to google drive
- (void)uploadExam:(Exams*)exam completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    NSLog(@"UPLOADING EXAM: %@",exam.examID);

    //first check to make sure this exam has had all images uploaded (and therefore has google file IDs associated with each)
    BOOL allImagesUploaded = YES;
    for (Slides* sl in exam.examSlides)
        for (Images* im in sl.slideImages)
            if (im.googleDriveFileID==nil)
                allImagesUploaded = NO;
    if (allImagesUploaded)
    {
        //create a google file object from this exam
        GTLDriveFile* file = [GTLDriveFile object];
        file.title = [NSString stringWithFormat:@"%@ - %@.json",
                      exam.cellscopeID,
                      exam.examID];
        file.descriptionProperty = @"Uploaded from CellScope";
        file.mimeType = @"application/json";
        file.modifiedDate = [GTLDateTime dateTimeWithRFC3339String:exam.dateModified];
        NSArray* arrayToSerialize = [NSArray arrayWithObjects:exam,nil];
        NSData* data = [CoreDataJSONHelper jsonStructureFromManagedObjects:arrayToSerialize];
        
        //create query
        GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
        GTLQueryDrive* query;
        if (exam.googleDriveFileID==nil) {
            NSLog(@"this is a new file in GD...");
            query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                uploadParameters:uploadParameters];
        }
        else { //this file exists in google, so we are updating
            NSLog(@"file exists in GD, updating with new data...");
            query = [GTLQueryDrive queryForFilesUpdateWithObject:file
                                                          fileId:exam.googleDriveFileID
                                                uploadParameters:uploadParameters];
        }
        query.setModifiedDate = YES;

        //execute query
        [self executeQueryWithTimeout:query
                      completionHandler:^(GTLServiceTicket *ticket,
                                          GTLDriveFile *insertedFile, NSError *error) {

                          if (error == nil)
                          {
                              //save this fileID to CD, but don't change modified date of exam
                              exam.googleDriveFileID = insertedFile.identifier;
                              exam.synced = YES;
                              [[TBScopeData sharedData] saveCoreData];
                              
                              NSLog(@"Uploaded exam file name: %@, ID: %@", insertedFile.title, insertedFile.identifier);
                              
                              completionBlock();
                          }
                          else
                              errorBlock(error);
                          
                      }
                         errorHandler:^(NSError* error){
                             errorBlock(error);
                         }];
        
    }
    else
    {
        NSLog(@"exam does not yet have all images uploaded, so it will be skipped for now");
        completionBlock();
    }

}

//download exam (new or modified)
- (void)downloadExam:(GTLDriveFile*)file completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    NSLog(@"DOWNLOADING EXAM FROM JSON FILE: %@, ID: %@",file.title,file.identifier);
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
    
    // For downloads requiring authorization, set the authorizer.
    fetcher.authorizer = self.driveService.authorizer;
    //TODO: check what happens w/o network
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSError* error2;
            NSArray* result = [CoreDataJSONHelper managedObjectsFromJSONStructure:data withManagedObjectContext:[[TBScopeData sharedData] managedObjectContext] error:&error2];
            if (error2 == nil && result.count>0)
            {
                Exams* downloadedExam = (Exams*)result[0];
                
                downloadedExam.dateModified = file.modifiedDate.RFC3339String; //this is necessary to avoid cases where the updating app doesn't
                downloadedExam.googleDriveFileID = file.identifier;
                downloadedExam.synced = YES;
                
                //for each image in this exam, check to see if there is already a matching image on this iPad (via google ID)
                //if so, copy the path over to new downloaded exam
                //if not, set path to null (this will trigger the image download)
                for (Slides* sl in downloadedExam.examSlides)
                {
                    for (Images* im in sl.slideImages)
                    {
                        im.path = nil;

                        //check if there was a matching image already in the db and copy the local file path to the new one
                        NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)",im.googleDriveFileID];
                        result = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                        for (Images* localMatchingImage in result)
                        {
                            if (im!=localMatchingImage) //in other words, this was a pre-existing image, not the one that was just downloaded
                                im.path = localMatchingImage.path;
                        }

                    }
                }
                
                //check if this googleFileID exists in the CD exam database.
                NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)",downloadedExam.googleDriveFileID];
                result = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                for (Exams* localExam in result)
                {
                    //delete old copy
                    if (downloadedExam!=localExam)
                        [[[TBScopeData sharedData] managedObjectContext] deleteObject:localExam];
                }

                //save
                [[TBScopeData sharedData] saveCoreData];
                
                NSLog(@"Downloaded exam ID: %@ from file ID: %@", downloadedExam.examID, file.identifier);
                completionBlock();
            }
            else
            {
                NSLog(@"error parsing JSON file");
                errorBlock(error2);
            }
            
        } else
            errorBlock(error);
    }];
}

- (void)downloadImage:(Images*)image completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    //double check to make sure it hasn't already been downloaded
    if (image.path==nil)
    {
        NSLog(@"DOWNLOADING IMAGE #%d FROM SLIDE #%d FROM EXAM %@ FROM GOOGLE FILE ID %@",image.fieldNumber,image.slide.slideNumber,image.slide.exam.examID,image.googleDriveFileID);
        
        //get the image file metadata
        GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:image.googleDriveFileID];
        [self executeQueryWithTimeout:query
                      completionHandler:^(GTLServiceTicket *ticket,
                                          GTLDriveFile *file, NSError *error) {
                          if (error==nil) {
                              GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
                              fetcher.authorizer = self.driveService.authorizer;
                              //TODO: verify w/o network connection
                              [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                                  if (error==nil)
                                  {
                                      //save this image to asset library as jpg
                                      UIImage* im = [UIImage imageWithData:data];
                                      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                      [library writeImageToSavedPhotosAlbum:im.CGImage
                                                                orientation:(ALAssetOrientation)[im imageOrientation]
                                                            completionBlock:^(NSURL *assetURL, NSError *error){
                                          if (error==nil) {
                                              image.path = assetURL.absoluteString;
                                              [[TBScopeData sharedData] saveCoreData];
                                              
                                              NSLog(@"Downloaded image to path: %@", image.path);
                                              completionBlock();
                                          }
                                          else
                                              errorBlock(error); //likely disk is full
                                       }];
                                  }
                                  else
                                      errorBlock(error); //likely data transfer interrupted
                              }];
                          }
                          else if (error.code == 404) //file not found error
                          {
                              NSLog(@"referenced file does not exist in google drive (it was deleted on server?). fileID will be set to nil on client.");
                              image.googleDriveFileID = nil;
                              [[TBScopeData sharedData] saveCoreData];
                              completionBlock();
                          }
                          else
                              errorBlock(error); //likely data transfer interrupted
                      }
                         errorHandler:^(NSError* error){
                             errorBlock(error); //likely network connection not present
                         }];
    }
    else
    {
        NSLog(@"this image has already been downloaded");
        completionBlock();
    }
    
}

//uploads any recent log entries to a new text file
- (void) uploadLogWithCompletionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"(synced == NO)"];
    NSArray* results = [CoreDataHelper searchObjectsForEntity:@"Logs" withPredicate:pred andSortKey:@"date" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
    if (results.count>0)
    {
        NSLog(@"UPLOADING LOG FILE");
        
        //build text file
        NSMutableString* outString = [[NSMutableString alloc] init];
        
        for (Logs* logEntry in results)
        {
            [outString appendFormat:@"%@\t%@\t%@\n",logEntry.date,logEntry.category,logEntry.entry];
        }
        
        //create a google file object from this image
        GTLDriveFile *file = [GTLDriveFile object];
        file.title = [NSString stringWithFormat:@"%@ - %@.log",
                      [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                      [TBScopeData stringFromDate:[NSDate date]]];
        file.descriptionProperty = @"Uploaded from CellScope";
        file.mimeType = @"text/plain";
        NSData *data = [outString dataUsingEncoding:NSUTF8StringEncoding];
        GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data
                                                                                     MIMEType:file.mimeType];
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                           uploadParameters:uploadParameters];
        
        
        [self executeQueryWithTimeout:query
                    completionHandler:^(GTLServiceTicket *ticket,
                                          GTLDriveFile *insertedFile, NSError *error) {
                          
                          if (error == nil)
                          {
                              //set all log entries to synced
                              for (Logs* logEntry in results) {
                                  logEntry.synced = YES;
                              }
                              [[TBScopeData sharedData] saveCoreData];
                              
                              completionBlock();
                          }
                          else
                          {
                              NSLog(@"error uploading log file");
                              errorBlock(error);
                          }
                      }
                         errorHandler:^(NSError* error){
                             errorBlock(error);
                         }];

    }
    else
    {
        completionBlock();
    }
    
}

- (void) executeQueryWithTimeout:(GTLQuery*)query
             completionHandler:(id)completionBlock
                    errorHandler:(void(^)(NSError*))errorBlock
{
    GTLServiceTicket* ticket = [self.driveService executeQuery:query
                                            completionHandler:completionBlock];
    
    //since google drive API doesn't call completion or error handler when network connection drops (arg!),
    //set this timer to check the query ticket and make sure it returned something. if not, cancel the query
    //and return an error
    //TODO: roll this into my own executeQuery function and make it universal
    //TODO: check what happens if we are uploading a big file (hopefully returns a diff status code)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(GOOGLE_DRIVE_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"status code: %ld",(long)ticket.statusCode);
        if (ticket.statusCode==0) { //might also handle other error codes? code of 0 means that it didn't even attempt I guess? the other HTTP codes should get handled in the errorhandler above
            [ticket cancelTicket];
            NSError* error = [NSError errorWithDomain:@"GoogleDriveSync" code:123 userInfo:[NSDictionary dictionaryWithObject:@"No response from query. Likely network failure." forKey:@"description"]];
            errorBlock(error);
        }
    });
}

@end
