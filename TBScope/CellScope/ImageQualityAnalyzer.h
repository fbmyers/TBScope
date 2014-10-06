//
//  ImageQualityAnalyzer.h
//  TBScope
//
//  Created by Frankie Myers on 6/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cv.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef struct
    {
        double normalizedGraylevelVariance;
        double varianceOfLaplacian;
        double modifiedLaplacian;
        double tenengrad1;
        double tenengrad3;
        double tenengrad9;
        double movingAverageSharpness;
        double movingAverageContrast;
        double entropy;
        double maxVal;
        double contrast;
    } ImageQuality;

@interface ImageQualityAnalyzer : NSObject

+ (ImageQuality) calculateFocusMetric:(CMSampleBufferRef)sampleBuffer;

+ (UIImage*) maskCircleFromImage:(UIImage*)inputImage;

+ (UIImage *)cropImage:(UIImage*)image withBounds:(CGRect)rect;

@end
