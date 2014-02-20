//
//  CSUserContext.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "CSUserContext.h"

@implementation CSUserContext

@synthesize username;

- (id)initWithUsername:(NSString*)uname
{
    self.username = uname;
    self.sharing = @"Camera Roll";
    return self;
}

@end
