//
//  TBScopeHardware.h
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CoreDataHelper.h" //TODO: still needed?
#import "Exams.h"
#import "Slides.h"
#import "Images.h"
#import "ImageAnalysisResults.h"
#import "SlideAnalysisResults.h"
#import "ROIs.h"
#import "Logs.h"
#import "Users.h"
#import "GTLDateTime.h"

@interface TBScopeData : NSObject <CLLocationManagerDelegate>

//TODO: might want to create a third MOC for sync (so that while exams are being edited, other exams can still be synced)
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *logMOC; //this is just used for logging

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) Users* currentUser;

@property (nonatomic,strong) CLLocation* lastLocation;

+ (id)sharedData;

//TODO: make these class methods
- (void) startGPS;

- (void) saveCoreData;

- (void) resetCoreData;

+ (void)CSLog:(NSString*)entry inCategory:(NSString*)cat;

+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern;;

+ (CLLocationCoordinate2D)coordinatesFromString:(NSString*)string;
+ (NSString*)stringFromCoordinates:(CLLocationCoordinate2D)location;

+(NSDate*)dateFromString:(NSString*)str;
+(NSString*)stringFromDate:(NSDate*)date;

+ (void)touchExam:(Exams*)exam;

+ (void)getImage:(Images*)currentImage resultBlock:(void (^)(UIImage* image, NSError* err))resultBlock;


+ (UIImage*)getPatchFromImage:(UIImage*)image X:(float)x Y:(float)y;

@end
