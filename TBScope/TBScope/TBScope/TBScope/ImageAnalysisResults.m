//
//  ImageAnalysisResults.m
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ImageAnalysisResults.h"
#import "Images.h"
#import "ROIs.h"


@implementation ImageAnalysisResults

@dynamic dateAnalyzed;
@dynamic diagnosis;
@dynamic numPositive;
@dynamic score;
@dynamic image;
@dynamic imageROIs;

- (void)addImageROIsObject:(ROIs *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.imageROIs];
    [tempSet addObject:value];
    self.imageROIs = tempSet;
}

@end
