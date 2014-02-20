//
//  TBDiagnoser.h
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"
#import "ROIs.h"
#import "ImageAnalysisResults.h"


@interface TBDiagnoser : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (ImageAnalysisResults*) runWithImage: (UIImage*)img;

@end
