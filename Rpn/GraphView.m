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

-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
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
    
    CGPoint drawingAreaOrigin = CGPointMake( (self.bounds.size.width - size) / 2.0, (self.bounds.size.height-size)/ 2.0 ); 
    CGRect drawingArea = CGRectMake(drawingAreaOrigin.x, drawingAreaOrigin.y , size, size); 
    
    double startOfRange = [self.dataSource startOfRange]; 
    double rangeDistance = [self.dataSource totalRangeDistance]; 
    
        
    CGPoint midPoint; 
    midPoint.x = drawingAreaOrigin.x + size/2.0; 
    midPoint.y = drawingAreaOrigin.y + size/2.0;  
    
    size *= self.scale; 

    
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

@end
