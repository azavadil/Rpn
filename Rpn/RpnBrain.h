//
//  RpnBrain.h
//  Rpn
//
//  Created by athony on 5/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RpnBrain : NSObject

- (void)pushOperand:(double)operand; 
- (void)pushVariable:(NSString*)variable; 
- (double)performOperation:(NSString*)operation; 
- (void) clearProgramStack;

@property (readonly) id program;


//eval the top item on stack
+ (double)runProgram:(id)program; 
+ (NSString *)descriptionOfProgram:(id)program; 
+ (NSSet *)variablesUsedInProgram:(id)program; 


@end
