//
//  SplitViewBarButtonItemPresenter.h
//  Rpn
//
//  Created by Anthony Zavadil on 6/5/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


/** Implementation note: SplitViewBarButtonItemPresenter
 * -----------------------------------------------------
 * the SplitViewBarButtonItemPresenter protocol is part of the implementation 
 * of the functionality for hiding/showing the master portion of a splitViewController. 
 * We need the detailVC to be able to add/remove a button so we add the 
 * functionality via a protocol. 
 */ 


#import <Foundation/Foundation.h>

@protocol SplitViewBarButtonItemPresenter <NSObject>

@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;

@end
