//
//  ROIs.h
//  TBScope
//
//  Created by Frankie Myers on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ROIs : NSManagedObject

@property (nonatomic) float score;
@property (nonatomic) int32_t x;
@property (nonatomic) int32_t y;

@end
