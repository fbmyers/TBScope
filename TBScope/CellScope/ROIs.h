//
//  ROIs.h
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageAnalysisResults;

@interface ROIs : NSManagedObject

@property (nonatomic) float score;
@property (nonatomic) int32_t x;
@property (nonatomic) int32_t y;
@property (nonatomic) BOOL userCall;
@property (nonatomic, retain) ImageAnalysisResults *imageAnalysisResult;

@end
