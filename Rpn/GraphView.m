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
 
    
    
    double startOfRange = [self.dataSource startOfRange]; 
    double rangeDistance = [self.dataSource totalRangeDistance]; 
    
    NSLog(@"rangeDistance = %f, width = %f, height = %f", rangeDistance, self.bounds.size.width, self.bounds.size.height); 
    
    
    CGPoint midPoint; 
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2.0; 
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2.0;
    
    CGFloat halfHeight = midPoint.y * 1; 
    
    
    double max; 
    for(int i = 0; i< self.bounds.size.width; i++){ 
        double scaledX = startOfRange + rangeDistance*(i/self.bounds.size.width); 
        double temp = [self.dataSource yCoordinateForGraphView:scaledX]; 
        if (fabs(temp) > max) max = fabs(temp); 
    }
    
    CGFloat pointsPerHashmark = self.bounds.size.width / (CGFloat)rangeDistance; 
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:midPoint scale:pointsPerHashmark];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextBeginPath(context); 
    CGContextMoveToPoint(context, startOfRange, [self.dataSource yCoordinateForGraphView:startOfRange]); //datasource
    
    for(int i = 1; i< self.bounds.size.width; i++){
        double scaledX = startOfRange + rangeDistance*(i/self.bounds.size.width);
        double temp = [self.dataSource yCoordinateForGraphView:scaledX];
     
        CGContextAddLineToPoint(context, (CGFloat)i, (halfHeight - pointsPerHashmark*(CGFloat)temp)); //datasource
    }
    CGContextDrawPath(context, kCGPathStroke); 
    
    
}

@end
