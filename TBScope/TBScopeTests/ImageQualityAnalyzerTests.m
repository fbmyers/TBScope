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

- (void)testThatFocusedFluorescenceImagesHaveHigherContrastThanBluryFluorescence {
    // Image set 01
    NSDecimalNumber *fl_01_01 = [self _contrastForImageNamed:@"fl_01_01"];
    NSDecimalNumber *fl_01_02 = [self _contrastForImageNamed:@"fl_01_02"];
    NSDecimalNumber *fl_01_03 = [self _contrastForImageNamed:@"fl_01_03"];
    NSDecimalNumber *fl_01_04 = [self _contrastForImageNamed:@"fl_01_04"];
    NSDecimalNumber *fl_01_05 = [self _contrastForImageNamed:@"fl_01_05"];
    
    // Image set 02
    NSDecimalNumber *fl_02_01 = [self _contrastForImageNamed:@"fl_02_01"];
    NSDecimalNumber *fl_02_02 = [self _contrastForImageNamed:@"fl_02_02"];
    NSDecimalNumber *fl_02_03 = [self _contrastForImageNamed:@"fl_02_03"];
    NSDecimalNumber *fl_02_04 = [self _contrastForImageNamed:@"fl_02_04"];
    NSDecimalNumber *fl_02_05 = [self _contrastForImageNamed:@"fl_02_05"];
    
    // Image set 03
    NSDecimalNumber *fl_03_01 = [self _contrastForImageNamed:@"fl_03_01"];
    NSDecimalNumber *fl_03_02 = [self _contrastForImageNamed:@"fl_03_02"];
    NSDecimalNumber *fl_03_03 = [self _contrastForImageNamed:@"fl_03_03"];
    NSDecimalNumber *fl_03_04 = [self _contrastForImageNamed:@"fl_03_04"];
    NSDecimalNumber *fl_03_05 = [self _contrastForImageNamed:@"fl_03_05"];
    
    // Image set 04
    NSDecimalNumber *fl_04_01 = [self _contrastForImageNamed:@"fl_04_01"];
    NSDecimalNumber *fl_04_02 = [self _contrastForImageNamed:@"fl_04_02"];
    NSDecimalNumber *fl_04_03 = [self _contrastForImageNamed:@"fl_04_03"];
    NSDecimalNumber *fl_04_04 = [self _contrastForImageNamed:@"fl_04_04"];
    NSDecimalNumber *fl_04_05 = [self _contrastForImageNamed:@"fl_04_05"];
    
    NSArray *testCases = @[
        // Sharper image        Blurrier image
        @[ fl_01_01,            fl_01_02        ],
        @[ fl_01_02,            fl_01_03        ],
        @[ fl_01_03,            fl_01_04        ],
        @[ fl_01_04,            fl_01_05        ],
        @[ fl_02_01,            fl_02_02        ],
        @[ fl_02_02,            fl_02_03        ],
        @[ fl_02_03,            fl_02_04        ],
        @[ fl_02_04,            fl_02_05        ],
        @[ fl_03_01,            fl_03_02        ],
        @[ fl_03_02,            fl_03_03        ],
        @[ fl_03_03,            fl_03_04        ],
        @[ fl_03_04,            fl_03_05        ],
        @[ fl_04_01,            fl_04_02        ],
        @[ fl_04_02,            fl_04_03        ],
        @[ fl_04_03,            fl_04_04        ],
        @[ fl_04_04,            fl_04_05        ],
    ];
    for (NSArray *testCase in testCases) {
        NSDecimalNumber *sharperContrast = testCase[0];
        NSDecimalNumber *blurrierContrast = testCase[1];
        XCTAssertGreaterThan([sharperContrast doubleValue], [blurrierContrast doubleValue]);
    }
}

#pragma helper methods

- (NSDecimalNumber *)_contrastForImageNamed:(NSString *)imageName {
    ImageQuality imageQuality =[self _imageQualityForImageNamed:imageName];
    double contrast = imageQuality.greenContrast;
    NSLog(@"Image %@ has greenContrast %3.3f", imageName, contrast);
    return [[NSDecimalNumber alloc] initWithDouble:contrast];
}

- (ImageQuality)_imageQualityForImageNamed:(NSString *)imageName {
    // Load up UIImage
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:imageName ofType:@"jpg"];
    UIImage *uiImage = [UIImage imageWithContentsOfFile:filePath];

    // Convert UIImage to an IplImage
    IplImage *iplImage = [[self class] createIplImageFromUIImage:uiImage];
    ImageQuality iq = [ImageQualityAnalyzer calculateFocusMetricFromIplImage:iplImage];

    // Release an nullify iplImage
    // cvReleaseImage(&iplImage);  // not sure why this crashes
    iplImage = NULL;

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
    IplImage *converted = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, converted, CV_RGBA2BGR);
    cvReleaseImage(&iplImage);

    // Crop IplImage
    int cropDim = 250;  // see ImageQualityAnalyzer::CROP_WINDOW_SIZE
    IplImage *cropped = 0;
    cvSetImageROI(converted, cvRect(converted->width/2-(cropDim/2), converted->height/2-(cropDim/2), cropDim, cropDim));
    cropped = cvCreateImage(cvGetSize(converted),
                            converted->depth,
                            converted->nChannels);
    cvCopy(converted, cropped, NULL);
    cvReleaseImage(&converted);
    
    return cropped;
}

@end
