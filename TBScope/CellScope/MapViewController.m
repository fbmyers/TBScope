//
//  MapViewController.m
//  TBScope
//
//  Created by Frankie Myers on 2/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[self.view layer] setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor];
    [[self.view layer] setBorderWidth:1];
    
    //cancel this modal view if user taps background
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [self.recognizer setNumberOfTapsRequired:1];
    self.recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:self.recognizer];
    
    //drop a pushpin where this exam was recorded
    MKPointAnnotation* pushpin = [[MKPointAnnotation alloc] init];
    pushpin.coordinate = self.examLocation;
    [self.mapView addAnnotation:pushpin];
    
    //set the zoom scale of the mapview
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.examLocation, DEFAULT_MAP_REGION_SPAN, DEFAULT_MAP_REGION_SPAN)];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    //TODO: pushpins of other assays
    //TODO: color pushpins based on assay results
    //TODO: clicking on pushpin brings up that exam (only in review mode)
    
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}


@end
