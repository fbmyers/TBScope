//
//  ImageROIResultViewController.h
//  TBScope
//
//  Created by Frankie Myers on 4/10/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  The collection view that generates the grid-style ROI viewer which displays only the bright patches of the images in an exam. This is used to quickly diagnose TB manually and to generate training set data.

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "ImageROIResultCell.h"

#define NEIGHBORHOOD_SIZE 200

@interface ImageROIResultView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong,nonatomic) UIImageView* roiNeighborhoodView;

@property (strong,nonatomic) Slides* currentSlide;
@property (strong,nonatomic) NSArray* ROIList;

@property (nonatomic) float redThreshold;
@property (nonatomic) float yellowThreshold;
@property (nonatomic) BOOL boxesVisible;
@property (nonatomic) BOOL selectionVisible;
@property (nonatomic) BOOL scoresVisible;

@property (nonatomic) float scale;
@property (nonatomic) BOOL hasChanges;

- (void) setSlide:(Slides*)slide;

@end
