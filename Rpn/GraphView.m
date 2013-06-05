//
//  GraphView.m
//  Rpn
//
//  Created by Anthony Zavadil on 6/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"



@implementation GraphView

@synthesize dataSource = _dataSource; 

@synthesize scale = _scale; 
@synthesize panAdjustment = _panAdjustment; 
@synthesize originAdjustment = _originAdjustment; 

#define DEFAULT_SCALE 0.90


-(CGFloat)scale
{
    if(!_scale)
    {
        return DEFAULT_SCALE; 
    }
    else 
    {
        return _scale; 
    }
}

-(void)setScale:(CGFloat)scale
{
    //before triggering exspensive redraw, check that scale changed
    if(_scale != scale)
    {
        _scale = scale; 
        [self setNeedsDisplay]; 
    }
    
}

-(CGPoint)panAdjustment
{
    if(!(_panAdjustment.x != 0 || _panAdjustment.y != 0))
    {
        return CGPointZero; 
    }
    else 
    {
        return _panAdjustment; 
    }
}

-(void)setPanAdjustment:(CGPoint)panAdjustment
{
    //before triggering exspensive redraw, check that scale changed
    if(_panAdjustment.x != panAdjustment.x || 
       _panAdjustment.y != panAdjustment.y)
    {
        _panAdjustment = panAdjustment; 
        [self setNeedsDisplay]; 
    }
    
}

- (void)incrementPanAdjustment:(CGPoint)panAdjustment
{
    //before triggering exspensive redraw, check that scale changed
    if(_panAdjustment.x != panAdjustment.x || 
       _panAdjustment.y != panAdjustment.y)
    {
        _panAdjustment.x += panAdjustment.x;
        _panAdjustment.y += panAdjustment.y; 
        [self setNeedsDisplay]; 
    }

    
}


-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        [self incrementPanAdjustment:[gesture translationInView:self]]; 

        [gesture setTranslation:CGPointZero inView:self];             
    }
}

-(void)handleTaps:(UITapGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self setPanAdjustment:[gesture locationOfTouch:0 inView:self]]; 
    }

}


- (void)setup
{ 
    //code required to force view to redraw
    self.contentMode = UIViewContentModeRedraw; 
} 

-(void)awakeFromNib 
{
    [self setup]; 
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; 
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
 
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGFloat size = self.bounds.size.width; 
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height; 
    
    /* If the size is less than the width/height, we want to split the difference
     * so there's an equal margin on both sides
     */ 
    
    CGPoint drawingAreaOrigin = CGPointMake( self.panAdjustment.x + (self.bounds.size.width - size) / 2.0, self.panAdjustment.y + (self.bounds.size.height-size)/ 2.0 ); 
    CGRect drawingArea = CGRectMake(self.panAdjustment.x + drawingAreaOrigin.x, self.panAdjustment.y + drawingAreaOrigin.y , size, size); 
    
    CGPoint midPoint; 
    midPoint.x = self.panAdjustment.x + drawingAreaOrigin.x + size/2.0; 
    midPoint.y = self.panAdjustment.y + drawingAreaOrigin.y + size/2.0;  
    
    if (![self.dataSource hasProgram]) 
    {
        [AxesDrawer drawAxesInRect:drawingArea originAtPoint:midPoint scale:25];
    }
    else
    {
        size *= self.scale; 

        double startOfRange = [self.dataSource startOfRange]; 
        double rangeDistance = [self.dataSource totalRangeDistance]; 
    
        double max; 
        for(int i = 0; i < size; i++){ 
            double scaledX = startOfRange + rangeDistance*(i/size); 
            double temp = [self.dataSource yCoordinateForGraphView:scaledX]; 
            if (fabs(temp) > max) max = fabs(temp); 
        }
    
        CGFloat pointsPerHashmark = size / (CGFloat)rangeDistance; 
        [AxesDrawer drawAxesInRect:drawingArea originAtPoint:midPoint scale:pointsPerHashmark];
    
        CGContextBeginPath(context); 
        CGContextMoveToPoint(context, midPoint.x - size/2 , midPoint.y - pointsPerHashmark*[self.dataSource yCoordinateForGraphView:startOfRange]); //datasource    
    
        for(int i = 1; i < size; i++){
            double scaledX = startOfRange + rangeDistance*(i/size);
            double temp = [self.dataSource yCoordinateForGraphView:scaledX];
     
            CGContextAddLineToPoint(context, midPoint.x - size/2 + (CGFloat)i, (midPoint.y - pointsPerHashmark*(CGFloat)temp)); //datasource
        }
        CGContextDrawPath(context, kCGPathStroke); 
    }
}

@end
