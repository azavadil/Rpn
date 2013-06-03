//
//  GraphView.h
//  Rpn
//
//  Created by Anthony Zavadil on 6/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView; 

@protocol GraphViewDataSource

-(double)yCoordinateForGraphView:(double)xCoordinate; 
-(double)startOfRange; 
-(double)endOfRange; 

@end


@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id<GraphViewDataSource>dataSource; 

@property (nonatomic) CGFloat scale; 

@end
