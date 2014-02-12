//
//  AnalysisViewController.h
//  CellScope
//
//  Created by Frankie Myers on 11/1/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TBScopeViewControllerContext.h"
#import "TBDiagnoser.h"
#import "ResultsTabBarController.h"
#import "Users.h"
#import "Slides.h"
#import "Images.h"

//Q: what is this?
@class CSUserContext;

//TODO: if this protocol technique works, have all the VCs implement it and don't worry about getting explicit references
@interface AnalysisViewController : UIViewController <TBScopeViewControllerContext>
{
    TBDiagnoser* diagnoser;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong,nonatomic) Slides* currentSlide;

@property (weak, nonatomic) IBOutlet UIProgressView* progress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;
@property (weak, nonatomic) IBOutlet UILabel *analysisLabel;

@property (nonatomic) int currentField;

- (void)analyzeField:(int)fieldNumber;
- (void) analysisCompleteCallback;


- (UIImage *)convertImageToGrayScale:(UIImage *)image;

@end
