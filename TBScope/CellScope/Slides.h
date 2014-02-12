//
//  Slides.h
//  TBScope
//
//  Created by Frankie Myers on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images, SlideAnalysisResults;

@interface Slides : NSManagedObject

@property (nonatomic) NSTimeInterval datePrepared;
@property (nonatomic, retain) NSString * gpsLocation;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * patientAddress;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic) int32_t readNumber;
@property (nonatomic) int32_t slideNumber;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) SlideAnalysisResults *slideAnalysisResults;
@property (nonatomic, retain) NSSet *slideImages;
@end

@interface Slides (CoreDataGeneratedAccessors)

- (void)addSlideImagesObject:(Images *)value;
- (void)removeSlideImagesObject:(Images *)value;
- (void)addSlideImages:(NSSet *)values;
- (void)removeSlideImages:(NSSet *)values;

@end
