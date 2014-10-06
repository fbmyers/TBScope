//
//  ImageROIResultViewController.m
//  TBScope
//
//  Created by Frankie Myers on 4/10/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ImageROIResultView.h"
#import "ImageQualityAnalyzer.h"

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
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self addGestureRecognizer:pinch];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLongPressGesture:)];
    longpress.minimumPressDuration = .5; //seconds
    [self addGestureRecognizer:longpress];
    
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

-(void)didReceiveLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint p = [gestureRecognizer locationInView:self];
        float neighborhoodX = 300;
        float neighborhoodY = 300;
        if (p.x<512)
            neighborhoodX = 750;
        
        
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:p];;
        if (indexPath != nil) {
            // get the cell at indexPath (the one you long pressed)
            ImageROIResultCell* cell = [self cellForItemAtIndexPath:indexPath];
            // do stuff with the cell
            //cell.currentROI.x;
            
            Images* roiImage = (Images*)cell.currentROI.imageAnalysisResult.image;
            int x = cell.currentROI.x;
            int y = cell.currentROI.y;
            
            [TBScopeData getImage:roiImage resultBlock:^(UIImage* image, NSError* err){
                if (err==nil)
                {
                    CGRect bounds = CGRectMake(x-NEIGHBORHOOD_SIZE/2,y-NEIGHBORHOOD_SIZE/2,NEIGHBORHOOD_SIZE,NEIGHBORHOOD_SIZE);
                    
                    //get a cropped version of the vicinity around this ROI
                    UIImage* roiNeighborhood = [ImageQualityAnalyzer cropImage:image withBounds:bounds];
                    
                    //display image
                    //place image view on left/right side if gesture is on the right/left side
                    //image view should be 2x scaled
                    if (self.roiNeighborhoodView!=nil)
                    {
                        [self.roiNeighborhoodView removeFromSuperview];
                        self.roiNeighborhoodView = nil;
                    }
                    
                    self.roiNeighborhoodView = [[UIImageView alloc] initWithImage:roiNeighborhood];
                    [self.roiNeighborhoodView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0)];
                    [self.roiNeighborhoodView setCenter:CGPointMake(neighborhoodX,neighborhoodY)];
                    
                    [self.superview addSubview:self.roiNeighborhoodView];
                    
                }
            }];
            
            
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)//gesture ended
    {
        [self.roiNeighborhoodView removeFromSuperview];
        self.roiNeighborhoodView = nil;
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
