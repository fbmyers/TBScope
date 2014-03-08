//
//  TBScopeData.m
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeData.h"

@implementation TBScopeData

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
        
        
    }
    return self;
}

- (void) startGPS
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];
}

- (void) saveCoreData
{
    NSError *error;
    if (![self.managedObjectContext save:&error])
        NSLog(@"Failed to commit to core data: %@", [error description]);
}

//assumes CD has already been cleared
- (void) resetCoreData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm a"];

    // Add our default user object in Core Data
    Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:self.managedObjectContext];
    [user setUsername:@"admin"];
    [user setPassword:@"default"];
    [user setAccessLevel:@"ADMIN"];
    
    [self saveCoreData];
    
    Exams* exam;
    Slides* slide;
    Images* image;
    
    exam = (Exams*)[NSEntityDescription insertNewObjectForEntityForName:@"Exams" inManagedObjectContext:self.managedObjectContext];
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
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
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
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
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
    
    slide = (Slides*)[NSEntityDescription insertNewObjectForEntityForName:@"Slides" inManagedObjectContext:self.managedObjectContext];
    [slide setSlideNumber:1];
    [slide setDateCollected:@"2013-10-11T12:35:02.000Z"];
    [slide setDateScanned:@"2013-10-11T12:35:02.000Z"];
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
    
    [self saveCoreData];
    
    
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
                 
                 resultBlock(image,nil);
                 
             }
             
         }
         failureBlock:^(NSError *error)
         {
             resultBlock(nil,error);
             // error handling
             NSLog(@"failure loading image");
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
}

@end
