//
//  TBScopeViewControllerContext.h
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBScopeData.h"

@protocol TBScopeViewControllerContext <NSObject>


@property (strong,nonatomic) Slides* currentSlide;
@property (strong,nonatomic) Exams* currentExam;

@end
