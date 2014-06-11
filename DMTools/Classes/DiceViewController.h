//
//  DiceViewController.h
//  DM Tools
//
//  Created by hamouras on 05/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEAutoInputViewController.h"
#import "RollEntry.h"

@protocol DiceViewDelegate;

@interface DiceViewController : SEAutoInputViewController
{
	UITextField *	modifierText;
	RollEntry *		currentRoll;
	NSInteger		diceArray[DiceType_Max];
	
	id<DiceViewDelegate>	delegate;
}

@property (nonatomic, retain) IBOutlet UITextField * modifierText;
@property (nonatomic, assign) id<DiceViewDelegate> delegate;

- (id)initWithRoll:(RollEntry *)roll;

- (IBAction) diceCountChanged:(id)sender;
- (IBAction) modifierChanged:(id)sender;

@end

@protocol DiceViewDelegate

@required
- (void) diceView:(DiceViewController *)diceView addedRoll:(RollEntry *)roll;
- (void) diceView:(DiceViewController *)diceView modifiedRoll:(RollEntry *)roll;

@end