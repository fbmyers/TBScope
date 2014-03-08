//
//  SlideAnalysisResults.h
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slides;

@interface SlideAnalysisResults : NSManagedObject

@property (nonatomic, retain) NSString * dateDiagnosed;
@property (nonatomic, retain) NSString * diagnosis;
@property (nonatomic) int32_t numAFBAlgorithm;
@property (nonatomic) int32_t numAFBManual;
@property (nonatomic) float score;
@property (nonatomic, retain) Slides *slide;

@end
