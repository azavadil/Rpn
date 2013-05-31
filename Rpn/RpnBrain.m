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

+ (BOOL)isTwoOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"*", @"/", @"+", @"-", nil]; 
    return [operationSet containsObject:operation]; 
}

+ (BOOL)isOneOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"sqrt", @"sin", @"cos", nil]; 
    return [operationSet containsObject:operation]; 
}

+ (BOOL)isNoOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"π", nil]; 
    return [operationSet containsObject:operation]; 
}


- (id) program { 
    return [self.programStack copy]; 
}

+ (NSString *)descriptionOfProgramAux:(id)program accParam:(NSString*)accumulator
{
    if ([program count] == 0) {
        return accumulator; 
    } else { 
        id topOfStack = [program lastObject]; 
        [program removeLastObject]; 
        if([self isTwoOperand:topOfStack])
        {   
            NSAssert( [program count] > 1, @"program should have at least 2 operands"); 
            double arg1 = [[program lastObject] doubleValue]; 
            double arg2 = [[program lastObject] doubleValue]; 
            [program removeLastObject]; 
            [program removeLastObject]; 
            accumulator = [accumulator stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@",arg1, topOfStack, arg2]]; 
            [self descriptionOfProgramAux:program accParam:accumulator]; 
        } 
        else if([self isOneOperand:topOfStack])
        { 
            NSAssert( [program count] > 0, @"program should have at least 1 operands") ; 
            double arg1 = [[program lastObject] doubleValue];
            [program removeLastObject]; 
            accumulator = [accumulator stringByAppendingString:[NSString stringWithFormat:@"%@(%@)",arg1, topOfStack]];
            [self descriptionOfProgramAux:program accParam:accumulator]; 
        }  
        else if([self isNoOperand:topOfStack]){ 
            accumulator = [accumulator stringByAppendingString:[NSString stringWithFormat:@"%@ ",topOfStack]];
            [self descriptionOfProgramAux:program accParam:accumulator]; 
        } 
    }
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *result; 
    if ([program isKindOfClass:[NSArray class]]) { 
        stack = [program mutableCopy]; 
        result = [self descriptionOfProgramAux:stack accParam:@""];    
    }
    return result; 
    
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
    
    NSMutableArray *stack;                      //1.autoset to nil
    if([program isKindOfClass:[NSArray class]]){ 
        stack = [program mutableCopy];          //2.
    }
    return [self popOperandOffStack:stack];     //3. 
}


@end
