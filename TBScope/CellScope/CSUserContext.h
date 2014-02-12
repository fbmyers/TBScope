//
//  CSUserContext.h
//  CellScope
//
//  Created by Matthew Bakalar on 8/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUserContext : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, weak) NSString *sharing;

- (id)initWithUsername:(NSString*)username;

@end
