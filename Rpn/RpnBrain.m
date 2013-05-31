//
//  RpnBrain.m
//  Rpn
//
//  Created by athony on 5/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RpnBrain.h"

@interface RpnBrain()
@property (nonatomic, strong) NSMutableArray *programStack; 
@end


@implementation RpnBrain

@synthesize programStack = _programStack; 

- (NSMutableArray*)programStack
{ 
    if(_programStack == nil) _programStack = [[NSMutableArray alloc] init];  
    return _programStack; 
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]]; 
 
}

- (double)performOperation:(NSString*)operation
{
    
    [self.programStack addObject:operation]; 
    return [RpnBrain runProgram:self.program]; 
}

- (id) program { 
    return [self.programStack copy]; 
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"implement this in assignment 2"; 
}

-(void) clearProgramStack 
{
    [self.programStack removeAllObjects]; 
}

/* This is a class method. the self in [self popOperandOffStack:stack]
 * is a class
 */ 

+ (double)popOperandOffStack:(NSMutableArray*)stack
{
    /* 1. id because the item could be number or string (*,/,+ ...)
     */ 
    
    
    double result = 0; 
    
    id topOfStack = [stack lastObject];     //.1
    if(topOfStack) [stack removeLastObject]; 
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    { 
        result = [topOfStack doubleValue]; 
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    { 
        NSString *operation = topOfStack; 
        
        if([operation isEqualToString:@"*"])  
        { 
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack]; 
        }
        else if([operation isEqualToString:@"+"])  
        { 
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack]; 
        }
        else if([operation isEqualToString:@"-"])  
        { 
            result = [self popOperandOffStack:stack] - [self popOperandOffStack:stack]; 
        }
        else if ([operation isEqualToString:@"/"]) 
        {
            double divisor = [self popOperandOffStack:stack]; 
            if(divisor) result = [self popOperandOffStack:stack] / divisor; 
        } 
        else if([operation isEqualToString:@"sqrt"])  
        { 
            result = sqrt([self popOperandOffStack:stack]); 
        }

        else if([operation isEqualToString:@"π"])  
        { 
            result = M_PI; 
        }
        else if([operation isEqualToString:@"cos"])  
        { 
            result = cos([self popOperandOffStack:stack]); 
        }
        else if([operation isEqualToString:@"sin"])  
        { 
            result = sin([self popOperandOffStack:stack]); 
        }
        else if([operation isEqualToString:@"e"])  
        { 
            result = M_E; 
        }
        else if([operation isEqualToString:@"log"])  
        { 
            result = log([self popOperandOffStack:stack]); 
        }
        else if([operation isEqualToString:@"+/-"])  
        { 
            result = -[self popOperandOffStack:stack]; 
        }
        else if([operation isEqualToString:@"C"])  
        { 
            result = 0; 
            [stack removeAllObjects]; 
        }
        
    }
    
    return result; 

}


+ (double)runProgram:(id)program 
{
    /*
     * 1. in iOS4 has to say NSMutableArray *stack = nil
     * 2. stack is NSMutableArray, mutableCopy is id
     *    ok to assign id to NSMutableArray
     * 3. need a class method (because I'm in a class method)
     *    pops top items of stack and returns the items
     */
    
    NSMutableArray *stack;   //1.autoset to nil
    if([program isKindOfClass:[NSArray class]]){ 
        stack = [program mutableCopy];        //2.
    }
    return [self popOperandOffStack:stack];  //3. 
}


@end
