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
@end

@implementation RpnViewController

@synthesize display = _display; 
@synthesize stackDisplay = _stackDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = 
    _userIsInTheMiddleOfEnteringANumber; 
@synthesize stackDisplayWaitingForOperation = _stackDisplayWaitingForOperation; 
@synthesize brain = _brain; 
@synthesize notFirstUseOfStackDisplay = _notFirstUseOfStackDisplay; 

- (RpnBrain*)brain { 
    if(_brain == nil) _brain = [[RpnBrain alloc] init]; 
    return _brain; 
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

- (void) updateStackLabel:(NSString*)operationType
{ 
    NSString *newProgram; 
    if (self.notFirstUseOfStackDisplay){ 
         newProgram = [self.stackDisplay.text stringByAppendingString:self.display.text];
    } else { 
        if ([self.display.text isEqualToString:@"0"]){
            newProgram = @"";
        } else { 
            newProgram = self.display.text; 
        }
        self.notFirstUseOfStackDisplay = YES; 
    }
        
    if (operationType && [self notEorPi:operationType])                                                    
    { 
        self.stackDisplay.text = [NSString stringWithFormat:@"%@ %@ ",self.stackDisplay.text, operationType];
        self.stackDisplayWaitingForOperation = NO; 
    }
    else
    {
        self.stackDisplay.text = [NSString stringWithFormat:@"%@ ", newProgram];
        self.stackDisplayWaitingForOperation = YES; 
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
    
    [self.brain pushOperand:[self.display.text doubleValue]]; 
    self.userIsInTheMiddleOfEnteringANumber = NO; 
    [self updateStackLabel:nil];

}


- (IBAction)operationPressed:(UIButton*)sender {
    
    if([[sender currentTitle] isEqualToString:@"C"]) { 
        self.stackDisplay.text = @"";
        self.display.text = @"0"; 
        [self.brain clearProgramStack]; 
        self.notFirstUseOfStackDisplay = NO;  
        return; 
    } 
    
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self updateStackLabel:sender.currentTitle];

    double result = [self.brain performOperation:sender.currentTitle]; 
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString; 
    

}


- (void)viewDidUnload {
    [self setStackDisplay:nil];
    [super viewDidUnload];
}
@end
