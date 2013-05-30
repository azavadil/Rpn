//
//  RpnBrain.m
//  Rpn
//
//  Created by athony on 5/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RpnBrain.h"

@interface RpnBrain()
@property (nonatomic, strong) NSMutableArray *operandStack; 
@end


@implementation RpnBrain

@synthesize operandStack = _operandStack; 

- (NSMutableArray*)operandStack
{ 
    if(_operandStack == nil) _operandStack = [[NSMutableArray alloc] init];  
    return _operandStack; 
}

- (void)pushOperand:(double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]]; 
 
}
- (double)popOperand
{
    NSNumber *objectNumber = [self.operandStack lastObject];
    if (objectNumber) [self.operandStack removeLastObject]; 
    return [objectNumber doubleValue]; 
}

- (double)performOperation:(NSString*)operation
{
    double result = 0; 
    
    if([operation isEqual:@"*"])  
    { 
        result = [self popOperand] * [self popOperand]; 
    }
    else if ([operation isEqual:@"/"]) 
    {
        double divisor = [self popOperand]; 
        result = [self popOperand] / divisor; 
    } 
    return result; 
}



@end
