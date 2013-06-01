//
//  RpnViewController.m
//  Rpn
//
//  Created by athony on 5/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RpnViewController.h"
#import "RpnBrain.h" 

@interface RpnViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL stackDisplayWaitingForOperation; 
@property (nonatomic) BOOL notFirstUseOfStackDisplay; 
@property (nonatomic, strong) RpnBrain *brain; 
@property (nonatomic,strong) NSDictionary *variableDictionary; 
- (void)setTestVariables:(NSString*)test;  
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

- (void) updateVariableDisplay
{
    NSString *result = @""; 
    for (NSString *key in [self.variableDictionary keyEnumerator]){ 
        NSString *temp = [NSString stringWithFormat:@"%@ = %@ ", key, [self.variableDictionary valueForKey:key]];
        result = [result stringByAppendingString:temp]; 
    }
    self.variableDisplay.text = result; 
}

- (void)setTestVariables:(NSString*)test
{
    if([test isEqualToString:@"TestA"])
    { 
        self.variableDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:10],@"a", 
                                   [NSNumber numberWithDouble:20], @"b", 
                                   [NSNumber numberWithDouble:30], @"x", nil]; 
    }
    else if([test isEqualToString:@"TestB"])
    {
        self.variableDictionary =  [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:2], @"a", 
                                    [NSNumber numberWithDouble:4], @"b", 
                                    [NSNumber numberWithDouble:6], @"x",nil];
    }
    else if([test isEqualToString:@"TestC"])
    {
        self.variableDictionary =  [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNull null], @"a", 
                                    [NSNull null], @"b", 
                                    [NSNull null], @"x",nil];
        
    }
    
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
    

- (IBAction)testPressed:(id)sender {
    
    [self setTestVariables:[sender currentTitle]]; 
    [self updateVariableDisplay]; 
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

@end
