//
//  Exams.m
//  TBScope
//
//  Created by Frankie Myers on 2/18/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Exams.h"
#import "Slides.h"


@implementation Exams

@dynamic gpsLocation;
@dynamic location;
@dynamic intakeNotes;
@dynamic patientAddress;
@dynamic patientID;
@dynamic patientName;
@dynamic userName;
@dynamic cellscopeID;
@dynamic bluetoothUUID;
@dynamic ipadMACAddress;
@dynamic ipadName;
@dynamic googleDriveFileID;
@dynamic patientHIVStatus;
@dynamic patientDOB;
@dynamic patientGender;
@dynamic examID;
@dynamic dateModified;
@dynamic diagnosisNotes;
@dynamic examSlides;

- (void)addExamSlidesObject:(Slides *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.examSlides];
    [tempSet addObject:value];
    self.examSlides = tempSet;
}

@end
