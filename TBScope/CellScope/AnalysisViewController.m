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


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analysisCompleteCallback) name:@"AnalysisComplete" object:nil];
	
    diagnoser = [[TBDiagnoser alloc] init]; //TODO: use delegate instead
   
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = NSLocalizedString(@"Analyzing...", nil);
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Abort", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (self.currentSlide.slideAnalysisResults!=nil) {
        NSLog(@"deleting old slide results");
        [[[TBScopeData sharedData] managedObjectContext] deleteObject:self.currentSlide.slideAnalysisResults];
        

    }
    
    for (Images* im in self.currentSlide.slideImages)
    {
        if (im.imageAnalysisResults!=nil)
        {
            NSLog(@"deleting old image results");
            [[[TBScopeData sharedData] managedObjectContext] deleteObject:im.imageAnalysisResults];
        }
    }
    
    // Commit
    [TBScopeData touchExam:self.currentExam];
    [[TBScopeData sharedData] saveCoreData];
    
    self.currentField = 0;
    [self analyzeField:self.currentField]; //begin by analyzing the 0th field.
    
    
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

- (void)analyzeField:(int)fieldNumber
{
    int numFields = (int)self.currentSlide.slideImages.count;
    
    self.analysisLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Processing image %d of %d...",nil),fieldNumber+1,numFields];
    self.progress.progress = (float)fieldNumber/(float)numFields;
    
    Images* currentImage = (Images*)[[self.currentSlide slideImages] objectAtIndex:fieldNumber];
    
    //TODO: remove
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RunWithExampleTBImage"])
    {
        currentImage.path = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExampleTBImageURL"];
    }
    
    [TBScopeData CSLog:[NSString stringWithFormat:@"Analyzing image %d-%d from exam %@ with path %@",
                        self.currentSlide.slideNumber,
                        fieldNumber+1,
                        self.currentSlide.exam.examID,
                        currentImage.path]
            inCategory:@"ANALYSIS"];
    
    
    //TODO: spin out analysis to separate thread and add spinny thing and progress bar
    //TODO: handle back button (cancel analysis) and have it say "Cancel"
    
    [TBScopeData getImage:currentImage resultBlock:^(UIImage* image, NSError* err){
        
        if (err==nil) {
            //do analysis on this image
            currentImage.imageAnalysisResults = [diagnoser runWithImage:(image)]; //todo: spin out as new thread
            
            [TBScopeData touchExam:self.currentExam];
            [[TBScopeData sharedData] saveCoreData];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysisComplete" object:nil];
        
    }];
    
    /*
    NSURL *aURL = [NSURL URLWithString:currentImage.path]; //TODO: check that this is a valid url to an image (see example code on stackoverflow)

    if ([[aURL scheme] isEqualToString:@"assets-library"])
    {
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {

             if (asset==nil)
                 NSLog(@"Could not load image for analysis");
             else
             {
                 //load the image
                 ALAssetRepresentation* rep = [asset defaultRepresentation];
                 CGImageRef iref = [rep fullResolutionImage];
                 UIImage* imageColor = [UIImage imageWithCGImage:iref];
                 
                 //this isn't necessary
                 //UIImage* imageBW = [self convertImageToGrayScale:imageColor];
                 //imageColor = nil;
                 
                 rep = nil;
                 iref = nil;
                 
                 //do analysis on this image
                 currentImage.imageAnalysisResults = [diagnoser runWithImage:(imageColor)]; //todo: spin out as new thread
                
                 [TBScopeData touchExam:self.currentExam];
                 [[TBScopeData sharedData] saveCoreData];
             }
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysisComplete" object:nil];
             
         }
                failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"failure loading image");
         }];
    }
    else //this is a file in the bundle
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            UIImage* image = [UIImage imageNamed:currentImage.path];
            currentImage.imageAnalysisResults = [diagnoser runWithImage:(image)]; //spin out as new thread

            // Commit to core data
            [[TBScopeData sharedData] saveCoreData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysisComplete" object:nil];
        });

    }
    */
    
}

- (void)analysisCompleteCallback
{
    self.currentField++;
    
    if (self.currentField<self.currentSlide.slideImages.count)
    {
        [self analyzeField:self.currentField];
    }
    else
    {
        //TODO: do the slide-level diagnosis
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
        
        [self performSegueWithIdentifier:@"ResultsSegue" sender:nil];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ResultsSegue"]) {
        ResultsTabBarController *rtbc = (ResultsTabBarController*)[segue destinationViewController];
        rtbc.currentExam = self.currentSlide.exam;
        [rtbc.navigationItem setHidesBackButton:YES];
        
    }
}

@end
