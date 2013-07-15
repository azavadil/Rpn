//
//  RpnViewController.m
//  Rpn
//
//  Created by athony on 5/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RpnViewController.h"
#import "RpnBrain.h" 
#import "GraphViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RpnViewController() 
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL stackDisplayWaitingForOperation; 
@property (nonatomic) BOOL notFirstUseOfStackDisplay; 
@property (nonatomic, strong) RpnBrain *brain; 
@property (nonatomic,strong) NSDictionary *variableDictionary;

@end

@implementation RpnViewController

@synthesize display = _display; 
@synthesize stackDisplay = _stackDisplay;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber; 
@synthesize stackDisplayWaitingForOperation = _stackDisplayWaitingForOperation; 
@synthesize brain = _brain; 
@synthesize notFirstUseOfStackDisplay = _notFirstUseOfStackDisplay; 
@synthesize variableDictionary = _variableDictionary;

- (RpnBrain*)brain { 
    if(_brain == nil) _brain = [[RpnBrain alloc] init]; 
    return _brain; 
}


/** Instance method: splitViewGraphViewController
 * ----------------------------------------------
 * splitViewGraphViewController returns the graphViewController if I'm in a splitview
 * with a graphView, otherwise it returns nil
 */ 

-(GraphViewController *)splitViewGraphViewController
{
    
    id graphViewController = [self.splitViewController.viewControllers lastObject]; 
    if(![graphViewController isKindOfClass:[graphViewController class]]) 
    {
        graphViewController = nil; 
    }
    return graphViewController; 
}


/** Instance method: isSplitViewBarButtonItemPresenter
 * ---------------------------------------------------
 * isSplitViewBarButtonItemPresenter returns the detailVC if the detailVC
 * implements the SplitViewBarButtonItemPresenter protocol, nil otherwise
 */ 

-(id <SplitViewBarButtonItemPresenter>)isSplitViewBarButtonItemPresenter
{
    /** [self.splitViewController.viewControlers lastObject] will get the 
     * detailViewController if I'm in a splitview, other it will return nil
     * (i.e. if we're not in a splitView, self.splitViewController will be nil, 
     *  .viewControllers will be nil, and the call to lastObject will be nil)
     */
      
    id detailVC = [self.splitViewController.viewControllers lastObject]; 
    
    /* I'm going to get the detailVC if the detailVC is able to show a barButton 
     * (i.e. is a BarButtonItemPresenter)
     * Note. this is how you check whether an object conforms to a
     * protocol. If the detailVC doesn't implement the protocol, we're defensive
     * and set detailVC to nil. 
     */ 
    
    if(![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)])
    {
        detailVC = nil; 
    }
    return detailVC;     
}


/** Instance method: awakeFromNib
 * ------------------------------
 * awakeFromNib for the RpnViewController sets itself as the delegate for
 * the splitViewController
 */ 

- (void)awakeFromNib
{
    [super awakeFromNib]; 
    self.splitViewController.delegate = self; 
}

/** Implementation note: 
 * ---------------------
 * The next 3 methods splitViewController-shouldHideViewController-inOrientation
 *                    splitViewController-willHideViewController-withBarButtonItem-forPopoverController
 *                    splitViewController-willShowViewController-invalidatingBarButtonItem
 * are used to control the  going onscreen/offscreen
 * 
 * This code is specific to the iPad implementation. When the iPad is in portrait mode we'd like 
 * to hide the master part of the splitViewController. In order to hide the master, we need to put 
 * a button onscreen that allows us to navigate back to the previous screen. 
 *
 * One poor solution is to have the method splitViewController-shouldHideViewController always 
 * return NO (i.e. we never hide the master). This produces a sub-optimal UI. 
 *
 * What we'd prefer is for the detailVC to have a method to add a button and remove a button.
 * However, add/remove a button isn't a built in method for the UIViewController class. 
 *
 * Instead, we have the detailVC implement a protocol that provides the functionality we want
 * (i.e. the add/remove a button functionality). Then we use introspection. If the detailVC
 * If the detailVC implements the protocol and is able to add/remove buttons, then we hide 
 * the master and put the button onscreen. If the detailVC doesn't implement the protocol, 
 * then we never hide the master (i.e. we always return NO from the 
 * splitViewController-shouldHideViewController method. 
 */

/** Instance method: splitViewController-shouldHideViewController-inOrientation
 * ----------------------------------------------------------------------------
 * returns YES if the master should be hidden in the specified orientation, returns 
 * NO otherwise. In this case, we only want the master to be hidden when the device
 * is in portrait mode. 
 */ 
 
-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation
{
    /** There's an implicit conditional. self isSplitViewBarButtonItemPresenter returns the detailVC
     * if the detailVC implements the add/remove button protocol. Objective-C treats an object as 
     * true in a conditional (i.e. if isSplitViewBarButtonItemPresenter returns a VC, the true branch
     * of the conditional gets evaluated. 
     */
    return [self isSplitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO; 
} 

/** Instance method: splitViewController-willHideViewController-withBarButtonItem-forPopoverController
 * ---------------------------------------------------------------------------------------------------
 * the method handles when we're going to hide the master controller and need 
 * to put a button on-screen
 */ 

-(void)splitViewController:(UISplitViewController *)svc 
    willHideViewController:(UIViewController *)aViewController 
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc
{
    
    /* This is a generic implementation. We assume that the title 
     * of the controller is good title for the button
     */
    barButtonItem.title = self.title; 
    
    /* if isSplitViewBarButtonItemPresenter returns a detailVC, we set the barButtonItem 
     */ 
    [self isSplitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem; 
    
}



/** Instance method: splitViewController-willShowViewController-invalidatingBarButtonItem
 * --------------------------------------------------------------------------------------
 * the method handles the case where we're going to put the master back on screen and 
 * want to take the button away
 */ 

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController 
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    /* here we want to take away the button 
     */ 
    [self isSplitViewBarButtonItemPresenter].splitViewBarButtonItem = nil; 
    
}



/** Instance method: variableDictionary
 * ------------------------------------
 * getter for variableDictionary. overrides the @synthesize method. 
 * We put responsibility for instantiating the instance variable in the getter
 */ 

- (NSDictionary*)variableDictionary
{
    if(_variableDictionary == nil) _variableDictionary =[[NSMutableDictionary alloc] init]; 
    return _variableDictionary; 
}



/** Instance method: containsDecimalPoint
 * --------------------------------------
 * containsDecimalPoint takes an NSString. Returns YES if the string contains 
 * the string @".", NO otherwise
 */ 

- (BOOL) containsDecimalPoint:(NSString *)digitsSoFar
{
    NSRange range = [digitsSoFar rangeOfString:@"."]; 
    if(range.location == NSNotFound){ 
        return NO; 
    }
    return YES; 
}



/** Instance method: notEorPi
 * -------------------------
 * notEorPi takes an NSString and returns YES if the string equals the 
 * string @"π" or the string @"e"
 */ 

- (BOOL) notEorPi:(NSString *)unknownOperation
{ 
    return !([unknownOperation isEqualToString:@"π"] || [unknownOperation isEqualToString:@"e"]); 
}


/** Instance method: updateStackDisplay
 * ------------------------------------
 * updateStackDisplay calls descriptionOfProgram and updates the stack display
 * to the string value returned by descriptionOfProgram
 *
 */
- (void) updateStackDisplay
{ 
    self.stackDisplay.text = [RpnBrain descriptionOfProgram:self.brain.program];     
    
}


/** Instance method: digitPressed
 * ------------------------------
 * target for the action of a digit button being pressed. 
 * Update the display to reflect the digit pressed. 
 * 
 * Note we do some defensive programming. If the user is in the middle of entering a number, 
 * we check whether the digit is a decimal point and if the number so far already contains 
 * a decimal point. As long as that's not then we can update the number 
 */

- (IBAction)digitPressed:(UIButton*)sender {
    
    NSString *digit = [sender currentTitle]; 
    if(self.userIsInTheMiddleOfEnteringANumber){ 
        if(![self containsDecimalPoint:self.display.text] || ![digit isEqualToString:@"."]){  
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
    } else { 
        self.display.text = digit; 
        self.userIsInTheMiddleOfEnteringANumber = YES; 
    }
}



/** Instance method: enterPressed
 * ------------------------------
 * target for the action of the enter button being pressed. 
 */

- (IBAction)enterPressed {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    self.userIsInTheMiddleOfEnteringANumber = NO; 
    [self updateStackDisplay];

}


/** Instance method: operationPressed
 * ------------------------------
 * target for the action for one of the operation buttons being pressed.
 *
 * We provide the convience that if the user was in the middle of entering 
 * a number then we call enterPressed for the user. 
 */

- (IBAction)operationPressed:(UIButton*)sender {
    
    
    // operation = clear: clear everything
    if([[sender currentTitle] isEqualToString:@"C"]) { 
        self.stackDisplay.text = @"";
        self.display.text = @"0"; 
        [self.brain clearProgramStack]; 
        self.notFirstUseOfStackDisplay = NO; 
        self.userIsInTheMiddleOfEnteringANumber = NO; 
        return; 
    } 
    
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    double result = [self.brain performOperation:sender.currentTitle valParam:self.variableDictionary]; 
    self.display.text = [NSString stringWithFormat:@"%g", result]; 
    [self updateStackDisplay];

}



/** Instance method: variablePressed
 * ------------------------------
 * target for the variable button being pressed. 
 */

- (IBAction)variablePressed:(id)sender {
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed]; 
    [self.brain pushVariable:[sender currentTitle]]; 
}
    


- (IBAction)undoPressed {
    if(self.userIsInTheMiddleOfEnteringANumber){ 
        if([self.display.text length] > 1) {
            self.display.text = [self.display.text substringToIndex:[self.display.text length]-1]; 
        } else { 
            double result = [self.brain performOperation:self.variableDictionary]; 
            self.display.text = [NSString stringWithFormat:@"%g", result]; 
            [self updateStackDisplay];
        }
    } else { 
        [self.brain removeLastItem];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowGraph"])
    {
        [segue.destinationViewController setCurrProgram:self.brain.program]; 
    }
}



/** Instance method: graph
 * -----------------------
 * target for the action of the user pressing the graph button. 
 * The graph button graphs the program that is currently on the 
 * program stack 
 */ 

- (IBAction)graph {
    /* get the graphViewController from the splitview
     * send the graphViewController a message updating the program
     */ 
    
    if([self splitViewGraphViewController]) 
    {
        [[self splitViewGraphViewController] setCurrProgram:self.brain.program]; 
    }
    else 
    {
        /* sender is usually the button that's causing the segue
         * in this case it's the view controller itself.
         */ 
        
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }

    
    
    
}

@end
