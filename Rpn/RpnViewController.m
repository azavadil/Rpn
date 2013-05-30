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
@property (nonatomic, strong) RpnBrain *brain; 
@end

@implementation RpnViewController

@synthesize display = _display; 
@synthesize userIsInTheMiddleOfEnteringANumber = 
    _userIsInTheMiddleOfEnteringANumber; 
@synthesize brain = _brain; 

- (RpnBrain*)brain { 
    if(_brain == nil) _brain = [[RpnBrain alloc] init]; 
    return _brain; 
}

- (IBAction)digitPressed:(UIButton*)sender {
    
    NSString *digit = [sender currentTitle]; 
    if(self.userIsInTheMiddleOfEnteringANumber){ 
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else { 
        self.display.text = digit; 
        self.userIsInTheMiddleOfEnteringANumber = YES; 
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]]; 
    self.userIsInTheMiddleOfEnteringANumber = NO; 
    
}


- (IBAction)operationPressed:(UIButton*)sender {
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed]; 
    double result = [self.brain performOperation:sender.currentTitle]; 
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString; 
    
    

}


@end
