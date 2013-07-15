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
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar; 

@end

@implementation GraphViewController

@synthesize graphView = _graphView; 
@synthesize currProgram = _currProgram; 
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; 
@synthesize toolbar = _toolbar; 


/** Instance method: setSplitViewBarButtonItem
 * -------------------------------------------
 * setSplitViewBarButtonItem adds a button to the detailVC. This is part of 
 * the implementation of the functionality that hides/shows the master portion
 * of a splitView controller (the graphViewController is the detail portion). 
 * We connection between the toolbar and the controller is established in the storyboard. 
 * 
 */ 

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    // check that the new button is different from the existing button
    if(_splitViewBarButtonItem != splitViewBarButtonItem)
    {
        /* get the current toolbar array and make a mutableCopy (we're going to be modifying the array)
         * if the _splitViewBarButtonItem isn't nil, remove it from the array
         * put the new button in the array on the left hand side (i.e. at index:0)
         * set self.toolbar.items to the mutated array
         */
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy]; 
        if(_splitViewBarButtonItem) [toolbarItems removeObject: _splitViewBarButtonItem]; 
        if(splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0]; 
        self.toolbar.items = toolbarItems; 
        _splitViewBarButtonItem = splitViewBarButtonItem; 
    }
                                
    
}


/** Instance method: currProgram 
 * -----------------------------
 * currProgram is the setter for the _currProgram instance variable
 */

- (void)setCurrProgram:(NSArray *)currProgram
{
    _currProgram = currProgram; 
    
    // require graphView to redraw each time program is set
    [self.graphView setNeedsDisplay];
    
}



/** Instance method: setGraphView
 * ------------------------------
 * setGraphView is the setter for the _graphView instance variable. 
 * setGraphView adds the gesture recognizers that we use
 */ 

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView; 
    
    self.graphView.dataSource = self;
    
    /* target: the object that implements the gesture. In this example 
     * the view itself implements the gesture. So target is self.graphView
     */ 
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]]; 
    
    /* target: again the view will be the object that reacts/deals with the gesture
     */ 

    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handleTaps:)];
    
    tripleTap.numberOfTapsRequired = 3;
    
    [self.graphView addGestureRecognizer:tripleTap]; 
}


/** Instance method: yCoordinateForGraphView
 * -----------------------------------------
 * yCoordinateForGraphView takes a double and returns a double. yCoordinateForGraphView
 * takes as input the x coordinate and calls the calculator brain to return the corresponding
 * y coordinate
 */ 

-(double)yCoordinateForGraphView:(double)xCoordinate
{
    NSDictionary *xValue = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xCoordinate], @"x", nil];
    return [RpnBrain runProgram:self.currProgram usingVariableValues: xValue]; 
    
}


/**Instance method: hasProgram
 * ---------------------------
 * self-documenting
 */ 

-(BOOL)hasProgram
{
    return (self.currProgram != nil); 
}


/** Instance method: startOfRange
 * ------------------------------
 * startOfRange returns the start of the range to be graphed. 
 * If we're graphing a line the default range is -10 to 10
 * If we're graphing sin or cos, the default range is -2π to 2π
 */

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


/** Instance method: totalRangeDistance
 * ------------------------------------
 * totalRangeDistance returns the length of the range
 * that we are graphing over
 */

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
