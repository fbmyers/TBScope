//
//  TBSlideViewerSubview.m
//  TBSlideViewerTestbed
//
//  Created by Frankie Myers on 11/6/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "TBSlideViewerSubview.h"
#import "TBSlideViewer.h"

@implementation TBSlideViewerSubview

@synthesize roiList;
@synthesize roiSizeX;
@synthesize roiSizeY;
@synthesize redThreshold;
@synthesize yellowThreshold;
@synthesize scoresVisible;
@synthesize boxesVisible;
@synthesize image;
@synthesize brightness;
@synthesize contrast;
@synthesize zoomFactor;

- (id)initWithImage:(UIImage*)im
{
    CGRect bounds = CGRectMake(0,0,im.size.width,im.size.height);
    self = [super initWithFrame:bounds];
    
    if (self) {
        self.image = im;
        self.roiList = nil;
        self.roiSizeX = 24;
        self.roiSizeY = 24;
        self.redThreshold = 0.5;
        self.yellowThreshold = 0.2;
        self.scoresVisible = NO;
        self.boxesVisible = YES;
        self.brightness = 1.0;
        self.contrast = 1.0;
        self.zoomFactor = 1.0;
        
        //self.image = im;
        [im drawInRect:bounds];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    //TODO: brightness and contrast
    [self.image drawInRect:bounds];
    
    // Drawing code
    if (self.boxesVisible)
    {
        
        if (zoomFactor<1.0)
            CGContextSetLineWidth(ctx,1.0/zoomFactor);
        else
            CGContextSetLineWidth(ctx,1.0);
        
        ROI* roi;
        for (roi in self.roiList)
        {
            CGRect roiRect = CGRectMake(roi.x-(self.roiSizeX/2),roi.y-(self.roiSizeY/2),self.roiSizeX,self.roiSizeY);
            if (roi.score>self.redThreshold)
                CGContextSetRGBStrokeColor(ctx,1.0,0.0,0.0,1.0);
            else if (roi.score>self.yellowThreshold)
                CGContextSetRGBStrokeColor(ctx,1.0,1.0,0.0,1.0);
            else
                CGContextSetRGBStrokeColor(ctx,0.0,1.0,0.0,1.0);
            
            CGContextAddRect(ctx, roiRect);
            CGContextStrokePath(ctx);
            
            if (self.scoresVisible && self.zoomFactor>1)
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);

                //CGContextSetFillColorWithColor(ctx, whiteColor);
                NSString* scoreLabel = [[NSString alloc] initWithFormat:@"%d",(int)round(roi.score*100)];
                
                UIFont *font = [UIFont systemFontOfSize:12];
                
                CGSize stringSize = [scoreLabel sizeWithFont:font];
                CGRect stringRect = CGRectMake(roi.x+self.roiSizeX/2, roi.y+self.roiSizeY/2, stringSize.width, stringSize.height);
                
                [[UIColor whiteColor] set];
                [scoreLabel drawInRect:stringRect withFont:font];
                CGContextStrokePath(ctx);
                
            }

            
        }
    }
    

    
    //NSLog(@"x=%f y=%f dx=%f dy=%f zf=%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height,zoomFactor);
    
    
}

@end
