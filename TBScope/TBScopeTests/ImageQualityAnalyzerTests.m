//
//  ImageQualityAnalyzerTests.m
//  TBScope
//
//  Created by Jason Ardell on 10/1/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "TBScopeCamera.h"
#import "ImageQualityAnalyzer.h"

@interface ImageQualityAnalyzerTests : XCTestCase
@end

@implementation ImageQualityAnalyzerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatFocusedBrightfieldImageIsSharperThanBlurryBrightfield {
    ImageQuality focusedIQ = [self _imageQualityForImageNamed:@"bf_focused"];
    ImageQuality blurryIQ = [self _imageQualityForImageNamed:@"bf_blurry"];

    // Expect bf_focused_sharpness > bf_blurry_sharpness
    XCTAssert(focusedIQ.tenengrad3 > blurryIQ.tenengrad3);
}

- (void)testThatFocusedFluorescenceImageHasHigherContrastThanBluryFluorescence {
    ImageQuality focusedIQ = [self _imageQualityForImageNamed:@"fl_focused"];
    ImageQuality blurryIQ = [self _imageQualityForImageNamed:@"fl_blurry"];
    
    // Expect fl_focused contrast > fl_blurry contrast
    XCTAssert(focusedIQ.contrast > blurryIQ.contrast);
}

#pragma helper methods

- (ImageQuality)_imageQualityForImageNamed:(NSString *)imageName {
    // Load up UIImage
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:imageName ofType:@"jpg"];
    UIImage *uiImage = [UIImage imageWithContentsOfFile:filePath];

    // Convert UIImage to an IplImage
    IplImage *iplImage = [[self class] createIplImageFromUIImage:uiImage];
    ImageQuality iq = [ImageQualityAnalyzer calculateFocusMetricFromIplImage:iplImage];

    // Release an nullify iplImage
    // cvReleaseImage(&iplImage);  // Not sure why this line crashes
    iplImage = nil;

    return iq;
}

+ (IplImage *)createIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplImage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplImage->imageData, iplImage->width, iplImage->height,
                                                    iplImage->depth, iplImage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplImage);
    
    return ret;
}

@end
