//
//  TBScopeData.m
//  TBScope
//
//  Created by Frankie Myers on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBScopeData.h"

@implementation TBScopeData

+ (id)sharedData {
    static TBScopeData *newData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newData = [[self alloc] init];
    });
    return newData;
}

- (id)init {
    if (self = [super init]) {
        
        
    }
    return self;
}


- (void) saveCoreData
{
    NSError *error;
    if (![self.managedObjectContext save:&error])
    NSLog(@"Failed to commit to core data: %@", [error domain]);
}

@end
