//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Brandon Millman on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userIsEnteringFloatingPointNumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize secondaryDisplay = _secondaryDisplay;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userIsEnteringFloatingPointNumber = _userIsEnteringFloatingPointNumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _numberFormatter = [[NSNumberFormatter alloc] init];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [_numberFormatter setMaximumFractionDigits:10];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"illusion"]];
    
    [self clearPressed];
}



- (IBAction)testPressed:(UIButton *)sender
{
    NSString *test = [sender currentTitle];
    if ([test isEqualToString:@"Test 1"]) {
        self.testVariableValues = @{@"x" : @5 , @"y" : @6.7  , @"z" : @33.0};
    }
    else if ([test isEqualToString:@"Test 2"]) {
        self.testVariableValues = @{@"x" : @400, @"y" : @0, @"z" : @0.001 };
    }
    else if ([test isEqualToString:@"Test 3"]) {
        self.testVariableValues = nil;
    }
    [self setUpVariableDisplay];
    self.display.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]]];
    self.display.text = [CalculatorBrain descriptionOfProgram:self.brain.program withFormatter:self.numberFormatter];
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    
    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:digit];
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];

    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)variablePressed:(UIButton *)sender
{
    NSString *variable = [sender currentTitle];
    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:variable];
    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:@" "];
    self.display.text = variable;
    
    [self.brain pushVariable:variable];
//    self.display.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.secondaryDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program withFormatter:self.numberFormatter];

}

- (IBAction)pointPressed:(UIButton *)sender
{
    if (!self.userIsEnteringFloatingPointNumber) {
        self.userIsEnteringFloatingPointNumber = YES;
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
            self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:@"."];
        }
        else {
            self.userIsInTheMiddleOfEnteringANumber = YES;
            self.display.text = @"0.";
            self.secondaryDisplay.text = @"0.";
        }
    }
}

- (IBAction)enterPressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain pushOperand:[self.display.text doubleValue]];
        //self.display.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
//        self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:@" "];
        self.secondaryDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program withFormatter:self.numberFormatter];

    }
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userIsEnteringFloatingPointNumber = NO;
    
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    NSString *operation = [sender currentTitle];
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    if (([self.brain lastOperand] == 0 && [operation isEqualToString:@"/"]) ||
         ([self.brain lastOperand] < 0 && [operation isEqualToString:@"sqrt"])) {
        self.display.text = @"Error!";
        return;
    }
    
    self.display.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self.brain performOperation:operation]]];
    self.secondaryDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program withFormatter:self.numberFormatter];
//    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:@" "];
//    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:operation];
//    self.secondaryDisplay.text = [self.secondaryDisplay.text stringByAppendingString:@" "];
}

- (IBAction)clearPressed 
{
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userIsEnteringFloatingPointNumber = NO;
    [self.brain reset];
    self.display.text = @"0";
    self.secondaryDisplay.text = @"";
    self.variableDisplay.text = @"";
}

-(void)setUpVariableDisplay
{
    if (self.testVariableValues) {
        for (NSString * key in self.testVariableValues) {
            NSString *value = [self.numberFormatter stringFromNumber:[self.testVariableValues objectForKey:key]];
            self.variableDisplay.text = [NSString stringWithFormat:@"%@ %@ = %@", self.variableDisplay.text, key, value];
        }
    }
}

- (CalculatorBrain *)brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

@end
