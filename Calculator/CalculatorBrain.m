//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Brandon Millman on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

#pragma mark - Custom Accessors

- (id)program
{
    return [self.programStack mutableCopy];
}

- (NSMutableArray *)programStack
{
    if (_programStack == nil)
        _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

#pragma mark - Class methods

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]])
        for (id member in program) 
            if ([member isKindOfClass:[NSString class]])
                if ([self isOperator:member]) 
                    [result addObject:member];
    return result;
 
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack withVariables:variableValues];
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (NSString *)descriptionHelperOfProgram:(id)program withFormatter:(NSNumberFormatter *)formatter
{
    NSString *result;
    NSMutableArray *stack = program;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [formatter stringFromNumber:topOfStack];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([self isOperator:topOfStack])
        {
            NSString *operation = topOfStack;
            if ([operation isEqualToString:@"+"]) {
                result = [NSString stringWithFormat:@"(%@ + %@)", [self descriptionHelperOfProgram:stack withFormatter:formatter], [self descriptionHelperOfProgram:stack withFormatter:formatter] ];
            } else if ([@"*" isEqualToString:operation]) {
                result = [NSString stringWithFormat:@"(%@ * %@)", [self descriptionHelperOfProgram:stack withFormatter:formatter], [self descriptionHelperOfProgram:stack withFormatter:formatter] ];
            } else if ([operation isEqualToString:@"-"]) {
                NSString *subtrahend = [self descriptionHelperOfProgram:stack withFormatter:formatter];
                result = [NSString stringWithFormat:@"(%@ - %@)", [self descriptionHelperOfProgram:stack withFormatter:formatter], subtrahend];
            } else if ([operation isEqualToString:@"/"]) {
                NSString *divisor = [self descriptionHelperOfProgram:stack withFormatter:formatter];
                if (divisor) result = [NSString stringWithFormat:@"(%@ / %@)", [self descriptionHelperOfProgram:stack withFormatter:formatter], divisor];
            } else if ([operation isEqualToString:@"sin"]) {
                result = [NSString stringWithFormat:@"sin(%@)", [self descriptionHelperOfProgram:stack withFormatter:formatter]];
            } else if ([operation isEqualToString:@"cos"]) {
                result = [NSString stringWithFormat:@"cos(%@)", [self descriptionHelperOfProgram:stack withFormatter:formatter]];
            } else if ([operation isEqualToString:@"sqrt"]) {
                result = [NSString stringWithFormat:@"sqrt(%@)", [self descriptionHelperOfProgram:stack withFormatter:formatter]];
            } else if ([operation isEqualToString:@"π"]) {
                result = @"π";
            }
        }
        else
        {
            result = topOfStack;
        }
    }
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program withFormatter:(NSNumberFormatter *)formatter
{
    NSString *result = [self descriptionHelperOfProgram:program withFormatter:formatter];
    
    while ([program count] > 0)
    {
        result = [NSString stringWithFormat:@"%@, %@", [self descriptionHelperOfProgram:program withFormatter:formatter], result ];
    }
    
    return result;
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack withVariables:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([self isOperator:topOfStack])
        {
            NSString *operation = topOfStack;
            if ([operation isEqualToString:@"+"]) {
                result = [self popOperandOffProgramStack:stack withVariables:variableValues] + [self popOperandOffProgramStack:stack withVariables:variableValues];
            } else if ([@"*" isEqualToString:operation]) {
                result = [self popOperandOffProgramStack:stack withVariables:variableValues] * [self popOperandOffProgramStack:stack withVariables:variableValues];
            } else if ([operation isEqualToString:@"-"]) {
                double subtrahend = [self popOperandOffProgramStack:stack withVariables:variableValues];
                result = [self popOperandOffProgramStack:stack withVariables:variableValues] - subtrahend;
            } else if ([operation isEqualToString:@"/"]) {
                double divisor = [self popOperandOffProgramStack:stack withVariables:variableValues];
                if (divisor) result = [self popOperandOffProgramStack:stack withVariables:variableValues] / divisor;
            } else if ([operation isEqualToString:@"sin"]) {
                result = sin([self popOperandOffProgramStack:stack withVariables:variableValues]);
            } else if ([operation isEqualToString:@"cos"]) {
                result = cos([self popOperandOffProgramStack:stack withVariables:variableValues]);
            } else if ([operation isEqualToString:@"sqrt"]) {
                result = sqrt([self popOperandOffProgramStack:stack withVariables:variableValues]);
            } else if ([operation isEqualToString:@"π"]) {
                result = M_PI;
            }
        }
        else
        {
            NSString *variable = topOfStack;
            result = [variableValues valueForKey:variable] ? [[variableValues valueForKey:variable] doubleValue]: 0;
        }
    }
    
    return result;
}

+ (bool)isOperator:(NSString *)name
{
    return  ([name isEqualToString:@"*"] ||
              [name isEqualToString:@"+"] || 
              [name isEqualToString:@"-"] ||
              [name isEqualToString:@"/"] ||
              [name isEqualToString:@"sqrt"] ||
              [name isEqualToString:@"sin"] ||
              [name isEqualToString:@"cos"] ||
              [name isEqualToString:@"π"]);
}


#pragma mark - Instance methods

- (void)reset
{
    [self.programStack removeAllObjects];
}

-(double)lastOperand
{
    return [[self.programStack lastObject] doubleValue];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (id)popOperand
{
    NSNumber *operandObject = [self.programStack lastObject];
    if (operandObject) {
        [self.programStack removeLastObject];
    }
    return operandObject;
}

- (double)performOperation:(NSString *)operation
{    
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}



@end
