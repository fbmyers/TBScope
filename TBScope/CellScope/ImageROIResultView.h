//
//  ImageROIResultViewController.h
//  TBScope
//
//  Created by Frankie Myers on 4/10/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBScopeData.h"
#import "ImageROIResultCell.h"

@interface ImageROIResultView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

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
