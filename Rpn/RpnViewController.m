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


- (NSDictionary*)variableDictionary
{
    if(_variableDictionary == nil) _variableDictionary =[[NSMutableDictionary alloc] init]; 
    return _variableDictionary; 
}


- (BOOL) containsDecimalPoint:(NSString *)digitsSoFar
{
    NSRange range = [digitsSoFar rangeOfString:@"."]; 
    if(range.location == NSNotFound){ 
        return NO; 
    }
    return YES; 
}

- (BOOL) notEorPi:(NSString *)unknownOperation
{ 
    return !([unknownOperation isEqualToString:@"π"] || [unknownOperation isEqualToString:@"e"]); 
}

- (void) updateStackDisplay
{ 
    self.stackDisplay.text = [RpnBrain descriptionOfProgram:self.brain.program];     
    
}


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

- (IBAction)enterPressed {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    self.userIsInTheMiddleOfEnteringANumber = NO; 
    [self updateStackDisplay];

}


- (IBAction)operationPressed:(UIButton*)sender {
    
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

- (IBAction)graph {
    [self performSegueWithIdentifier:@"ShowGraph" sender:self]; 
    
}

@end
