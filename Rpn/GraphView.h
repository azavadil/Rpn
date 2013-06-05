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
-(double)totalRangeDistance; 
-(BOOL)hasProgram; 

@end


@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id<GraphViewDataSource>dataSource; 

@property (nonatomic) CGFloat scale; 
@property (nonatomic) CGPoint panAdjustment; 
@property (nonatomic) CGPoint originAdjustment; 

/* include in the public API so clients are aware that 
 * graphView supports pinch recognition
 */ 
 
- (void)pinch:(UIPinchGestureRecognizer *)gesture; 
- (void)pan:(UIPanGestureRecognizer *)gesture; 
- (void)handleTaps:(UITapGestureRecognizer *)gesture;

@end
