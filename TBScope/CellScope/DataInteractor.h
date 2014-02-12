//
//  DataInteractor.h
//  CellScope
//
//  Created by Wayne Gerard on 3/25/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"
#include "svm.h"

@interface DataInteractor : NSObject

/**
    Loads a CSV into an NSMutableArray (an array of arrays), and returns it.
 */
+ (cv::Mat) loadCSVWithPath: (NSString*) path;

/**
    Stores scores and centroids down to core data.
    @param scores    Corresponding scores (likelihood of being bacilli)
    @param centroids Array of centroids, sorted by descending patch score. 
                     Each row contains (row,col) indices.
 */
+ (void) storeScores: (NSMutableArray*) scores withCentroids:(NSMutableArray*) centroids;

/**
    Loads a SVM model from disk and returns it as a LibSVM model
    @param fileName The filename to load from
    @return         Returns a LibSVM model
 */
+ (svm_model*) loadSVMModelWithPathName: (NSString*) fileName;

@end
