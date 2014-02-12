//
//  TBScopeViewControllerContext.h
//  TBScope
//
//  Created by Frankie Myers on 11/20/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Slides.h"
#import "Users.h"

@protocol TBScopeViewControllerContext <NSObject>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users* currentUser;
@property (strong,nonatomic) Slides* currentSlide;

@end
