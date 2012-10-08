//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Brandon Millman on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *secondaryDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variableDisplay;
@end
