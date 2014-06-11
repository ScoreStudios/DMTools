//
//  DiceViewController.m
//  DM Tools
//
//  Created by hamouras on 05/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "DiceViewController.h"
#import "RollEntry.h"


@implementation DiceViewController

@synthesize modifierText;
@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithRoll:(RollEntry *)roll
{
	if ((self = [super initWithNibName:@"DiceViewController"
								bundle:nil]))
	{
		// Custom initialization
		if (roll)
		{
			currentRoll = [roll retain];
			for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
			{
				diceArray[i] = [currentRoll dice:i];
			}
		}
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
	{
		UILabel *diceLabel = (UILabel *) [self.view viewWithTag:(600 + i)];
		diceLabel.text = [NSString stringWithFormat:@"%dd%d", diceArray[i], [RollEntry diceValue:i]];
		UISegmentedControl *diceControl = (UISegmentedControl *) [self.view viewWithTag:(700 + i)];
		[diceControl setEnabled:diceArray[i] > 0
			  forSegmentAtIndex:0];
	}
	
	modifierText.text = [NSString stringWithFormat:@"%d", currentRoll.modifier];

	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);

	self.navigationItem.title = [RollEntry stringForDice:diceArray
											withModifier:currentRoll.modifier];
}

- (IBAction) diceCountChanged:(id)sender
{
	UISegmentedControl *diceControl = sender;
	NSInteger dice = diceControl.tag - 700;
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invalid dice type");
	diceArray[dice] += (diceControl.selectedSegmentIndex == 0) ? -1 : 1;
	[diceControl setEnabled:diceArray[dice] > 0
		  forSegmentAtIndex:0];
	UILabel *diceLabel = (UILabel *) [self.view viewWithTag:600 + dice]; 
	diceLabel.text = [NSString stringWithFormat:@"%dd%d", diceArray[dice], [RollEntry diceValue:dice]];
	
	self.navigationItem.title = [RollEntry stringForDice:diceArray
											withModifier:[modifierText.text integerValue]];
}

- (IBAction) modifierChanged:(id)sender
{
	self.navigationItem.title = [RollEntry stringForDice:diceArray
											withModifier:[modifierText.text integerValue]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (currentRoll)
	{
		for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
		{
			[currentRoll setDice:i
						 toValue:diceArray[i]];
		}
		currentRoll.modifier = [modifierText.text integerValue];
		
		[delegate diceView:self
			  modifiedRoll:currentRoll];
	}
	else
	{
		currentRoll = [[RollEntry alloc] init];
		for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
		{
			[currentRoll setDice:i
						 toValue:diceArray[i]];
		}
		currentRoll.modifier = [modifierText.text integerValue];
		
		[delegate diceView:self
				 addedRoll:currentRoll];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	[currentRoll release];
	currentRoll = nil;
}


- (void)dealloc
{
	[modifierText release];
	[currentRoll release];
    [super dealloc];
}


@end
