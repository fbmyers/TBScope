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

@interface TBScopeData : NSObject

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) CLLocationManager* locationManager;

@property (nonatomic, retain) Users* currentUser;


+ (id)sharedData;

- (void) startGPS;

- (void) saveCoreData;

- (void) resetCoreData;

+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern;;

+ (CLLocationCoordinate2D)coordinatesFromString:(NSString*)string;
+ (NSString*)stringFromCoordinates:(CLLocationCoordinate2D)location;

+(NSDate*)dateFromString:(NSString*)str;
+(NSString*)stringFromDate:(NSDate*)date;

+ (void)touchExam:(Exams*)exam;

+ (void)getImage:(Images*)currentImage resultBlock:(void (^)(UIImage* image, NSError* err))resultBlock;

@end
