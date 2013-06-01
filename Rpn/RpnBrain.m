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

- (void)pushVariable:(NSString*)variable
{
    [self.programStack addObject:variable]; 
    
}

- (void)removeLastItem
{
    id obj = [self.programStack lastObject]; 
    if(obj) [self.programStack removeLastObject]; 
}

/* performOperation */ 
- (double)performOperation:(NSString*)operation valParam:(NSDictionary *)valDict
{
    
    [self.programStack addObject:operation]; 
    return [RpnBrain runProgram:self.program usingVariableValues:valDict]; 
}

/* performOperation */ 
- (double)performOperation:(NSDictionary *)valDict
{
    return [RpnBrain runProgram:self.program usingVariableValues:valDict]; 
}


/* isTwoOperand */ 
+ (BOOL)isTwoOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"*", @"/", @"+", @"-", nil]; 
    return [operationSet containsObject:operation]; 
}

/* isOneOperand */ 
+ (BOOL)isOneOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"sqrt", @"sin", @"cos", nil]; 
    return [operationSet containsObject:operation]; 
}

/* isNoOperand */ 
+ (BOOL)isNoOperand:(NSString *)operation
{ 
    NSSet *operationSet = [NSSet setWithObjects:@"π", nil]; 
    return [operationSet containsObject:operation]; 
}

/* isOperation */ 
+ (BOOL)isOperation:(NSString*)operation
{
    NSSet *varSet = [NSSet setWithObjects:@"*","/",@"+",@"-",@"sin",@"cos",@"sqrt", nil]; 
    return [varSet containsObject:operation]; 
}

/* isVariable */ 
+ (BOOL)isVariable:(NSString*)operation
{
    NSSet *varSet = [NSSet setWithObjects:@"x",@"a",@"b", nil]; 
    return [varSet containsObject:operation]; 
}

/* program */ 
- (id) program { 
    return [self.programStack copy]; 
}

/* descriptionOfTopOfStack */ 
+ (NSString *)descriptionOfTopOfStack:(id)program 
{
    NSString *result = @""; 
    
    id topOfStack = [program lastObject]; 
    if(topOfStack) [program removeLastObject];
    
    if([self isTwoOperand:topOfStack])
    {   
        NSAssert( [program count] > 1, @"program should have at least 2 operands"); 
        NSString *backInDisplay = [self descriptionOfTopOfStack:program]; 
        result = [NSString stringWithFormat:@"(%@ %@ %@)",[self descriptionOfTopOfStack:program], 
                                                           topOfStack, 
                                                           backInDisplay]; 
    } 
    else if([self isOneOperand:topOfStack])
    { 
        NSAssert( [program count] > 0, @"program should have at least 1 operand") ; 
        result = [NSString stringWithFormat:@"%@(%@)",topOfStack, [self descriptionOfTopOfStack:program]];
    }  
    else if([self isNoOperand:topOfStack]){ 
        result = [NSString stringWithFormat:@"%@",topOfStack];
    } 
    else if([topOfStack isKindOfClass:[NSNumber class]])
    { 
        result = [NSString stringWithFormat:@"%@", topOfStack]; 
    }
    else if([self isVariable:topOfStack]){ 
        result = topOfStack; 
    }
        
    return result; 
   
}

/* descriptionOfProgram */ 
+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) { 
        stack = [program mutableCopy]; 
    }
    
    NSString *result; 
    result = [self descriptionOfTopOfStack:stack];  
    while([stack count] > 0){ 
        result = [NSString stringWithFormat:@"%@, %@", result, [self descriptionOfTopOfStack:stack]]; 
    }
    return result; 
}

/* clearProgramStack */
-(void) clearProgramStack 
{
    [self.programStack removeAllObjects]; 
}

/* popUnknownOffStack
 * This is a class method. the self in [self popOperandOffStack:stack]
 * is a class
 */ 

+ (double)popTopOffStack:(NSMutableArray*)stack
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
            result = [self popTopOffStack:stack] * [self popTopOffStack:stack]; 
        }
        else if([operation isEqualToString:@"+"])  
        { 
            result = [self popTopOffStack:stack] + [self popTopOffStack:stack]; 
        }
        else if([operation isEqualToString:@"-"])  
        { 
            result = [self popTopOffStack:stack] - [self popTopOffStack:stack]; 
        }
        else if ([operation isEqualToString:@"/"]) 
        {
            double divisor = [self popTopOffStack:stack]; 
            if(divisor) result = [self popTopOffStack:stack] / divisor; 
        } 
        else if([operation isEqualToString:@"sqrt"])  
        { 
            result = sqrt([self popTopOffStack:stack]); 
        }

        else if([operation isEqualToString:@"π"])  
        { 
            result = M_PI; 
        }
        else if([operation isEqualToString:@"cos"])  
        { 
            result = cos([self popTopOffStack:stack]); 
        }
        else if([operation isEqualToString:@"sin"])  
        { 
            result = sin([self popTopOffStack:stack]); 
        }
        else if([operation isEqualToString:@"+/-"])  
        { 
            result = -[self popTopOffStack:stack]; 
        }
        else if([operation isEqualToString:@"C"])  
        { 
            result = 0; 
            [stack removeAllObjects]; 
        }
        
    }
    
    return result; 

}


/* CLASS METHODS */



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
    return [self popTopOffStack:stack];     //3. 
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    
    NSAssert([program isKindOfClass:[NSArray class]], @"invalid input for runProgram. program must be array"); 
    
    program = [program mutableCopy]; 
    
    //iterate through program and replace variables with values
    int count = [program count]; 
    id currObj; 
    for (int i = 0; i < count; i++){ 
        currObj = [program objectAtIndex:i]; 
        if([self isVariable:currObj]){ 
            if([variableValues objectForKey:currObj]) {  
                [program replaceObjectAtIndex:i withObject:[variableValues objectForKey:currObj]]; 
            } else { 
                [program replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]]; 
            }
        }
    }
    
    return [self runProgram: program]; 
}
  
+ (NSSet *)variablesUsedInProgram:(id) program
{ 
    NSMutableSet *result = [[NSMutableSet alloc] initWithCapacity:3]; 
    if([program isKindOfClass:[NSArray class]]) {
        for(id obj in program) {
            if([obj isKindOfClass:[NSString class]]){ 
                if([RpnBrain isVariable:obj]){ 
                    [result addObject:obj]; 
                }
            }
        }
    }
    if([result count] > 0){ 
        return result; 
    } else { 
        return nil; 
    }
}
         
@end
