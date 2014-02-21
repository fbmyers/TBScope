//
//  AppDelegate.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/19/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "CSAppDelegate.h"

@implementation CSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Setup defaults for preference file
    NSString* defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"default-configuration" ofType:@"plist"];
    NSDictionary* defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    //LoginViewController *rootView = (LoginViewController *)self.window.rootViewController;
    //rootView.managedObjectContext = self.managedObjectContext; //todo: move to singleton
    
    //setup data singleton
    [[TBScopeData sharedData] setManagedObjectContext:self.managedObjectContext];
    
    //start bluetooth connection
    [[TBScopeHardware sharedHardware] setupBLEConnection];
    
    
    // if this is the first time the app has run, or if the Reset Button was pressed in config settings, this will initialize core data
    // note that at this point, the database has already been deleted (that happened when the message was sent to managedObjectContext
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ResetCoreDataOnStartup"])
    {
        [self initializeCoreData];
        
    }
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void) initializeCoreData
{
    NSLog(@"Re-initializing Core Data...");
    
    // Set flag so we know not to run this next time
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ResetCoreDataOnStartup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Add our default user object in Core Data
    Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:self.managedObjectContext];
    [user setUsername:@"admin"];
    [user setPassword:@"default"];
    [user setAccessLevel:@"ADMIN"];
    
    [[TBScopeData sharedData] saveCoreData];
    
    Exams* exam;
    Slides* slide;
    Images* image;
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:self.managedObjectContext];
    [exam setExamID:@"HLH1010296"];
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"John Doe 1"];
    [exam setPatientID:@"92037"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:[NSDate timeIntervalSinceReferenceDate]];
    [exam setPatientGender:@"M"];
    [exam setPatientHIVStatus:@"+"];
    [exam setDateModified:[NSDate timeIntervalSinceReferenceDate]];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:[NSDate timeIntervalSinceReferenceDate]];
    [slide setDateScanned:[NSDate timeIntervalSinceReferenceDate]];
    [slide setSputumQuality:@"B"];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I1_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I2_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I3_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:4];
    [image setPath:@"DHC5_CHP21_1010296_S1_R1_HLH_I4_Fluor_Y_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    
    [[TBScopeData sharedData] saveCoreData];
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:self.managedObjectContext];
    [exam setExamID:@"HLH1010107"];
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"John Doe 2"];
    [exam setPatientID:@"38293"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:[NSDate timeIntervalSinceReferenceDate]];
    [exam setPatientGender:@"M"];
    [exam setPatientHIVStatus:@"-"];
    [exam setDateModified:[NSDate timeIntervalSinceReferenceDate]];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:[NSDate timeIntervalSinceReferenceDate]];
    [slide setDateScanned:[NSDate timeIntervalSinceReferenceDate]];
    [slide setSputumQuality:@"BS"];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I1_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I2_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010107_S1_R1_HLH_I3_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];

    [[TBScopeData sharedData] saveCoreData];
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:self.managedObjectContext];
    [exam setExamID:@"HLH1010195"];
    [exam setUserName:@"example"];
    [exam setGpsLocation:@"0,0"];
    [exam setLocation:@"Hanoi Lung Hospital"];
    [exam setIntakeNotes:@"Patient presented with persistent cough lasting >2 weeks."];
    [exam setDiagnosisNotes:@"Slide is positive for TB."];
    [exam setPatientName:@"Jane Doe 3"];
    [exam setPatientID:@"23439"];
    [exam setPatientAddress:@"463 Hoang Hoa Tham, Hanoi 10000"];
    [exam setPatientDOB:[NSDate timeIntervalSinceReferenceDate]];
    [exam setPatientGender:@"F"];
    [exam setPatientHIVStatus:@""];
    [exam setDateModified:[NSDate timeIntervalSinceReferenceDate]];
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:[NSDate timeIntervalSinceReferenceDate]];
    [slide setDateScanned:[NSDate timeIntervalSinceReferenceDate]];
    [slide setSputumQuality:@""];
    [exam addExamSlidesObject:slide];
    
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:1];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I1_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:2];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I2_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    image = (Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
    [image setFieldNumber:3];
    [image setPath:@"DHC5_CHP21_1010195_S1_R1_HLH_I4_Fluor_N_F.tif"];
    [image setMetadata:@"example image"];
    [slide addSlideImagesObject:image];
    
    [[TBScopeData sharedData] saveCoreData];
    

}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TBScope.sqlite"];
    
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

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
