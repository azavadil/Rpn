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

/** Instance method: scale
 * -----------------------
 * getter for _scale instance variable  
 */

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



/** Instance method: getScale
 * --------------------------
 * self-documenting implementation
 */ 

-(void)setScale:(CGFloat)scale
{
    //before triggering exspensive redraw, check that scale changed
    if(_scale != scale)
    {
        _scale = scale; 
        // have the screen redraw each time the scale is set
        [self setNeedsDisplay]; 
    }
    
}



/** Instance method: panAdjustment
 * -------------------------------
 * getter for panAdjustment. If there is no panAdjustment we just return 
 * point (0,0)
 */ 

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



/** Instance method: setPanAdjustment
 * ----------------------------------
 * setter for _panAdjustment instance variable. We check that the argument 
 * passed to them method is different than the current value of the instance 
 * variable to avoid the computation expense of redrawing the display if 
 * possible
 */ 

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



/** Instance method: incrementPanAdjustment
 * ----------------------------------------
 * incrementPanAdjustment takes a CGPoint and increments the 
 * _panAdjustment by the x,y values in the point
 */ 

- (void)incrementPanAdjustment:(CGPoint)panAdjustment
{
    _panAdjustment.x += panAdjustment.x;
    _panAdjustment.y += panAdjustment.y; 
    [self setNeedsDisplay]; 

}



/** Instance method: pinch
 * -----------------------
 * self-documenting
 */

-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}


/** Instance method: pan
 * ---------------------
 * pan handles the pan gesture recognizer. We reset the gesture to
 * zero after we handle the gesture
 */ 

-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        [self incrementPanAdjustment:[gesture translationInView:self]]; 

        [gesture setTranslation:CGPointZero inView:self];             
    }
}



/** Instance method: handleTaps
 * ----------------------------
 * handleTaps 
 */ 

-(void)handleTaps:(UITapGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self setPanAdjustment:[gesture locationOfTouch:0 inView:self]]; 
    }

}



/** Instance method: setup
 * -----------------------
 * setup ensures that content mode is always called. initWithFrame isn't 
 * always called when the view controller comes out of a storyboard so 
 * so put the code to set contentMode in setup and then put a call to 
 * setup in both awakeFromNib and initWitFrame
 */

- (void)setup
{ 
    //code required to force view to redraw
    self.contentMode = UIViewContentModeRedraw; 
} 



/** Instance method: awakeFromNib
 * ------------------------------
 * self-documenting
 */ 

-(void)awakeFromNib 
{
    [self setup]; 
}


/** Instance method: initWithFrame
 * -------------------------------
 * self-documenting
 */ 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; 
    }
    return self;
}


/** Instance method: drawRect
 * --------------------------
 * drawRect draws the graph on screen
 */

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
    
        // note the GraphViewController is set as the datasource (i.e. same as delegate) and we use that to get the y coordinate
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
