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
        self.isSyncing = NO;
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

- (void)doSync {
    [TBScopeData CSLog:@"Checking if we should sync..." inCategory:@"SYNC"];

    _hasAttemptedLogUpload = NO;

    // if google unreachable or sync disabled, abort this operation and call
    // again some time later
    if (self.syncEnabled==NO || [self isOkToSync]==NO) {
        [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncRetryInterval"]
                                         target:self
                                       selector:@selector(doSync)
                                       userInfo:nil
                                        repeats:NO];
        [TBScopeData CSLog:@"Google Drive unreachable or sync disabled. Cannot build queue. Will retry."
                inCategory:@"SYNC"];
        return;
    }

    [TBScopeData CSLog:[NSString stringWithFormat:@"Sync initiated with Google Drive account: %@",[self userEmail]]
            inCategory:@"SYNC"];
    self.isSyncing = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStarted" object:nil];

    // Sync in a background thread so we don't block the UI
    NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tmpMOC.parentContext = [[TBScopeData sharedData] managedObjectContext];
    [tmpMOC performBlock:^{
        NSPredicate* pred;
        NSMutableArray* results;

        /////////////////////////
        //push images
        [TBScopeData CSLog:@"Fetching new images from core data." inCategory:@"SYNC"];
        pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID = nil) && (path != nil)"];
        results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:tmpMOC];
        int imageUploadsEnqueued = 0;
        for (Images* im in results) {
            if ([self.imageUploadQueue indexOfObject:im]==NSNotFound) {  //if it's not already in the queue
                NSLog(@"Adding image #%d from slide #%d from exam %@ to upload queue", im.fieldNumber, im.slide.slideNumber, im.slide.exam.examID);
                [self.imageUploadQueue addObject:im];
                imageUploadsEnqueued++;
                //previousSyncHadNoChanges = NO;
            }
        }
        [TBScopeData CSLog:[NSString stringWithFormat:@"Added %d images to upload queue.", imageUploadsEnqueued] inCategory:@"SYNC"];

        /////////////////////////
        // push exams
        [TBScopeData CSLog:@"Fetching new/modified exams from core data." inCategory:@"SYNC"];
        //TODO: it probably makes more sense to just store a "hasUpdates" flag in CD. this gets set whenever exam changes, reset when its uploaded. then can do away w/ previousSyncHadNoChanges
        pred = [NSPredicate predicateWithFormat:@"(synced == NO) || (googleDriveFileID = nil)"];
        results = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:tmpMOC];
        int examUploadsEnqueued = 0;
        for (Exams* ex in results) {
            if ([self.examUploadQueue indexOfObject:ex]==NSNotFound) {  //if it's not already in the queue
                if (ex.googleDriveFileID==nil) {
                    NSLog(@"Adding new exam %@ to upload queue. local timestamp: %@", ex.examID, ex.dateModified);
                    [self.examUploadQueue addObject:ex];
                    examUploadsEnqueued++;
                    // previousSyncHadNoChanges = NO;
                } else {  // exam exists on both client and server, so check dates
                    // Google Drive queries must be run on the main thread
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        // get modified date on server
                        GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:ex.googleDriveFileID];
                        [self executeQueryWithTimeout:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
                            if (error==nil) {
                                if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]>0) {
                                    NSLog(@"Adding modified exam %@ to upload queue. server timestamp: %@, local timestamp: %@", ex.examID, [TBScopeData stringFromDate:file.modifiedDate.date], ex.dateModified);
                                    [self.examUploadQueue addObject:ex];
                                    previousSyncHadNoChanges = NO;
                                }
                            } else if (error.code==404) {  // the file referenced by this exam isn't present on server, so remove this google drive ID
                                [TBScopeData CSLog:@"Requested JSON file doesn't exist in Google Drive (error 404), so removing this reference."
                                        inCategory:@"SYNC"];

                                [tmpMOC performBlock:^{
                                    // remove all google drive references
                                    ex.googleDriveFileID = nil;
                                    for (Slides* sl in ex.examSlides)
                                        for (Images* im in sl.slideImages)
                                            im.googleDriveFileID = nil;

                                    // Save exam/images
                                    NSError *tmpMOCSaveError;
                                    if (![tmpMOC save:&tmpMOCSaveError]) {
                                        NSLog(@"Error saving temporary managed object context.");
                                    }
                                    [[TBScopeData sharedData] saveCoreData];
                                }];
                            } else {
                                [TBScopeData CSLog:[NSString stringWithFormat:@"An error occured while querying Google Drive: %@",error.description]
                                        inCategory:@"SYNC"];
                                // previousSyncHadNoChanges = NO;
                            }
                        }
                        errorHandler:^(NSError* error){
                            [TBScopeData CSLog:@"Query couldn't be executed." inCategory:@"SYNC"];
                        }
                    ];
                    });
                }
            } //next exam
        }
        [TBScopeData CSLog:[NSString stringWithFormat:@"Added %d new exams to upload queue.", examUploadsEnqueued] inCategory:@"SYNC"];

        /////////////////////////
        // pull exams
        // get all exams on server
        // Google Drive queries must be run on the main thread
        dispatch_async(dispatch_get_main_queue(), ^(void) {
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
            [self executeQueryWithTimeout:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
                if (error == nil) {
                    [TBScopeData CSLog:[NSString stringWithFormat:@"Fetched %ld exam JSON files from Google Drive.",(long)files.items.count]
                            inCategory:@"SYNC"];

                    [tmpMOC performBlock:^{
                        int examDownloadsEnqueued = 0;
                        for (GTLDriveFile* file in files) {
                            if ([self.examDownloadQueue indexOfObject:file]==NSNotFound) {  //not already in the queue
                                // check if there is a corresponding record in CD for this googleFileID
                                NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)", file.identifier];
                                NSArray* result = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:tmpMOC];
                                if (result.count==0) {
                                    NSLog(@"Adding new exam %@ to download queue. server timestamp: %@", file.title, file.modifiedDate.date);
                                    [self.examDownloadQueue addObject:file];
                                    examDownloadsEnqueued++;
                                    // previousSyncHadNoChanges = NO;
                                } else {
                                    Exams* ex = (Exams*)result[0];
                                    if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]<0) {
                                        NSLog(@"Adding modified exam %@ to download queue. server timestamp: %@, local timestamp: %@", file.title, [TBScopeData stringFromDate:file.modifiedDate.date], ex.dateModified);
                                        [self.examDownloadQueue addObject:file];
                                        examDownloadsEnqueued++;
                                        // previousSyncHadNoChanges = NO;
                                    }
                                }
                            }
                        }
                        [TBScopeData CSLog:[NSString stringWithFormat:@"Added %d exams to download queue.", examDownloadsEnqueued] inCategory:@"SYNC"];
                    }];
                } else {
                    [TBScopeData CSLog:[NSString stringWithFormat:@"An error occured while querying Google Drive: %@", error.description] inCategory:@"SYNC"];
                    // previousSyncHadNoChanges = NO;
                }
            }
            errorHandler:^(NSError* error) {
                [TBScopeData CSLog:@"Query couldn't be executed" inCategory:@"SYNC"];
            }
        ];
        });

        /////////////////////////
        // pull images
        // search CD for images with empty path
        [TBScopeData CSLog:@"Fetching new images from Google Drive." inCategory:@"SYNC"];
        pred = [NSPredicate predicateWithFormat:@"(path = nil) && (googleDriveFileID != nil)"];
        results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:tmpMOC];
        int imageDownloadsEnqueued = 0;
        for (Images* im in results) {
            if ([self.imageDownloadQueue indexOfObject:im]==NSNotFound) {
                NSLog(@"Adding image #%d from slide #%d from exam %@ to download queue", im.fieldNumber, im.slide.slideNumber, im.slide.exam.examID);

                [self.imageDownloadQueue addObject:im];
                imageDownloadsEnqueued++;
                // previousSyncHadNoChanges = NO;
            }
            [tmpMOC refreshObject:im mergeChanges:NO];
        }
        [TBScopeData CSLog:[NSString stringWithFormat:@"Added %d images to download queue", imageDownloadsEnqueued] inCategory:@"SYNC"];

        // Start processing queues. We wait to dispatch this for 5s because we want
        // to make sure the server has a chance to respond to the requests made
        // above (and all the queues become populated)
        [self processTransferQueues];
    }];
}

//uploads/downloads the next item in the upload queue
- (void)processTransferQueues
{
    
    void (^completionBlock)(NSError*) = ^(NSError* error){
        
        //log the error, but continue on with queue
        if (error!=nil) {
            [TBScopeData CSLog:[NSString stringWithFormat:@"Error while processing queue: %@",error.description] inCategory:@"SYNC"];
        }
        
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

        //call process queue again to execute the next item in queue
        [self processTransferQueues];
    };
    
    static BOOL isPaused = NO;
    
    //if network unreachable or sync disabled, call this function again later (it will pick up where it left off)
    //this is ideal for short-term network drops, since it means we don't have to go through the whole doSync process again
    //when it reconnects
    if (self.syncEnabled==NO || [self isOkToSync]==NO) {
            [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncRetryInterval"] target:self selector:@selector(processTransferQueues) userInfo:nil repeats:NO];
        [TBScopeData CSLog:@"Google Drive unreachable or sync disabled while processing queue. Will retry." inCategory:@"SYNC"];
        isPaused = YES;
        self.isSyncing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStopped" object:nil];

        return;
    }
    else
    {
        if (isPaused) {
            self.isSyncing = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStarted" object:nil];

        }
        isPaused = NO;
    }
    

    
    [TBScopeData CSLog:@"Processing next item in sync queue..." inCategory:@"SYNC"];
    if (self.imageUploadQueue.count>0 && self.syncEnabled) {
        [self uploadImage:(Images*)self.imageUploadQueue[0]
        completionHandler:completionBlock];
    }
    else if (self.examUploadQueue.count>0 && self.syncEnabled) {
        [self uploadExam:(Exams*)self.examUploadQueue[0]
       completionHandler:completionBlock];
    }
    else if (self.examDownloadQueue.count>0 && self.syncEnabled) {
        [self downloadExam:(GTLDriveFile*)self.examDownloadQueue[0]
         completionHandler:completionBlock];
    }
    else if (self.imageDownloadQueue.count>0 && self.syncEnabled) {
        [self downloadImage:(Images*)self.imageDownloadQueue[0]
          completionHandler:completionBlock];
    }
    else if (_hasAttemptedLogUpload==NO && self.syncEnabled)
    {
        _hasAttemptedLogUpload = YES;
        [self uploadLogWithCompletionHandler:completionBlock];
    }
    else {
        self.isSyncing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStopped" object:nil];
        [TBScopeData CSLog:@"upload/download queues empty or sync disabled" inCategory:@"SYNC"];
        
        //if (previousSyncHadNoChanges) {
            
            //schedule the next sync iteration some time in the future (note: might want to make this some kind of service which runs based on OS notifications)
            [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncInterval"]*60 target:self selector:@selector(doSync) userInfo:nil repeats:NO];
        //}
        //else //previous iteration resulted in changes, so run another sync to make sure there are no remaining updates
        //{
            //immediately run another sync operation (don't call directly b/c could lead to excessive stack growth)
            //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doSync) userInfo:nil repeats:NO];
        //}
    }
    

}

// Uploads a photo to Google Drive and sets the local googleFileID to the fileID provided by google
- (void)uploadImage:(Images*)image completionHandler:(void(^)(NSError*))completionBlock
{
    NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tmpMOC.parentContext = [[TBScopeData sharedData] managedObjectContext];

    // Create a temporary copy of image belonging to this NSManagedObjectContext
    NSError *tmpImageError;
    Images *tmpImage = [tmpMOC existingObjectWithID:[image objectID] error:&tmpImageError];

    if (tmpImage.googleDriveFileID==nil) {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Uploading image %d-%d for exam %@", tmpImage.slide.slideNumber, tmpImage.fieldNumber, tmpImage.slide.exam.examID]
                inCategory:@"SYNC"];

        //load the image
        [tmpMOC performBlock:^{
            [TBScopeData getImage:tmpImage resultBlock:^(UIImage* im, NSError* error) {
                if (error==nil) {
                    //create a google file object from this image
                    GTLDriveFile *file = [GTLDriveFile object];
                    file.title = [NSString stringWithFormat:@"%@ - %@ - %d-%d.jpg",
                                   tmpImage.slide.exam.cellscopeID,
                                   tmpImage.slide.exam.examID,
                                   tmpImage.slide.slideNumber,
                                   tmpImage.fieldNumber];
                    file.descriptionProperty = @"Uploaded from CellScope";
                    file.mimeType = @"image/jpeg";
                    file.modifiedDate = [GTLDateTime dateTimeWithRFC3339String:tmpImage.slide.exam.dateModified];
                    NSData *data = UIImageJPEGRepresentation((UIImage *)im,1.0);
                    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data
                                                                                                 MIMEType:file.mimeType];
                    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                                       uploadParameters:uploadParameters];
                    query.setModifiedDate = YES;

                    //execute upload query
                    [self executeQueryWithTimeout:query
                                completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *insertedFile, NSError *error) {
                                    if (error == nil) {
                                        // Save this fileID to CD, but don't change modified date of exam
                                        tmpImage.googleDriveFileID = insertedFile.identifier;
                                        NSError *tmpMOCSaveError;
                                        if (![tmpMOC save:&tmpMOCSaveError]) {
                                            NSLog(@"Error saving temporary managed object context.");
                                        }
                                        [[TBScopeData sharedData] saveCoreData];
                                        [TBScopeData CSLog:[NSString stringWithFormat:@"Uploaded image file name: %@ (ID: %@)", insertedFile.title, insertedFile.identifier] inCategory:@"SYNC"];
                                    }
                                    completionBlock(error); //error likely means google drive over quota or network error
                                }
                                errorHandler:^(NSError* error){
                                    completionBlock(error);
                                }
                    ];
                } else {
                    completionBlock(error); //likely local file not found
                }
            }];
        }];
    } else {
        [TBScopeData CSLog:@"This image has already been uploaded." inCategory:@"SYNC"];
        
        completionBlock(nil);
    }
    
}

//upload an exam (either new or modified) to google drive
- (void)uploadExam:(Exams*)exam completionHandler:(void(^)(NSError*))completionBlock
{
    NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tmpMOC.parentContext = [[TBScopeData sharedData] managedObjectContext];

    // Create a temporary copy of exam belonging to this NSManagedObjectContext
    NSError *tmpExamError;
    Exams *tmpExam = [tmpMOC existingObjectWithID:[exam objectID] error:&tmpExamError];

    //first check to make sure this exam has had all images uploaded (and therefore has google file IDs associated with each)
    BOOL allImagesUploaded = YES;
    for (Slides* sl in tmpExam.examSlides)
        for (Images* im in sl.slideImages)
            if (im.googleDriveFileID==nil)
                allImagesUploaded = NO;
    if (allImagesUploaded)
    {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Uploading exam: %@", tmpExam.examID] inCategory:@"SYNC"];
        
        //create a google file object from this exam
        GTLDriveFile* file = [GTLDriveFile object];
        file.title = [NSString stringWithFormat:@"%@ - %@.json",
                      tmpExam.cellscopeID,
                      tmpExam.examID];
        file.descriptionProperty = @"Uploaded from CellScope";
        file.mimeType = @"application/json";
        file.modifiedDate = [GTLDateTime dateTimeWithRFC3339String:tmpExam.dateModified];
        NSArray* arrayToSerialize = [NSArray arrayWithObjects:tmpExam,nil];
        NSData* data = [CoreDataJSONHelper jsonStructureFromManagedObjects:arrayToSerialize];
        
        //create query
        GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
        GTLQueryDrive* query;
        if (tmpExam.googleDriveFileID==nil) {
            [TBScopeData CSLog:@"This is a new file in Google Drive" inCategory:@"SYNC"];
            query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                uploadParameters:uploadParameters];
        } else {  // this file exists in google, so we are updating
            [TBScopeData CSLog:@"File exists in Google Drive, will update." inCategory:@"SYNC"];
            query = [GTLQueryDrive queryForFilesUpdateWithObject:file
                                                          fileId:tmpExam.googleDriveFileID
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
                              tmpExam.googleDriveFileID = insertedFile.identifier;
                              tmpExam.synced = YES;

                              // Save
                              NSError *error;
                              if (![tmpMOC save:&error]) {
                                  NSLog(@"Error saving temporary managed object context.");
                              }
                              [[TBScopeData sharedData] saveCoreData];
                              
                              [TBScopeData CSLog:[NSString stringWithFormat:@"Uploaded exam with file name: %@ (ID: %@)", insertedFile.title, insertedFile.identifier] inCategory:@"SYNC"];
                          }
                          completionBlock(error);
                      }
                      errorHandler:^(NSError* error){
                          completionBlock(error);
                      }
         ];
    }
    else
    {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Exam %@ does not yet have all images uploaded and will be skipped.", tmpExam.examID] inCategory:@"SYNC"];
        completionBlock(nil);
    }

}

//download exam (new or modified)
- (void)downloadExam:(GTLDriveFile*)file completionHandler:(void(^)(NSError*))completionBlock
{
    [TBScopeData CSLog:[NSString stringWithFormat:@"Downloading exam JSON file: %@ (ID: %@)",file.title,file.identifier] inCategory:@"SYNC"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
    
    // For downloads requiring authorization, set the authorizer.
    fetcher.authorizer = self.driveService.authorizer;
    //TODO: check what happens w/o network
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            tmpMOC.parentContext = [[TBScopeData sharedData] managedObjectContext];
            [tmpMOC performBlock:^{
                NSError* examsFromJSONError;
                NSArray* examsFromJSON = [CoreDataJSONHelper managedObjectsFromJSONStructure:data withManagedObjectContext:tmpMOC error:&examsFromJSONError];
                if (examsFromJSONError == nil && examsFromJSON.count>0) {
                    Exams* downloadedExam = (Exams*)examsFromJSON[0];

                    [TBScopeData CSLog:[NSString stringWithFormat:@"Downloaded exam ID: %@", downloadedExam.examID] inCategory:@"SYNC"];

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
                            NSArray* imageResults = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:tmpMOC];
                            for (Images* localMatchingImage in imageResults)
                            {
                                if (im!=localMatchingImage) //in other words, this was a pre-existing image, not the one that was just downloaded
                                    im.path = localMatchingImage.path;
                            }

                        }
                    }

                    //check if this googleFileID exists in the CD exam database.
                    NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)",downloadedExam.googleDriveFileID];
                    NSArray* examResults = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:tmpMOC];
                    for (Exams* localExam in examResults)
                    {
                        //delete old copy
                        if (downloadedExam!=localExam)
                        {
                            [tmpMOC deleteObject:localExam];
                            [TBScopeData CSLog:@"This exam exists, so it will be replaced with the new file." inCategory:@"SYNC"];
                        }
                    }

                    // Save
                    NSError *error;
                    if (![tmpMOC save:&error]) {
                        NSLog(@"Error saving temporary managed object context.");
                    }
                    [[TBScopeData sharedData] saveCoreData];

                    completionBlock(nil);
                } else {
                    [TBScopeData CSLog:@"Error parsing JSON file" inCategory:@"SYNC"];
                    completionBlock(examsFromJSONError);
                }
            }];
        } else
            completionBlock(error);
    }];
}

- (void)downloadImage:(Images*)image completionHandler:(void(^)(NSError*))completionBlock
{
    NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tmpMOC.parentContext = [[TBScopeData sharedData] managedObjectContext];

    // Create a temporary copy of image belonging to this NSManagedObjectContext
    NSError *tmpImageError;
    Images *tmpImage = [tmpMOC existingObjectWithID:[image objectID] error:&tmpImageError];

    //double check to make sure it hasn't already been downloaded
    if (tmpImage.path==nil)
    {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Downloading image %d-%d of exam %@ from Google file ID: %@", tmpImage.slide.slideNumber, tmpImage.fieldNumber, tmpImage.slide.exam.examID, tmpImage.googleDriveFileID] inCategory:@"SYNC"];
        
        //get the image file metadata
        GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:tmpImage.googleDriveFileID];
        // NOTE: Google Drive queries MUST be run on the main thread to receive a response
        [self executeQueryWithTimeout:query
                      completionHandler:^(GTLServiceTicket *ticket,
                                          GTLDriveFile *file, NSError *error) {
                          if (error==nil) {
                              GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
                              fetcher.authorizer = self.driveService.authorizer;
                              [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                                  if (error==nil) {
                                      [tmpMOC performBlock:^{
                                          //there's an issue with this: if the analysis is rerun on the same image, this won't ever update
                                          //populate the ROI images in CD
                                          //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          //save this image to asset library as jpg
                                          UIImage* im = [UIImage imageWithData:data];
                                      
                                          /*
                                          if (image.imageAnalysisResults!=nil) {
                                              for (ROIs* roi in image.imageAnalysisResults.imageROIs)
                                              {
                                                  NSData* pngData = UIImagePNGRepresentation([TBScopeData getPatchFromImage:im X:roi.x Y:roi.y]);
                                                  //dispatch_async(dispatch_get_main_queue(), ^{
                                                      roi.image = pngData;
                                                  //});
                                              }
                                              
                                          }
                                          */
                                          //dispatch_async(dispatch_get_main_queue(), ^{
                                              ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                              [library writeImageToSavedPhotosAlbum:im.CGImage
                                                                        orientation:(ALAssetOrientation)[im imageOrientation]
                                                                    completionBlock:^(NSURL *assetURL, NSError *error){
                                                  if (error==nil) {
                                                      tmpImage.path = assetURL.absoluteString;

                                                      // Save
                                                      NSError *tmpMOCSaveError;
                                                      if (![tmpMOC save:&tmpMOCSaveError]) {
                                                          NSLog(@"Error saving temporary managed object context");
                                                      }
                                                      [[TBScopeData sharedData] saveCoreData];
                                                      
                                                      [TBScopeData CSLog:[NSString stringWithFormat:@"Downloaded image to path: %@", tmpImage.path]
                                                              inCategory:@"SYNC"];
                                                  }
                                                  
                                                  completionBlock(error); //error likely means disk is full
                                              }];
                                          //});
                                      }];
                                  }
                                  else
                                      completionBlock(error); //likely data transfer interrupted
                              }];
                          }
                          else if (error.code == 404) //file not found error
                          {
                              [TBScopeData CSLog:@"referenced file does not exist in google drive (it was deleted on server?). fileID will be set to nil on client."
                                      inCategory:@"SYNC"];
              
                              image.googleDriveFileID = nil;
                              [[TBScopeData sharedData] saveCoreData];
                              completionBlock(error);
                          }
                          else
                              completionBlock(error); //likely data transfer interrupted
                      }
                         errorHandler:^(NSError* error){
                             completionBlock(error); //likely network connection not present
                         }];
    }
    else
    {
        [TBScopeData CSLog:@"this image has already been downloaded" inCategory:@"SYNC"];
        completionBlock(nil);
    }
    
}

//uploads any recent log entries to a new text file
- (void) uploadLogWithCompletionHandler:(void(^)(NSError*))completionBlock
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
                          }
                        
                        completionBlock(error);
                      }
                         errorHandler:^(NSError* error){
                             completionBlock(error);
                         }];

    }
    else
    {
        completionBlock(nil);
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
        //NSLog(@"google returned status code: %ld",(long)ticket.statusCode);
        if (ticket.statusCode==0) { //might also handle other error codes? code of 0 means that it didn't even attempt I guess? the other HTTP codes should get handled in the errorhandler above
            [ticket cancelTicket];
            NSError* error = [NSError errorWithDomain:@"GoogleDriveSync" code:123 userInfo:[NSDictionary dictionaryWithObject:@"No response from query. Likely network failure." forKey:@"description"]];
            errorBlock(error);
        }
    });
}

@end
