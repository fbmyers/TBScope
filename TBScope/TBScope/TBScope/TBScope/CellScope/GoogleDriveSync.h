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
#import "TBScopeHardware.h"
#import "TBScopeData.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@interface GoogleDriveSync : NSObject

+ (id)sharedGDS;

@property (nonatomic, retain) GTLServiceDrive *driveService; //TODO: make this a singleton

@property (strong, nonatomic) Exams* examToUpload;

@property (strong, nonatomic) UIAlertView* waitIndicator;

- (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc;

- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject;

- (void)uploadSlide;

//internal function
- (void)uploadImage:(NSNotification*)notification;


@end
