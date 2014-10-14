//
//  LogEntryDetailViewController.m
//  TBScope
//
//  Created by Frankie Myers on 10/11/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "LogEntryDetailViewController.h"

@interface LogEntryDetailViewController ()

@end

@implementation LogEntryDetailViewController

UITapGestureRecognizer* recognizer;


- (void)viewWillAppear:(BOOL)animated
{
    self.logEntryTextView.text = self.currentLogEntry.entry;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    //cancel this modal view if user taps background
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
    
    
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {

                for (UITapGestureRecognizer* recognizer in self.view.window.gestureRecognizers)
                    [self.view.window removeGestureRecognizer:recognizer];
                [self dismissModalViewControllerAnimated:YES];

        }
    }
}



@end
