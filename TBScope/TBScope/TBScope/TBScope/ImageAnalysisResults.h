//
//  ImageAnalysisResults.h
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images, ROIs;

@interface ImageAnalysisResults : NSManagedObject

@property (nonatomic) NSTimeInterval dateAnalyzed;
@property (nonatomic) BOOL diagnosis;
@property (nonatomic) int32_t numPositive;
@property (nonatomic) float score;
@property (nonatomic, retain) Images *image;
@property (nonatomic, retain) NSOrderedSet *imageROIs;
@end

@interface ImageAnalysisResults (CoreDataGeneratedAccessors)

- (void)insertObject:(ROIs *)value inImageROIsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImageROIsAtIndex:(NSUInteger)idx;
- (void)insertImageROIs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImageROIsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImageROIsAtIndex:(NSUInteger)idx withObject:(ROIs *)value;
- (void)replaceImageROIsAtIndexes:(NSIndexSet *)indexes withImageROIs:(NSArray *)values;
- (void)addImageROIsObject:(ROIs *)value;
- (void)removeImageROIsObject:(ROIs *)value;
- (void)addImageROIs:(NSOrderedSet *)values;
- (void)removeImageROIs:(NSOrderedSet *)values;
@end
