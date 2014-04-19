//
//  TBScopeData.m
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeData.h"

NSManagedObjectModel* _managedObjectModel;
NSPersistentStoreCoordinator* _persistentStoreCoordinator;

@implementation TBScopeData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize logMOC = _logMOC;

+ (id)sharedData {
    static TBScopeData *newData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newData = [[self alloc] init];
    });
    return newData;
}

- (id)init {
    if (self = [super init]) {
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            
            _logMOC = [[NSManagedObjectContext alloc] init];
            [_logMOC setPersistentStoreCoordinator:coordinator];
        }
    }
    return self;
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TBScope" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL* applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"TBScope.sqlite"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ResetCoreDataOnStartup"])
    {
        //deletes the database
        //note that in didFinishLaunching above, the DB will be initialized with user account, etc.
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        NSLog(@"Core Data SQLLite file deleted");
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (void) startGPS
{
    //TODO: come back to this. it's not updating.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 10 m
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [TBScopeData CSLog:[NSString stringWithFormat:@"Did update GPS location: (%f,%f)",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude] inCategory:@"DATA"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [TBScopeData CSLog:[NSString stringWithFormat:@"GPS error: %@",error.description] inCategory:@"DATA"];
}

- (void) saveCoreData
{
    NSError *error;
    if (_managedObjectContext.hasChanges)
    {
        if ([_managedObjectContext save:&error])
        {
            [TBScopeData CSLog:@"Committed changes to core data" inCategory:@"DATA"];
        }
        else
        {
            [TBScopeData CSLog:[NSString stringWithFormat:@"Failed to commit to core data: %@", error.description]
                    inCategory:@"DATA"];
        }
    }
}

//assumes CD has already been cleared
- (void) resetCoreData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm a"];

    // Add our default user object in Core Data
    Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:_managedObjectContext];
    [user setUsername:@"admin"];
    [user setPassword:@"default"];
    [user setAccessLevel:@"ADMIN"];
    
    [self saveCoreData];
    
    Exams* exam;
    Slides* slide;
    Images* image;
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:_managedObjectContext];
    [exam setExamID:@"HLH1010296"];
    [exam setCellscopeID:@"EXAMPLE"];
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"John Doe 1"];
    [exam setPatientID:@"92037"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:@"1973-06-11T00:00:00.000-00:00"];
    [exam setPatientGender:@"M"];
    [exam setPatientHIVStatus:@"+"];
    [exam setDateModified:@"2013-10-11T12:35:02.000Z"];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:_managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
    [slide setSputumQuality:@"B"];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I1_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I2_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I3_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:4];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I4_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    
    [[TBScopeData sharedData] saveCoreData];
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:_managedObjectContext];
    [exam setExamID:@"HLH1010107"];
    [exam setCellscopeID:@"EXAMPLE"];
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"John Doe 2"];
    [exam setPatientID:@"38293"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:@"1980-08-19T00:00:00.000-00:00"];
    [exam setPatientGender:@"M"];
    [exam setPatientHIVStatus:@"-"];
    [exam setDateModified:@"2013-10-11T12:35:02.000Z"];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:_managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
    [slide setSputumQuality:@"BS"];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I1_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I2_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I3_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    
    [[TBScopeData sharedData] saveCoreData];
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:_managedObjectContext];
    [exam setExamID:@"HLH1010195"];
    [exam setCellscopeID:@"EXAMPLE"];    
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"Jane Doe 3"];
    [exam setPatientID:@"23439"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:@"1987-02-04T00:00:00.000-00:00"];
    [exam setPatientGender:@"F"];
    [exam setPatientHIVStatus:@""];
    [exam setDateModified:@"2013-10-11T12:35:02.000Z"];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:_managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
    [slide setSputumQuality:@""];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I1_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I2_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I4_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    
    [self saveCoreData];
    
    
}

+ (void)CSLog:(NSString*)entry inCategory:(NSString*)cat
{
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@>> %@",cat,entry]);

    Logs* logEntry = (Logs*)[NSEntityDescription insertNewObjectForEntityForName:@"Logs" inManagedObjectContext:[[TBScopeData sharedData] logMOC]];
    
    logEntry.entry = entry;
    logEntry.category = cat;
    logEntry.date = [TBScopeData stringFromDate:[NSDate date]];
    logEntry.synced = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{ //trying this, not sure how to ensure thread safety here
        [[[TBScopeData sharedData] logMOC] save:nil];
    });
}

// Validate the input string with the given pattern and
// return the result as a boolean
+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = NO;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound)
        didValidate = YES;
    
    return didValidate;
}

+ (CLLocationCoordinate2D)coordinatesFromString:(NSString*)string
{

    // the location object that we want to initialize based on the string
    CLLocationCoordinate2D location;
    
    // split the string by comma
    NSArray * locationArray = [string componentsSeparatedByString: @","];
    
    // set our latitude and longitude based on the two chunks in the string
    location.latitude = [[locationArray objectAtIndex:0] doubleValue];
    location.longitude = [[locationArray objectAtIndex:1] doubleValue];
    
    return location;
}

+ (NSString*)stringFromCoordinates:(CLLocationCoordinate2D)location
{
    return [NSString stringWithFormat:@"%f,%f",location.latitude,location.longitude];
}

+ (void)getImage:(Images*)currentImage resultBlock:(void (^)(UIImage* image, NSError* err))resultBlock
{
    NSURL *aURL = [NSURL URLWithString:currentImage.path];
    if ([[aURL scheme] isEqualToString:@"assets-library"])
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             NSError* err = nil;
             UIImage* image = nil;
             
             if (asset==nil)
             {
                err = [NSError errorWithDomain:@"TBScopeData" code:1 userInfo:nil];
                 [TBScopeData CSLog:@"Image returned was nil" inCategory:@"DATA"];
             }
             else
             {
                 //load the image
                 ALAssetRepresentation* rep = [asset defaultRepresentation];
                 CGImageRef iref = [rep fullResolutionImage];
                 image = [UIImage imageWithCGImage:iref];
                 
                 rep = nil;
                 iref = nil;
                
             }
             
             resultBlock(image,err);
         }
         failureBlock:^(NSError *error)
         {
             [TBScopeData CSLog:@"Error while loading image from asset library" inCategory:@"DATA"];
             resultBlock(nil,error);
         }];
    }
    else //this is a file in the bundle (only necessary for demo images)
    {
       UIImage* image = [UIImage imageNamed:currentImage.path];
       resultBlock(image,nil);
    }
    
}

//these assume RFC3339 strings (google formatted)
+(NSDate*)dateFromString:(NSString*)str
{
    GTLDateTime* dt = [GTLDateTime dateTimeWithRFC3339String:str];

    return dt.date;
}
+(NSString*)stringFromDate:(NSDate*)date
{
    GTLDateTime* dt = [GTLDateTime dateTimeWithDate:date timeZone:[NSTimeZone timeZoneWithName:@"Universal"]];
    return dt.RFC3339String;
}

//sets date modified to current date
+ (void)touchExam:(Exams*)exam {
    exam.dateModified = [TBScopeData stringFromDate:[NSDate date]];
    exam.synced = NO;
}

@end
