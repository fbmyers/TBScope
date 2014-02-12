//
//  GoogleDriveSync.h
//  TBScope
//
//  Created by Frankie Myers on 1/28/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "Slides.h"
#import "Images.h"
#import "SlideAnalysisResults.h"
#import "ImageAnalysisResults.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@interface GoogleDriveSync : NSObject


@property (nonatomic, retain) GTLServiceDrive *driveService; //TODO: make this a singleton

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext; //TODO: this will be in singleton

@property (strong, nonatomic) Slides* slideToUpload;

@property (strong, nonatomic) UIAlertView* waitIndicator;

- (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc;

- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject;

- (void)uploadSlide;

//internal function
- (void)uploadImage:(NSNotification*)notification;


@end
