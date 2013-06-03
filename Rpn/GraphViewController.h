//
//  GraphViewController.h
//  Rpn
//
//  Created by Anthony Zavadil on 6/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController

/* The model for the GraphView is a program
 * We make the property part of the public API
 * RpnViewController will set the program 
 * when the RpnViewController switches control over to the 
 * GraphViewController
 */ 

@property (nonatomic, strong) NSArray *currProgram; 

@end
