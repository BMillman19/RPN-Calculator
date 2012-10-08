//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Brandon Millman on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

+ (NSSet *)variablesUsedInProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
+ (bool)isOperator:(NSString *)name;

- (void)reset;
- (double)lastOperand;
- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (double)performOperation:(NSString *)operation;

@property (readonly) id program;

@end


