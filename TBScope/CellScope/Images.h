//
//  Images.h
//  TBScope
//
//  Created by Frankie Myers on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageAnalysisResults;

@interface Images : NSManagedObject

@property (nonatomic) int32_t fieldNumber;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * metadata;
@property (nonatomic, retain) ImageAnalysisResults *imageAnalysisResults;

@end
