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
    double endOfRange = [self.dataSource endOfRange]; 
    
    
    CGPoint midPoint; 
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2.0; 
    midPoint.x = self.bounds.origin.y + self.bounds.size.height/2.0;
    
    CGFloat halfOfGraphArea = midPoint.y * self.scale; 
    
      
    double max; 
    for(int i = 0; i< self.bounds.size.width; i++){ 
        double scaledX = startOfRange + endOfRange*(i/self.bounds.size.width); 
        double temp = [self.dataSource yCoordinateForGraphView:scaledX]; 
        if (fabs(temp) > max) max = fabs(temp); 
    }
    
    
    CGRect trigRect = CGRectMake(0, 0, endOfRange, 2); 
    
    [AxesDrawer drawAxesInRect:trigRect originAtPoint:midPoint scale:0.90];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextBeginPath(context); 
    CGContextMoveToPoint(context, startOfRange, [self.dataSource yCoordinateForGraphView:startOfRange]); //datasource
    
    for(int i = 1; i< self.bounds.size.width; i++){
        double scaledX = startOfRange + (endOfRange)*(i/self.bounds.size.width);
        double temp = [self.dataSource yCoordinateForGraphView:scaledX];
        CGFloat scaledY = halfOfGraphArea * (CGFloat)temp/max; 
    
        CGContextAddLineToPoint(context, i, midPoint.y + scaledY); //datasource
    }
    CGContextDrawPath(context, kCGPathStroke); 
    
    
}

@end
