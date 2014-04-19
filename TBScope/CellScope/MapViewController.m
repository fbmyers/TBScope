//
//  MapViewController.m
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "MapViewController.h"

@interface ExamPushpinAnnotation : MKPointAnnotation

@property (strong,nonatomic) Exams* exam;
@property (nonatomic) BOOL isCurrent;

@end

@implementation ExamPushpinAnnotation

+ (id) pushpinWithExam:(Exams*)ex isCurrent:(BOOL)current;
{
    ExamPushpinAnnotation* epa = [[ExamPushpinAnnotation alloc] init];
    
    //basics
    epa.exam = ex;
    epa.isCurrent = current; //may not need this anymore
    epa.title = ex.examID;
    epa.coordinate = [TBScopeData coordinatesFromString:ex.gpsLocation];
    
    //subtitle = location + date first collected
    epa.subtitle = ex.location;
    if (ex.examSlides.count>0) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        epa.subtitle = [epa.subtitle stringByAppendingString:@"   "];
        epa.subtitle = [epa.subtitle stringByAppendingString:[dateFormatter stringFromDate:[TBScopeData dateFromString:[(Slides*)ex.examSlides[0] dateCollected]]]];
    }
    
    return epa;
}

@end

@implementation MapViewController

UITapGestureRecognizer* recognizer;
MKCoordinateRegion lastRegion;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self.view layer] setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor];
    [[self.view layer] setBorderWidth:1];
    
    [self.mapView setDelegate:self];
    
    [self refreshMap];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    //cancel this modal view if user taps background
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
    
    
    [TBScopeData CSLog:@"Map screen presented" inCategory:@"USER"];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            [self dismissMap];
        }
    }
}

- (void)refreshMap
{
    NSMutableArray* pushpins = [[NSMutableArray alloc] init];

    //populate current exam pushpin
    if (self.currentExam!=nil)
    {
        [pushpins addObject:[ExamPushpinAnnotation pushpinWithExam:self.currentExam isCurrent:YES]];
    }
    
    //other exams
    if (!self.showOnlyCurrentExam || self.currentExam==nil)
    {
        NSArray* allExams = [CoreDataHelper getObjectsForEntity:@"Exams" withSortKey:@"dateModified" andSortAscending:NO andContext:[[TBScopeData sharedData] managedObjectContext]];
        
        for (Exams* ex in allExams) {
            if (ex!=self.currentExam) {
                [pushpins addObject:[ExamPushpinAnnotation pushpinWithExam:ex isCurrent:NO]];
            }
        }
    }
    
    //zoom the map
    static BOOL regionDefined;
    if (!regionDefined || self.currentExam!=nil)
    {
        if (pushpins.count>0)
        {
            //if there was a currentExam chosen, pushpins[0] will be that exam. Otherwise, it will
            //be the most recently modified exam.
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(((MKPointAnnotation*)pushpins[0]).coordinate, DEFAULT_MAP_REGION_SPAN, DEFAULT_MAP_REGION_SPAN)];
            [self.mapView setRegion:adjustedRegion animated:YES];
        }
        regionDefined = YES;
    }
    else
    {
        [self.mapView setRegion:lastRegion];
    }
    
    [self.mapView addAnnotations:pushpins];
    
    if (self.currentExam!=nil) {
        [self.mapView selectAnnotation:pushpins[0] animated:YES];
    }
}

- (void) dismissMap
{
    for (UITapGestureRecognizer* recognizer in self.view.window.gestureRecognizers)
        [self.view.window removeGestureRecognizer:recognizer];
    [self dismissModalViewControllerAnimated:YES];
    lastRegion = self.mapView.region;
}
/*
- (ExamPushpinAnnotation*)makePushpinForExam:(Exams*)ex isCurrent:(BOOL)isCurrent
{
    CLLocationCoordinate2D examLocation = [TBScopeData coordinatesFromString:ex.gpsLocation];
    ExamPushpinAnnotation* pushpin = [[ExamPushpinAnnotation alloc] init];
    pushpin.coordinate = examLocation;
    pushpin.exam = ex;
    pushpin.title = ex.examID;
    pushpin.subtitle = ex.patientID;
    
    if (isCurrent) {
        [UIColor whiteColor];
    }
    else
    {
        //color = diagnosis
        //determine overall exam-level diagnosis (discuss this and see if we should put it in exam CD object)
        int examDiagnosis = 0;
        for (Slides* slide in ex.examSlides)
        {
            if (slide.slideAnalysisResults!=nil) {
                if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
                    examDiagnosis += 100;
                else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
                    examDiagnosis += 10;
                else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
                    examDiagnosis += 1;
            }
        }
        if (examDiagnosis>=100) {
            [UIColor redColor];
        }
        else if (examDiagnosis>=20 || examDiagnosis==11 || examDiagnosis==10) {
            [UIColor yellowColor];
        }
        else if (examDiagnosis==12 || examDiagnosis>=1) {
            [UIColor greenColor];
        }
        else {
            [UIColor lightGrayColor];
        }
    }
    
    return pushpin;
}
*/

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle custom annotation for exam
    if ([annotation isKindOfClass:[ExamPushpinAnnotation class]])
    {
        ExamPushpinAnnotation* pushpin = (ExamPushpinAnnotation*)annotation;
        //TODO: create pushpin images w/ each color/style we want, then use MKAnnotationView
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ExamPinAnnotationView"];
        if (!pinView)
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ExamPinAnnotationView"];
        
        pinView.annotation = annotation;
        
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        //pinView.calloutOffset = CGPointMake(0, 32);


        //color = diagnosis
        //determine overall exam-level diagnosis (discuss this and see if we should put it in exam CD object)
        int examDiagnosis = 0;
        for (Slides* slide in pushpin.exam.examSlides)
        {
            if (slide.slideAnalysisResults!=nil) {
                if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"POSITIVE"])
                    examDiagnosis += 100;
                else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"INDETERMINATE"])
                    examDiagnosis += 10;
                else if ([slide.slideAnalysisResults.diagnosis isEqualToString:@"NEGATIVE"])
                    examDiagnosis += 1;
            }
        }
        if (examDiagnosis>=100) {
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.alpha = 1.0;
        }
        else if (examDiagnosis>=20 || examDiagnosis==11 || examDiagnosis==10) {
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.alpha = 1.0;
        }
        else if (examDiagnosis==12 || examDiagnosis>=1) {
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.alpha = 1.0;
        }
        else {
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.alpha = 1.0;
        }

        if (self.allowSelectingExams)
        {
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        return pinView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[ExamPushpinAnnotation class]])
    {
        ExamPushpinAnnotation* pushpin = (ExamPushpinAnnotation*)annotation;
        [self.delegate mapView:self didSelectExam:pushpin.exam];
        [self dismissMap];
        lastRegion = self.mapView.region;
    }
}

@end
