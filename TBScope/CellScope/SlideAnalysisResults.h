//
//  SlideAnalysisResults.h
//  TBScope
//
//  Created by Frankie Myers on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SlideAnalysisResults : NSManagedObject

@property (nonatomic) NSTimeInterval dateDiagnosed;
@property (nonatomic, retain) NSString * diagnosis;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic) int32_t numPositive;
@property (nonatomic) float score;

@end
