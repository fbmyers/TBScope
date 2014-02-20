//
//  ROI.h
//  CellScope
//
//  Created by Frankie Myers on 11/4/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROI : NSObject


@property int x;
@property int y;
@property float score;

+ (id)makeROIWithScore:(float)score X:(int)x Y:(int)y;

- (id)initWithScore:(float)score X:(int)x Y:(int)y;

@end

//TODO: should this include anything else?