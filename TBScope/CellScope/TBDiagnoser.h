//
//  TBDiagnoser.h
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBScopeData.h"


@interface TBDiagnoser : NSObject

- (ImageAnalysisResults*) runWithImage: (UIImage*)img;


@end
