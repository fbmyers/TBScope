//
//  ImageAnalysisResults.h
//  TBScope
//
//  Created by Frankie Myers on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ROIs;

@interface ImageAnalysisResults : NSManagedObject

@property (nonatomic) NSTimeInterval dateAnalyzed;
@property (nonatomic) int32_t numPositive;
@property (nonatomic) float score;
@property (nonatomic) BOOL diagnosis;
@property (nonatomic, retain) NSSet *imageROIs;
@end

@interface ImageAnalysisResults (CoreDataGeneratedAccessors)

- (void)addImageROIsObject:(ROIs *)value;
- (void)removeImageROIsObject:(ROIs *)value;
- (void)addImageROIs:(NSSet *)values;
- (void)removeImageROIs:(NSSet *)values;

@end
