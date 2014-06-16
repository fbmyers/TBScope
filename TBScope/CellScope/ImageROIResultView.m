//
//  ImageROIResultViewController.m
//  TBScope
//
//  Created by Frankie Myers on 4/10/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ImageROIResultView.h"


@interface ImageROIResultView ()

@end

@implementation ImageROIResultView

float threshold_score = 1;

- (void) setSlide:(Slides*)slide
{
    self.scale = 1.0; //should go in init?
    self.hasChanges = NO;
    
    
    self.delegate = self;
    self.dataSource = self;
    
    self.allowsSelection = self.selectionVisible;
    self.allowsMultipleSelection = NO;
    
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self addGestureRecognizer:gesture];
    
    self.currentSlide = slide;
    
    
    NSMutableSet* allROIs = [[NSMutableSet alloc] init];
    
    for (Images* im in self.currentSlide.slideImages)
        [allROIs addObjectsFromArray:[im.imageAnalysisResults.imageROIs array]];
    
    self.ROIList = [[allROIs allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
    
}

- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    static CGFloat scaleStart;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = self.scale;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        self.scale = scaleStart * gesture.scale;
        [self.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - UICollectionView Datasource

//return number of images for a given session
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.ROIList.count;
}

//return number of sessions
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

//populate each cell: image thumbnail and title
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageROIResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageROIResultCell" forIndexPath:indexPath];
    
    cell.currentROI = (ROIs*)self.ROIList[indexPath.item];
    

    cell.imageView.image = [UIImage imageWithData:cell.currentROI.image];
    
    if (self.boxesVisible)
    {
        if (cell.currentROI.score>self.redThreshold)
            cell.backgroundColor = [UIColor redColor];
        else if (cell.currentROI.score>self.yellowThreshold)
            cell.backgroundColor = [UIColor yellowColor];
        else
            cell.backgroundColor = [UIColor greenColor];
    }
    else
        cell.backgroundColor = [UIColor lightGrayColor];
    
    if (self.selectionVisible)
        cell.tintView.hidden = !cell.currentROI.userCall;
    else
        cell.tintView.hidden = YES;
    
    [self setCellFontSize:cell];
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageROIResultCell *cell = (ImageROIResultCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    cell.currentROI.userCall = cell.currentROI.userCall?NO:YES;
    if (cell.currentROI.userCall)
        cell.currentROI.imageAnalysisResult.image.slide.slideAnalysisResults.numAFBManual++;
    else
        cell.currentROI.imageAnalysisResult.image.slide.slideAnalysisResults.numAFBManual--;
        
    cell.tintView.hidden = !cell.currentROI.userCall;
 
    self.hasChanges = YES;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //resize the label
    
    ImageROIResultCell *cell = (ImageROIResultCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self setCellFontSize:cell];
    
    return CGSizeMake(50*self.scale, 50*self.scale);
}

- (void)setCellFontSize:(ImageROIResultCell*)cell
{
    if (self.scale>=1.0 && self.scoresVisible)
    {
        cell.scoreLabel.text = [[NSString alloc] initWithFormat:@"%d",(int)round(cell.currentROI.score*100)];
        cell.scoreLabel.font = [cell.scoreLabel.font fontWithSize:(8.0 * self.scale)];
        cell.scoreLabel.hidden = NO;
    }
    else
        cell.scoreLabel.hidden = YES;
}
@end
