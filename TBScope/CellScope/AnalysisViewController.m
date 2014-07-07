//
//  AnalysisViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "AnalysisViewController.h"

@implementation AnalysisViewController


@synthesize currentSlide,progress,spinner;

//@synthesize imagePath;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //localization
    self.navigationItem.title = NSLocalizedString(@"Analyzing...", nil);
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Abort", nil);
    self.analysisLabel.text = NSLocalizedString(@"Please wait...",nil);
    [self.navigationItem setHidesBackButton:YES];
    
    //disable syncing
    [[GoogleDriveSync sharedGDS] setSyncEnabled:NO];

    //delete old results
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.currentSlide.slideAnalysisResults!=nil) {
            [TBScopeData CSLog:@"Deleting old slide results." inCategory:@"ANALYSIS"];
            [[[TBScopeData sharedData] managedObjectContext] deleteObject:self.currentSlide.slideAnalysisResults];
            
            
        }
        for (Images* im in self.currentSlide.slideImages)
            if (im.imageAnalysisResults!=nil)
                [[[TBScopeData sharedData] managedObjectContext] deleteObject:im.imageAnalysisResults];
        [TBScopeData touchExam:self.currentExam];
        [[TBScopeData sharedData] saveCoreData];
        
        //start analysis
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analysisCompleteCallback) name:@"AnalysisComplete" object:nil];
        diagnoser = [[TBDiagnoser alloc] init]; //TODO: use delegate instead
        self.hasAborted = NO;
        self.currentField = 0;
        [self analyzeField:0]; //begin by analyzing the 0th field.
    });
    //TODO: multithreading?
}

- (IBAction)didPressAbort:(id)sender
{
    //the user pressed abort
    //[[[TBScopeData sharedData] managedObjectContext] rollback];
    [TBScopeData CSLog:@"Analysis aborted by user." inCategory:@"USER"];
    self.hasAborted = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[GoogleDriveSync sharedGDS] setSyncEnabled:YES];
    //any additional cleanup code?
    
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

//could play with a few ways of multithreading this...use a FIFO queue and fire all of them at once? analysisComplete simply checks that all have finished
- (void)analyzeField:(int)fieldNumber
{
    int numFields = (int)self.currentSlide.slideImages.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.analysisLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Processing image %d of %d...",nil),fieldNumber+1,numFields];
        self.progress.progress = (float)fieldNumber/(float)numFields;
    });
    
    //(try main queue for now)
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        Images* currentImage = (Images*)[[self.currentSlide slideImages] objectAtIndex:fieldNumber];
        
        [TBScopeData CSLog:[NSString stringWithFormat:@"Analyzing image %d-%d from exam %@ with path %@",
                            self.currentSlide.slideNumber,
                            fieldNumber+1,
                            self.currentSlide.exam.examID,
                            currentImage.path]
                inCategory:@"ANALYSIS"];
        
                
        [TBScopeData getImage:currentImage resultBlock:^(UIImage* image, NSError* err){
            
            if (err==nil) {
                //do analysis on this image
                
                currentImage.imageAnalysisResults = [diagnoser runWithImage:(image)]; //todo: spin out as new thread

                [TBScopeData touchExam:self.currentExam];
                [[TBScopeData sharedData] saveCoreData];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysisComplete" object:nil];
            
        }];
        
    });
    
}

- (void)didReceiveMemoryWarning
{
    [TBScopeData CSLog:@"AnalysisViewController received memory warning" inCategory:@"MEMORY"];
}

- (void)analysisCompleteCallback
{
    if (self.hasAborted) {
        return;
    }
    
    self.currentField++;
    
    if (self.currentField<self.currentSlide.slideImages.count)
    {
        [self analyzeField:self.currentField];
    }
    else
    {
        //do the slide-level diagnosis
        SlideAnalysisResults* slideResults = (SlideAnalysisResults*)[NSEntityDescription insertNewObjectForEntityForName:@"SlideAnalysisResults" inManagedObjectContext:[[TBScopeData sharedData] managedObjectContext]];
        
        Images* im;
        NSMutableSet* allROIs = [[NSMutableSet alloc] init];
        int numPositive = 0;
        float slideScore = 0;
        
        for (im in self.currentSlide.slideImages)
        {
            [allROIs addObjectsFromArray:[im.imageAnalysisResults.imageROIs array]];
            numPositive += im.imageAnalysisResults.numAFBAlgorithm;
        }
        
        NSArray *sortedROIs = [[allROIs allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
        
        for (int i=0;i<[[NSUserDefaults standardUserDefaults] integerForKey:@"NumPatchesToAverage"];i++)
        {
            if (sortedROIs.count>i)
            {
                slideScore += [(ROI*)[sortedROIs objectAtIndex:i] score];
                NSLog(@"top score %d: %f",i,[(ROI*)[sortedROIs objectAtIndex:i] score]);
            }
            else
                slideScore += 0;
            
        }
        slideScore /= [[NSUserDefaults standardUserDefaults] integerForKey:@"NumPatchesToAverage"];
        
        slideResults.dateDiagnosed = [TBScopeData stringFromDate:[NSDate date]];
        slideResults.numAFBAlgorithm = numPositive;
        slideResults.score = slideScore;
        slideResults.numAFBManual = 0;
        if (slideScore>[[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"])
        {
            slideResults.diagnosis = @"POSITIVE";
        }
        else
        {
            slideResults.diagnosis = @"NEGATIVE";
        }
        //TODO: WHAT ABOUT INDETERMINATE?
        
        currentSlide.slideAnalysisResults = slideResults;

        [TBScopeData CSLog:[NSString stringWithFormat:@"Slide-level analysis complete with score: %f",slideScore]
                inCategory:@"ANALYSIS"];
        
        [TBScopeData touchExam:self.currentSlide.exam];
        [[TBScopeData sharedData] saveCoreData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ResultsSegue" sender:nil];
        });

    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ResultsSegue"]) {
        ResultsTabBarController *rtbc = (ResultsTabBarController*)[segue destinationViewController];
        rtbc.currentExam = self.currentSlide.exam;
        [rtbc.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:rtbc.doneButton]];
        [rtbc.navigationItem setHidesBackButton:YES];
        
    }
}

@end
