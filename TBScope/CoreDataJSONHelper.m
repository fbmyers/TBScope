//
//  CoreDataJSONHelper.m
//  TBScope
//
//  Created by Frankie Myers on 4/4/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CoreDataJSONHelper.h"

@implementation CoreDataJSONHelper



+ (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject
{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
    [valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
    for (NSString *relationshipName in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if ([description deleteRule]!=2) //kind of a hack, but avoids recursive loop
            continue;
        if (![description isToMany]) {
            NSManagedObject *relationshipObject = [managedObject valueForKey:relationshipName];
            if (relationshipObject!=nil)
                [valuesDictionary setObject:[self dataStructureFromManagedObject:relationshipObject] forKey:relationshipName];
            continue;
        }
        NSSet *relationshipObjects = [managedObject valueForKey:relationshipName];
        NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *relationshipObject in relationshipObjects) {
            [relationshipArray addObject:[self dataStructureFromManagedObject:relationshipObject]];
        }
        [valuesDictionary setObject:relationshipArray forKey:relationshipName];
    }
    return valuesDictionary;
}

+ (NSArray*)dataStructuresFromManagedObjects:(NSArray*)managedObjects
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSManagedObject *managedObject in managedObjects) {
        [dataArray addObject:[self dataStructureFromManagedObject:managedObject]];
    }
    return dataArray;
}

+ (NSData*)jsonStructureFromManagedObjects:(NSArray*)managedObjects
{
    NSArray *objectsArray = [self dataStructuresFromManagedObjects:managedObjects];
    NSError* err;
    NSData *jsonString = [[CJSONSerializer serializer] serializeArray:objectsArray error:&err];
    
    if (err) {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Error serializing object to JSON: ",err.description]
                inCategory:@"DATA"];
    }
    
    return jsonString;
}


+ (NSManagedObject*)managedObjectFromStructure:(NSDictionary*)structureDictionary withManagedObjectContext:(NSManagedObjectContext*)moc
{
    //NSMutableDictionary* structureDictionary = [NSMutableDictionary dictionaryWithDictionary:dict]; //TODO: use mutables throughout
    
    NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
    
    //[structureDictionary removeObjectForKey:@"ManagedObjectName"];
    
    for (NSString* key in [structureDictionary allKeys]) {
        //NSString* dicValue = (NSString*)[structureDictionary valueForKey:key];
        
        if (![key isEqualToString:@"ManagedObjectName"])
        {
            id dicValue = [structureDictionary valueForKey:key];
            if ([dicValue isKindOfClass:[NSNull class]])
                [managedObject setValue:nil forKey:key];
            else if ([dicValue isKindOfClass:[NSArray class]] || [dicValue isKindOfClass:[NSDictionary class]])
                ;
            else
                [managedObject setValue:[structureDictionary valueForKey:key] forKey:key];
        }
    }
    
    for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if ([description deleteRule]!=2) //kind of a hack, but avoids recursive loop
            continue;
        if (![description isToMany]) {
            NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
            if (childStructureDictionary) {
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                [managedObject setValue:childObject forKey:relationshipName];
            }
            continue;
        }
        NSMutableOrderedSet *relationshipSet = [managedObject mutableOrderedSetValueForKey:relationshipName];
        NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
        for (NSDictionary *childStructureDictionary in relationshipArray) {
            if (childStructureDictionary) {
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                [relationshipSet addObject:childObject];
            }
        }
    }
    return managedObject;
}

+ (NSArray*)managedObjectsFromJSONStructure:(NSData*)json withManagedObjectContext:(NSManagedObjectContext*)moc error:(NSError**)error
{
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    
    error = nil;
    NSArray *structureArray = [[CJSONDeserializer deserializer] deserializeAsArray:json error:error];
    if (error == nil) {
        for (NSDictionary *structureDictionary in structureArray) {
            [objectArray addObject:[CoreDataJSONHelper managedObjectFromStructure:structureDictionary withManagedObjectContext:moc]];
        }
    }
    else
    {
        [TBScopeData CSLog:[NSString stringWithFormat:@"Error deserializing JSON string: %@",[*error description]]
                inCategory:@"DATA"];
    }
    
    return objectArray;
}



@end
