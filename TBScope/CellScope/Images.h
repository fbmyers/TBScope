//
//  Images.h
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageAnalysisResults, Slides;

@interface Images : NSManagedObject

@property (nonatomic) int32_t fieldNumber;
@property (nonatomic, retain) NSString * metadata;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * googleDriveFileID;
@property (nonatomic, retain) ImageAnalysisResults *imageAnalysisResults;
@property (nonatomic, retain) Slides *slide;

@end
