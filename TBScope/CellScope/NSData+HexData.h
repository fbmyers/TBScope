//
//  NSData+HexData.h
//  TBScope
//
//  Created by Frankie Myers on 4/15/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexData)

+ (NSData *)dataFromHexString:(NSString *)string;

- (NSString*)hexStringRepresentation;

@end
