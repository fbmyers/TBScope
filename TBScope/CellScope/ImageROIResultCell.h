//
//  ImageROIResultCell.h
//  TBScope
//
//  Created by Frankie Myers on 4/10/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Represents a single cell in the "grid view" which displays only the ROIs associated with an exam

#import <UIKit/UIKit.h>
#import "TBScopeData.h"

@interface ImageROIResultCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong,nonatomic) ROIs* currentROI;


@end
