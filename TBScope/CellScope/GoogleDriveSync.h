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

#import "CoreDataJSONHelper.h"

#define ONLY_CHECK_RECORDS_SINCE_LAST_FULL_SYNC 0
#define GOOGLE_DRIVE_TIMEOUT 5

@interface GoogleDriveSync : NSObject

+ (id)sharedGDS;

@property (nonatomic, retain) GTLServiceDrive *driveService;

@property (strong, nonatomic) Reachability* reachability;

@property (strong, nonatomic) NSMutableArray* imageUploadQueue;
@property (strong, nonatomic) NSMutableArray* imageDownloadQueue;
@property (strong, nonatomic) NSMutableArray* examUploadQueue;
@property (strong, nonatomic) NSMutableArray* examDownloadQueue;

@property (nonatomic) BOOL syncEnabled;
@property (nonatomic) BOOL isSyncing;

- (BOOL) isLoggedIn;

- (NSString*) userEmail;

- (void)doSync;

- (void) executeQueryWithTimeout:(GTLQuery*)query
               completionHandler:(id)completionBlock
                    errorHandler:(void(^)(NSError*))errorBlock;

@end

