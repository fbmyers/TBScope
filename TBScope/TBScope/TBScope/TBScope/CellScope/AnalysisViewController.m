//
//  AnalysisViewController.m
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "AnalysisViewController.h"

@implementation AnalysisViewController


@synthesize managedObjectContext,currentUser,currentSlide,progress,spinner;

//@synthesize imagePath;


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analysisCompleteCallback) name:@"AnalysisComplete" object:nil];
	
    diagnoser = [[TBDiagnoser alloc] init];
    diagnoser.managedObjectContext = self.managedObjectContext;
    
    
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
        [self.managedObjectContext deleteObject:self.currentSlide.slideAnalysisResults];
        

    }
    
    for (Images* im in self.currentSlide.slideImages)
    {
        if (im.imageAnalysisResults!=nil)
        {
            NSLog(@"deleting old image results");
            [self.managedObjectContext deleteObject:im.imageAnalysisResults];
        }
    }
    
    // Commit
    [self.managedObjectContext save:nil];
    
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
    int numFields = self.currentSlide.slideImages.count;
    
    NSLog(@"loading image %d of %d",fieldNumber+1,numFields);
    self.analysisLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Processing image %d of %d...",nil),fieldNumber+1,numFields];
    self.progress.progress = (float)fieldNumber/(float)numFields;
    
    //TODO: put in a loop to handle multiple images
    Images* currentImage = (Images*)[[self.currentSlide slideImages] objectAtIndex:fieldNumber];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RunWithExampleTBImage"])
    {
        currentImage.path = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExampleTBImageURL"];
    }
    
    NSLog(@"analyzing image at path = %@",currentImage.path);
    
    //TODO: spin out analysis to separate thread and add spinny thing and progress bar
    //TODO: handle back button (cancel analysis) and have it say "Cancel"
    
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
                 
                 // Commit to core data
                 NSError *error;
                 if (![self.managedObjectContext save:&error])
                     NSLog(@"Failed to commit to core data: %@", [error description]);
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
            NSError *error;
            if (![self.managedObjectContext save:&error])
                NSLog(@"Failed to commit to core data: %@", [error description]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysisComplete" object:nil];
        });

    }
    
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
        SlideAnalysisResults* slideResults = (SlideAnalysisResults*)[NSEntityDescription insertNewObjectForEntityForName:@"SlideAnalysisResults" inManagedObjectContext:self.managedObjectContext];
        
        Images* im;
        NSMutableSet* allROIs = [[NSMutableSet alloc] init];
        int numPositive = 0;
        float slideScore = 0;
        
        for (im in self.currentSlide.slideImages)
        {
            [allROIs addObjectsFromArray:[im.imageAnalysisResults.imageROIs array]];
            numPositive += im.imageAnalysisResults.numPositive;
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
        
        NSLog([sortedROIs description]);
        NSLog(@"slide score: %f",slideScore);
        
        slideResults.dateDiagnosed = [NSDate timeIntervalSinceReferenceDate];
        slideResults.numPositive = numPositive;
        slideResults.score = slideScore;
        if (slideScore>[[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"])
        {
            slideResults.diagnosis = @"POSITIVE";
        }
        else
        {
            slideResults.diagnosis = @"NEGATIVE";
        }
        
        currentSlide.slideAnalysisResults = slideResults;
        
        NSLog(@"analysis complete");
        
        // Commit to core data
        NSError *error;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Failed to commit to core data: %@", [error description]);
        
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
