//
//  MapViewController.h
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Provides a map summarizing diagnoses by location.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TBScopeData.h"

#define DEFAULT_MAP_REGION_SPAN 2000

@class MapViewController;
@protocol MapViewControllerDelegate <NSObject>
@optional
- (void)mapView:(MapViewController*)sender didSelectExam:(Exams *)exam;
@end

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak,nonatomic) IBOutlet MKMapView* mapView;

@property (nonatomic) BOOL showOnlyCurrentExam;
@property (nonatomic) BOOL allowSelectingExams;

@property (strong,nonatomic) Exams* currentExam;
@property (strong,nonatomic) id <MapViewControllerDelegate> delegate;

- (void)refreshMap;


@end


