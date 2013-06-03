//
//  GraphViewController.m
//  Rpn
//
//  Created by Anthony Zavadil on 6/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h" 
#import "RpnBrain.h" 

@interface GraphViewController() <GraphViewDataSource> 

// this is how we make outlets
@property (nonatomic, weak) IBOutlet GraphView *graphView; 

@end

@implementation GraphViewController

@synthesize graphView = _graphView; 
@synthesize currProgram = _currProgram; 


- (void)setCurrProgram:(NSArray *)currProgram
{
    _currProgram = currProgram; 
    
    // require graphView to redraw each time program is set
    [self.graphView setNeedsDisplay];
    
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView; 
    
    self.graphView.dataSource = self;
    
    /* target: the object that implements the gesture. In this example 
     * the view itself implements the gesture. So target is self.graphView
     */ 
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]]; 
    
    //implement pan

}


-(double)yCoordinateForGraphView:(double)xCoordinate
{
    NSDictionary *xValue = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xCoordinate], @"x", nil];
    return [RpnBrain runProgram:self.currProgram usingVariableValues: xValue]; 
    
}

-(double)startOfRange
{
    double result = -10; 
    
    if([self.currProgram containsObject:@"sqrt"]){
        result = -1; 
    }
    else if ([self.currProgram containsObject:@"sin"] ||
              [self.currProgram containsObject:@"cos"])
    {
        result = -2*M_PI; 
    }
    return result; 
}

-(double)totalRangeDistance
{
    double result = 20; 
    
    if ([self.currProgram containsObject:@"sin"] ||
             [self.currProgram containsObject:@"cos"])
    {
        result = 4*M_PI; 
    }
    return result; 
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
