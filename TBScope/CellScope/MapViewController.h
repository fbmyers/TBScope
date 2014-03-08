//
//  MapViewController.h
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define DEFAULT_MAP_REGION_SPAN 2000

@interface MapViewController : UIViewController

@property (weak,nonatomic) IBOutlet MKMapView* mapView;

@property (strong,nonatomic) UITapGestureRecognizer *recognizer;

@property (nonatomic) CLLocationCoordinate2D examLocation;

- (void)handleTapBehind:(UITapGestureRecognizer *)sender;

@end
