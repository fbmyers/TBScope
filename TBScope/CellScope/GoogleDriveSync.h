//
//  GoogleDriveSync.h
//  TBScope
//
//  Created by Frankie Myers on 1/28/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Reachability.h"

#import "TBScopeHardware.h"
#import "TBScopeData.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@interface GoogleDriveSync : NSObject

+ (id)sharedGDS;

@property (nonatomic, retain) GTLServiceDrive *driveService;

@property (strong, nonatomic) Reachability* reachability;

@property (strong, nonatomic) NSMutableArray* imageUploadQueue;
@property (strong, nonatomic) NSMutableArray* imageDownloadQueue;
@property (strong, nonatomic) NSMutableArray* examUploadQueue;
@property (strong, nonatomic) NSMutableArray* examDownloadQueue;

//move these to json helper
- (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)managedObjectsFromJSONStructure:(NSData*)json withManagedObjectContext:(NSManagedObjectContext*)moc;

- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject;

- (BOOL) isLoggedIn;

- (NSString*) userEmail;

- (void)doSync;

@end

