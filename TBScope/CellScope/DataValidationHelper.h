//
//  DataValidationHelper.h
//  TBScope
//
//  Created by Frankie Myers on 11/22/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataValidationHelper : NSObject

+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern;

@end
