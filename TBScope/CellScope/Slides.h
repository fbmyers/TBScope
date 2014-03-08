//
//  Slides.h
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exams, Images, SlideAnalysisResults;

@interface Slides : NSManagedObject

@property (nonatomic) int32_t slideNumber;
@property (nonatomic, retain) NSString * sputumQuality;
@property (nonatomic, retain) NSString * dateCollected;
@property (nonatomic, retain) NSString * dateScanned;
@property (nonatomic, retain) SlideAnalysisResults *slideAnalysisResults;
@property (nonatomic, retain) NSOrderedSet *slideImages;
@property (nonatomic, retain) Exams *exam;
@end

@interface Slides (CoreDataGeneratedAccessors)

- (void)insertObject:(Images *)value inSlideImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSlideImagesAtIndex:(NSUInteger)idx;
- (void)insertSlideImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSlideImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSlideImagesAtIndex:(NSUInteger)idx withObject:(Images *)value;
- (void)replaceSlideImagesAtIndexes:(NSIndexSet *)indexes withSlideImages:(NSArray *)values;
- (void)addSlideImagesObject:(Images *)value;
- (void)removeSlideImagesObject:(Images *)value;
- (void)addSlideImages:(NSOrderedSet *)values;
- (void)removeSlideImages:(NSOrderedSet *)values;
@end
