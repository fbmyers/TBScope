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
        self.driveService.shouldFetchNextPages = YES;
        
        self.examUploadQueue = [[NSMutableArray alloc] init];
        self.examDownloadQueue = [[NSMutableArray alloc] init];
        self.imageUploadQueue = [[NSMutableArray alloc] init];
        self.imageDownloadQueue = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImage:) name:@"UploadImage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        
    }

    return self;
}


- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {NSLog(@"no");}
    else if (remoteHostStatus == ReachableViaWiFi) {NSLog(@"wifi"); }
    else if (remoteHostStatus == ReachableViaWWAN) {NSLog(@"cell"); }
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

- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject
{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
    [valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
    for (NSString *relationshipName in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if ([description deleteRule]!=2) //kind of a hack, but avoids recursive loop
            continue;
        if (![description isToMany]) {
            NSManagedObject *relationshipObject = [managedObject valueForKey:relationshipName];
            if (relationshipObject!=nil)
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
        NSLog(@"%@",[err description]);
    }
    
    return jsonString;
}


- (NSManagedObject*)managedObjectFromStructure:(NSDictionary*)structureDictionary withManagedObjectContext:(NSManagedObjectContext*)moc
{
    //NSMutableDictionary* structureDictionary = [NSMutableDictionary dictionaryWithDictionary:dict]; //TODO: use mutables throughout

    NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
    
    //[structureDictionary removeObjectForKey:@"ManagedObjectName"];
    
    for (NSString* key in [structureDictionary allKeys]) {
        //NSString* dicValue = (NSString*)[structureDictionary valueForKey:key];

        if (![key isEqualToString:@"ManagedObjectName"])
        {
            id dicValue = [structureDictionary valueForKey:key];
            if ([dicValue isKindOfClass:[NSNull class]])
                [managedObject setValue:nil forKey:key];
            else if ([dicValue isKindOfClass:[NSArray class]] || [dicValue isKindOfClass:[NSDictionary class]])
                ;
            else
                [managedObject setValue:[structureDictionary valueForKey:key] forKey:key];
        }
    }
    
    //NSDictionary* d = [NSDictionary dictionaryWithDictionary:structureDictionary];
    
    //[managedObject setValuesForKeysWithDictionary:d];
    
    for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if ([description deleteRule]!=2) //kind of a hack, but avoids recursive loop
            continue;
        if (![description isToMany]) {
            NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
            if (childStructureDictionary) {
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                [managedObject setValue:childObject forKey:relationshipName];
            }
            continue;
        }
        NSMutableOrderedSet *relationshipSet = [managedObject mutableOrderedSetValueForKey:relationshipName];
        NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
        for (NSDictionary *childStructureDictionary in relationshipArray) {
            if (childStructureDictionary) {
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                [relationshipSet addObject:childObject];
            }
        }
    }
    return managedObject;
}

- (NSArray*)managedObjectsFromJSONStructure:(NSData*)json withManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSError *error = nil;
    NSArray *structureArray = [[CJSONDeserializer deserializer] deserializeAsArray:json error:&error];
    NSAssert2(error == nil, @"Failed to deserialize\n%@\n%@", [error localizedDescription], json);
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    for (NSDictionary *structureDictionary in structureArray) {
        [objectArray addObject:[self managedObjectFromStructure:structureDictionary withManagedObjectContext:moc]];
    }
    return objectArray;
}

- (void)doSync
{
    //allInSync keeps track of whether any changes are added to the upload/download queues as a result of this doSync call.
    //note that since the modified date comparison requires an asynchronous call to google drive, it's not possible to loop
    //through all exams and say at the end whether all are in sync. So this will be determined the NEXT time doSync is called
    
    static BOOL previousSyncHadNoChanges = NO; //to start, we assume things are NOT in sync
    static NSDate* previousSyncDate = nil;
    
    if (self.imageUploadQueue.count>0 || self.imageDownloadQueue.count>0 || self.examUploadQueue.count>0 || self.examDownloadQueue.count>0) {
        NSLog(@"queue is still not empty, will wait for it to empty before initiating new sync");
        previousSyncHadNoChanges = NO;
    }
    else //queues are empty
    {
        //this will be true if no uploads/downloads were performed on the last doSync call
        if (previousSyncHadNoChanges) {
            NSLog(@"last sync resulted in no changes, so this unit is in sync");
            [[NSUserDefaults standardUserDefaults] setObject:previousSyncDate forKey:@"LastSyncDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSDate *lastFullSync = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:@"LastSyncDate"];
        NSLog(@"last full sync date: %@",lastFullSync);

        previousSyncHadNoChanges = YES;
        previousSyncDate = [NSDate date]; //rename

        //reachability?
        if ([self isOkToSync])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStarted" object:nil];
            
            NSPredicate* pred; NSMutableArray* results;
            
            /////////////////////////
            //push images
            NSLog(@"fetching new images from core data");
            pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID = nil) && (path != nil)"];
            results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
            for (Images* im in results)
            {
                NSLog(@"adding image #%d from slide #%d from exam %@ to upload queue",im.fieldNumber,im.slide.slideNumber,im.slide.exam.examID);
                [self.imageUploadQueue addObject:im];
                previousSyncHadNoChanges = NO;
            }
            
            /////////////////////////
            //push exams
            NSLog(@"fetching new/modified exams from core data");
            pred = [NSPredicate predicateWithFormat:@"(dateModified >= %@) || (googleDriveFileID = nil)", lastFullSync];
            results = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
            for (Exams* ex in results)
            {
                //check to make sure this exam has had all images uploaded (and therefore has google file IDs associated with each)
                //probably don't need to do this, since if image uploads don't complete the exam won't get uploaded, but this doesn't hurt
                BOOL allImagesUploaded = YES;
                for (Slides* sl in ex.examSlides)
                     for (Images* im in sl.slideImages)
                         if (im.googleDriveFileID==nil)
                             allImagesUploaded = NO;
                
                if (!allImagesUploaded)
                {
                    NSLog(@"exam %@ does not yet have all images uploaded, so it will be skipped for now",ex.examID);
                    previousSyncHadNoChanges = NO;
                }
                else
                {
                    if (ex.googleDriveFileID==nil)
                    {
                        NSLog(@"Adding new exam %@ to upload queue. local timestamp: %@",ex.examID,ex.dateModified);
                        [self.examUploadQueue addObject:ex];
                        previousSyncHadNoChanges = NO;
                    }
                    else //exam exists on both client and server, so check dates
                    {
                        //get modified date on server
                        GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:ex.googleDriveFileID];
                        [self.driveService executeQuery:query
                                      completionHandler:^(GTLServiceTicket *ticket,
                                                          GTLDriveFile *file, NSError *error) {
                                          if (error==nil) {
                                              if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]>0) { //have to do this since ms values are a little funny, so round to nearest s
                                                  NSLog(@"Adding modified exam %@ to upload queue. server timestamp: %@, local timestamp: %@",ex.examID,[TBScopeData stringFromDate:file.modifiedDate.date],ex.dateModified);
                                                  [self.examUploadQueue addObject:ex];
                                                  previousSyncHadNoChanges = NO;
                                              }
                                          }
                                          else if (error.code==404) //the file referenced by this exam isn't present on server, so remove this google drive ID
                                          {
                                              NSLog(@"this file doesn't exist in google drive (deleted on server?), so removing this reference..");
                                              ex.googleDriveFileID = nil;
                                              [[TBScopeData sharedData] saveCoreData];
                                          }
                                          else {
                                              NSLog(@"an error occured: %@",[error description]);
                                              previousSyncHadNoChanges = NO;
                                          }
                                          
                                          
                                      }];
                    }
                } //next exam
            }
            
            /////////////////////////
            //pull exams
            //get all exams on server modified after last sync date
            NSLog(@"fetching modified files from google");
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
            query.q = [NSString stringWithFormat:@"modifiedDate > '%@' and mimeType='application/json'",[GTLDateTime dateTimeWithDate:lastFullSync timeZone:[NSTimeZone systemTimeZone]].RFC3339String];
            
            [self.driveService executeQuery:query
                          completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files,
                                              NSError *error) {
                              if (error == nil) {
                                  NSLog(@"fetched %d exam json files from google modified since last full sync",files.items.count);
                                  for (GTLDriveFile* file in files)
                                  {
                                      //check if there is a corresponding record in CD for this googleFileID
                                      NSPredicate* pred = [NSPredicate predicateWithFormat:@"(googleDriveFileID == %@)", file.identifier];
                                      NSArray* result = [CoreDataHelper searchObjectsForEntity:@"Exams" withPredicate:pred andSortKey:@"dateModified" andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
                                      if (result.count==0)
                                      {
                                          NSLog(@"Adding new exam %@ to download queue. server timestamp: %@",file.identifier,file.modifiedDate.date);
                                          [self.examDownloadQueue addObject:file];
                                          previousSyncHadNoChanges = NO;
                                      }
                                      else
                                      {
                                          Exams* ex = (Exams*)result[0];
                                          if ([[TBScopeData dateFromString:ex.dateModified] timeIntervalSinceDate:file.modifiedDate.date]<0) {
                                              NSLog(@"Adding modified exam %@ to download queue. server timestamp: %@, local timestamp: %@",ex.examID,[TBScopeData stringFromDate:file.modifiedDate.date],ex.dateModified);
                                              [self.examDownloadQueue addObject:file];
                                              previousSyncHadNoChanges = NO;
                                          }
                                      }
                                  }
                              } else {
                                  NSLog(@"An error occurred: %@", [error description]);
                                  previousSyncHadNoChanges = NO;
                              }
                          }];
            
            /////////////////////////
            //pull images
            //search CD for images with empty path
            NSLog(@"fetching new images from google");
            pred = [NSPredicate predicateWithFormat:@"(path = nil) && (googleDriveFileID != nil)"];
            results = [CoreDataHelper searchObjectsForEntity:@"Images" withPredicate:pred andSortKey:nil andSortAscending:YES andContext:[[TBScopeData sharedData] managedObjectContext]];
            for (Images* im in results)
            {
                NSLog(@"adding image #%d from slide #%d from exam %@ to download queue",im.fieldNumber,im.slide.slideNumber,im.slide.exam.examID);
                [self.imageDownloadQueue addObject:im];
                previousSyncHadNoChanges = NO;
            }
            
        }
        else {
            NSLog(@"not logged in or google unreachable");
            previousSyncHadNoChanges = NO;
        }
    }
    
    
    //start processing queue. this will start 10s later because we want to make sure the push requests have a chance to populate (they require responses from the server for modified dates)
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(processTransferQueues) userInfo:nil repeats:NO];
    
    //schedule next sync in the future
    [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"SyncInterval"] target:self selector:@selector(doSync) userInfo:nil repeats:NO];

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
        
        [self processTransferQueues];
    };
    
    void (^errorBlock)(NSError*) = ^(NSError* error){
        NSLog(@"error occured while processing queue (network error?)");
        NSLog(@"%@",[error description]);
    };
    
    
    NSLog(@"Processing next item in queue...");
    if (self.imageUploadQueue.count>0) {
        [self uploadImage:(Images*)self.imageUploadQueue[0]
        completionHandler:completionBlock
             errorHandler:errorBlock];
    }
    else if (self.examUploadQueue.count>0) {
        [self uploadExam:(Exams*)self.examUploadQueue[0]
       completionHandler:completionBlock
            errorHandler:errorBlock];
    }
    else if (self.examDownloadQueue.count>0) {
        [self downloadExam:(GTLDriveFile*)self.examDownloadQueue[0]
         completionHandler:completionBlock
              errorHandler:errorBlock];
    }
    else if (self.imageDownloadQueue.count>0) {
        [self downloadImage:(Images*)self.imageDownloadQueue[0]
          completionHandler:completionBlock
               errorHandler:errorBlock];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoogleSyncStopped" object:nil];
        NSLog(@"upload/download queues empty");
    }
    

}

// Uploads a photo to Google Drive and sets the local googleFileID to the fileID provided by google
- (void)uploadImage:(Images*)image completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{

    NSLog(@"UPLOADING IMAGE #%d FROM SLIDE #%d FROM EXAM %@",image.fieldNumber,image.slide.slideNumber,image.slide.exam.examID);
    
    //load the image
    [TBScopeData getImage:image resultBlock:^(UIImage* im, NSError* error)
     {
         if (error==nil)
         {
             //create a google file object from this image
             GTLDriveFile *file = [GTLDriveFile object];
             file.title = [NSString stringWithFormat:@"%@ - %@ - %d-%d",
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
             [self.driveService executeQuery:query
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
               }];
         }
         else
             errorBlock(error); //likely local file not found
    }];
}

//upload an exam (either new or modified) to google drive
- (void)uploadExam:(Exams*)exam completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    NSLog(@"UPLOADING EXAM: %@",exam.examID);
    
    //create a google file object from this exam
    GTLDriveFile* file = [GTLDriveFile object];
    file.title = [NSString stringWithFormat:@"%@ - %@",
                  exam.cellscopeID,
                  exam.examID];
    file.descriptionProperty = @"Uploaded from CellScope";
    file.mimeType = @"application/json";
    file.modifiedDate = [GTLDateTime dateTimeWithRFC3339String:exam.dateModified];
    NSArray* arrayToSerialize = [NSArray arrayWithObjects:exam,nil];
    NSData* data = [self jsonStructureFromManagedObjects:arrayToSerialize];
    
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
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {

                      if (error == nil)
                      {
                          //save this fileID to CD, but don't change modified date of exam
                          exam.googleDriveFileID = insertedFile.identifier;
                          [[TBScopeData sharedData] saveCoreData];
                          
                          NSLog(@"Uploaded exam file name: %@, ID: %@", insertedFile.title, insertedFile.identifier);
                          
                          completionBlock();
                      }
                      else
                          errorBlock(error);
                      
                  }];
    
}


- (void)downloadExam:(GTLDriveFile*)file completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    NSLog(@"DOWNLOADING EXAM FROM JSON FILE: %@, ID: %@",file.title,file.identifier);
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
    
    // For downloads requiring authorization, set the authorizer.
    fetcher.authorizer = self.driveService.authorizer;

    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSArray* result = [self managedObjectsFromJSONStructure:data withManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
            Exams* downloadedExam = (Exams*)result[0];
            
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
            
        } else
            errorBlock(error);
    }];
}

- (void)downloadImage:(Images*)image completionHandler:(void(^)())completionBlock errorHandler:(void(^)(NSError*))errorBlock
{
    NSLog(@"DOWNLOADING IMAGE #%d FROM SLIDE #%d FROM EXAM %@ FROM GOOGLE FILE ID %@",image.fieldNumber,image.slide.slideNumber,image.slide.exam.examID,image.googleDriveFileID);

    //get the image file metadata
    GTLQuery* query = [GTLQueryDrive queryForFilesGetWithFileId:image.googleDriveFileID];
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *file, NSError *error) {
                      if (error==nil) {
                          GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:file.downloadUrl];
                          fetcher.authorizer = self.driveService.authorizer;
                          
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
                  }];
    
    
}

@end
