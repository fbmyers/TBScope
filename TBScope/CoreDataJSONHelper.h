//
//  CoreDataJSONHelper.h
//  TBScope
//
//  Created by Frankie Myers on 4/4/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBScopeData.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@interface CoreDataJSONHelper : NSObject


+ (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
+ (NSArray*)managedObjectsFromJSONStructure:(NSData*)json withManagedObjectContext:(NSManagedObjectContext*)moc error:(NSError**)error;


@end
