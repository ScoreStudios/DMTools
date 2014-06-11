//
//  RollViewController.h
//  DM Tools
//
//  Created by hamouras on 04/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiceViewController.h"

@class RollEntry;
@protocol RollViewControllerDelegate;

@interface RollViewController : UITableViewController<DiceViewDelegate>
{
	NSMutableArray *				_rollArray;
	id<RollViewControllerDelegate>	_delegate;
}

@property (nonatomic, readonly) NSMutableArray * rollArray;
@property (nonatomic, assign) id<RollViewControllerDelegate> delegate;

- (id) initWithRollArray:(NSMutableArray *)rolls withDelegate:(id<RollViewControllerDelegate>)delegate;

- (IBAction) createRoll:(id)sender;

@end

@protocol RollViewControllerDelegate

- (void) rollViewControllerRerollInitiative:(RollViewController*)rollViewController;

@end
