//
//  DataInteractor.m
//  CellScope
//
//  Created by Wayne Gerard on 3/25/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "DataInteractor.h"
#import "CSAppDelegate.h"

@implementation DataInteractor

+ (cv::Mat) loadCSVWithPath: (NSString*) path {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"csv"];
    NSString* fullBuffer = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvArray = [fullBuffer componentsSeparatedByString:@"\r"]; // Line endings
    int row = 0;
    int col = 0;
    
    int maxRows = [csvArray count];
    NSString* firstRow = [csvArray objectAtIndex:0];
    int maxCols = [[firstRow componentsSeparatedByString:@","] count];
    cv::Mat csvMat(maxRows, maxCols, CV_32F);
    
    for (int i = 0; i < [csvArray count]; i++) {
        NSString* items = [csvArray objectAtIndex:i];
        NSArray* splitRow = [items componentsSeparatedByString:@","];
        col = 0;
        for (int j = 0; j < [splitRow count]; j++) {
            NSString* item = [splitRow objectAtIndex:j];
            csvMat.at<float>(row, col) = [item floatValue];
            col++;
        }
        row++;
    }
    
    return csvMat;
}

/*
+ (void) storeScores: (NSMutableArray*) scores withCentroids:(NSMutableArray*) centroids {
    CSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject* newScoresAndCentroids;
    
    newScoresAndCentroids = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ScoresAndCentroids"
                             inManagedObjectContext:context];
    
    NSData* scoresData = [NSKeyedArchiver archivedDataWithRootObject:scores];
    NSData* centroidsData = [NSKeyedArchiver archivedDataWithRootObject:centroids];

    [newScoresAndCentroids setValue:scoresData forKey:@"scores"];
    [newScoresAndCentroids setValue:centroidsData forKey:@"centroids"];
    
    NSError *error;
    [context save:&error];
}
*/

+ (NSString*) tknKeyHelper: (NSString*) str {
    return [[str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];
}


+ (NSString*) tknValHelper: (NSString*) str {
    return [[str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:1];
}

+ (int*) tknIntArrayHelper: (NSString*) str {
    NSArray* components = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int len = [components count] - 1;
    int* arr = new int[len * sizeof(int)];
    for (int i = 0; i < len; i++) {
        arr[i] = [[components objectAtIndex:i] intValue];
    }
    return arr;
}


+ (double*) tknDoubleArrayHelper: (NSString*) str {
    NSArray* components = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int len = [components count] - 1;
    double* arr = new double[len * sizeof(double)];
    for (int i = 0; i < len; i++) {
        arr[i] = [[components objectAtIndex:i] doubleValue];
    }
    return arr;
}

+ (svm_model*) loadSVMModelWithPathName: (NSString*) fileName {

    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    const char* fpath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    svm_model* model = svm_load_model(fpath); 
    return model;
}

@end
