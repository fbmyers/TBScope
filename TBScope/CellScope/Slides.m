//
//  Slides.m
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Slides.h"
#import "Exams.h"
#import "Images.h"
#import "SlideAnalysisResults.h"


@implementation Slides

@dynamic slideNumber;
@dynamic sputumQuality;
@dynamic dateCollected;
@dynamic dateScanned;
@dynamic slideAnalysisResults;
@dynamic slideImages;
@dynamic exam;

- (void)addSlideImagesObject:(Images *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.slideImages];
    [tempSet addObject:value];
    self.slideImages = tempSet;
}

@end
