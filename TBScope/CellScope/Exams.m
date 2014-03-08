//
//  Exams.m
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Exams.h"
#import "Slides.h"

@implementation Exams

@dynamic bluetoothUUID;
@dynamic cellscopeID;
@dynamic dateModified;
@dynamic diagnosisNotes;
@dynamic examID;
@dynamic googleDriveFileID;
@dynamic gpsLocation;
@dynamic intakeNotes;
@dynamic ipadMACAddress;
@dynamic ipadName;
@dynamic location;
@dynamic patientAddress;
@dynamic patientDOB;
@dynamic patientGender;
@dynamic patientHIVStatus;
@dynamic patientID;
@dynamic patientName;
@dynamic userName;
@dynamic examSlides;

- (void)addExamSlidesObject:(Slides *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.examSlides];
    [tempSet addObject:value];
    self.examSlides = tempSet;
}

@end
