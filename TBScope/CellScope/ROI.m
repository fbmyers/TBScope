//
//  ROI.m
//  CellScope
//
//  Created by Frankie Myers on 11/4/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ROI.h"

@implementation ROI

@synthesize x,y,score;


+ (id)makeROIWithScore:(float)score X:(int)x Y:(int)y
{
    return [[self alloc] initWithScore:score
                                     X:x
                                     Y:y];
}

- (id)initWithScore:(float)newScore X:(int)newX Y:(int)newY
{
    self = [super init];
    self.score = newScore;
    self.x = newX;
    self.y = newY;
    
    return self;
}



@end
