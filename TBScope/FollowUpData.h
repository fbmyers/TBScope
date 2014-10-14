//
//  FollowUpData.h
//  TBScope
//
//  Created by Frankie Myers on 10/9/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exams;

@interface FollowUpData : NSManagedObject

@property (nonatomic, retain) NSString * slide1ZNResult;
@property (nonatomic, retain) NSString * slide2ZNResult;
@property (nonatomic, retain) NSString * slide3ZNResult;
@property (nonatomic, retain) NSString * xpertMTBResult;
@property (nonatomic, retain) NSString * xpertRIFResult;
@property (nonatomic, retain) NSString * cultureResult;
@property (nonatomic, retain) NSString * qcStatus;
@property (nonatomic, retain) Exams *exam;

@end
