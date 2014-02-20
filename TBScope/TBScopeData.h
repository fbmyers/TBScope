//
//  TBScopeHardware.h
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h" //TODO: still needed?
#import "DataValidationHelper.h"
#import "Exams.h"
#import "Slides.h"
#import "Images.h"
#import "ImageAnalysisResults.h"
#import "SlideAnalysisResults.h"
#import "ROIs.h"
#import "Logs.h"
#import "Users.h"

@interface TBScopeData : NSObject

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) Users* currentUser;

+ (id)sharedData;

- (void) saveCoreData;

@end
