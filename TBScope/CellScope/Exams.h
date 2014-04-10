//
//  Exams.h
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slides;

@interface Exams : NSManagedObject

@property (nonatomic, retain) NSString * bluetoothUUID;
@property (nonatomic, retain) NSString * cellscopeID;
@property (nonatomic, retain) NSString * dateModified;
@property (nonatomic, retain) NSString * diagnosisNotes;
@property (nonatomic, retain) NSString * examID;
@property (nonatomic, retain) NSString * googleDriveFileID;
@property (nonatomic, retain) NSString * gpsLocation;
@property (nonatomic, retain) NSString * intakeNotes;
@property (nonatomic, retain) NSString * ipadMACAddress;
@property (nonatomic, retain) NSString * ipadName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * patientAddress;
@property (nonatomic, retain) NSString * patientDOB;
@property (nonatomic, retain) NSString * patientGender;
@property (nonatomic, retain) NSString * patientHIVStatus;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSOrderedSet *examSlides;
@property (nonatomic) BOOL synced;

@end

@interface Exams (CoreDataGeneratedAccessors)

- (void)insertObject:(Slides *)value inExamSlidesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromExamSlidesAtIndex:(NSUInteger)idx;
- (void)insertExamSlides:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeExamSlidesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInExamSlidesAtIndex:(NSUInteger)idx withObject:(Slides *)value;
- (void)replaceExamSlidesAtIndexes:(NSIndexSet *)indexes withExamSlides:(NSArray *)values;
- (void)addExamSlidesObject:(Slides *)value;
- (void)removeExamSlidesObject:(Slides *)value;
- (void)addExamSlides:(NSOrderedSet *)values;
- (void)removeExamSlides:(NSOrderedSet *)values;


@end
