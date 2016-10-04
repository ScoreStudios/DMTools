//
//  DamageViewController.m
//  DM Tools
//
//  Created by Paul Caristino on 6/11/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "DamageViewController.h"
#import "DMUnit.h"
#import "DMNumber.h"
#import "DMDataManager.h"
#import "DMStatusCell.h"

static NSInteger lastHP = 0;

static inline NSUInteger CreateCellTag( NSUInteger groupIndex, NSUInteger statusIndex )
{
	return ( ( groupIndex << 16 ) | statusIndex );
}

static inline NSUInteger GroupIndexFromTag( NSUInteger tag )
{
	return ( ( tag >> 16 ) & 0x7FFF );
}

static inline NSUInteger StatusIndexFromTag( NSUInteger tag )
{
	return ( tag & 0xFFFF );
}


@implementation DamageViewController

@synthesize HP = _HP;
@synthesize attribLabels = _attribLabels;
@synthesize attribValues = _attribValues;
@synthesize statesTableView = _statesTableView;
@synthesize delegate = _delegate;

+ (NSInteger) lastHP
{
	return lastHP;
}

+ (void) setLastHP:(NSInteger)HP
{
	lastHP = HP;
}

- (id) initWithUnits:(NSArray *)units
{
	NSAssert(units.count, @"units array is empty");
    if ((self = [super initWithNibName:@"DamageViewController"
								bundle:nil]))
	{
		self.navigationItem.title = units.count == 1 ? @"Single Damage" : @"Multiple Damage";
		_units = [units retain];
		_states = [NSMutableArray new];
    }
    return self;
}

- (void) applyDamage:(NSInteger)damage
{
	for( DMUnit *unit in _units )
	{
		unit.HP.value += damage;
		unit.dirty = YES;
	}
	
	[DamageViewController setLastHP:labs(damage)];
}

- (void) applyModifiers
{
	if( _units )
	{
		for( UITextField* textField in _attribValues )
		{
			const NSInteger tag = textField.tag;
			if( tag != -1 )
			{
				const NSUInteger groupIndex = GroupIndexFromTag( tag );
				const NSUInteger itemIndex = StatusIndexFromTag( tag );
				DMUnit* unit = [_units objectAtIndex:0];
				DMGroup* group = [unit.groups objectAtIndex:groupIndex];
				NSAssert( group.type == DMGroupTypeValue || group.type == DMGroupTypeValueModifier , @"invalid type" );
				DMNumber* number = [group.items objectAtIndex:itemIndex];
				number.modifier = [textField.text integerValue];
				unit.dirty = YES;
			}
		}
	}
}

- (IBAction) healButton:(id) sender
{
	_closing = YES;
	
	NSInteger currHP = [_HP.text intValue];
	[self applyDamage:currHP];
	[self applyModifiers];
	
	[_delegate addedDamageFromViewController:self
									 toUnits:_units];
	[_units release];
	_units = nil;
}

- (IBAction) damageButton:(id) sender
{
	_closing = YES;
	
	NSInteger currHP = [_HP.text intValue];
	[self applyDamage:-currHP];
	[self applyModifiers];
	
	[_delegate addedDamageFromViewController:self
									 toUnits:_units];
	[_units release];
	_units = nil;
}

- (IBAction) selectState:(id) sender
{
	UIButton *button = sender;
	const NSInteger tag = button.tag;
	if( tag != -1 )
	{
		const NSUInteger groupIndex = GroupIndexFromTag( tag );
		const NSUInteger statusIndex = StatusIndexFromTag( tag );
		DMUnit* unit = [_units objectAtIndex:0];
		DMGroup* group = [unit.groups objectAtIndex:groupIndex];
		NSAssert( group.type == DMGroupTypeBoolean , @"invalid type" );
		DMBoolean* boolean = [group.items objectAtIndex:statusIndex];
		boolean.value = !boolean.value;
		unit.dirty = YES;
		
		button.highlighted = boolean.value;
		
		CGRect rect = button.bounds;
		rect.origin.x += rect.size.width * 0.5f;
		rect.origin.y += rect.size.height * 0.5f;
		rect = [_statesTableView convertRect:rect
									fromView:button];
		NSIndexPath* indexPath = [_statesTableView indexPathForRowAtPoint:rect.origin];
		if( indexPath )
			[_statesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									withRowAnimation:UITableViewRowAnimationNone];
		else
			[_statesTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
							withRowAnimation:UITableViewRowAnimationNone];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	self.preferredContentSize = CGSizeMake(320.0, 480.0);
	
	_HP.text = [NSString stringWithFormat:@"%d", (int)lastHP];

	NSUInteger numAttribs = 0;
	const NSUInteger maxAttribs = _attribValues.count;

	[_states removeAllObjects];
	
	if( _units.count == 1 )
	{
		NSArray* statusIcons = [DMDataManager statusIcons];
		const NSUInteger maxStatus = statusIcons.count;
		DMUnit* unit = [_units objectAtIndex:0];
		NSUInteger groupIndex = 0;
		for( DMGroup* group in unit.groups )
		{
			switch( group.type )
			{
				case DMGroupTypeBoolean:
				{
					NSUInteger index = 0;
					for( DMBoolean* boolean in group.items )
					{
						NSInteger displayIndex = boolean.display;
						if( displayIndex
						   && displayIndex < maxStatus )
						{
							const NSUInteger tag = CreateCellTag( groupIndex, index );
							NSNumber* num = [NSNumber numberWithInteger:tag];
							[_states addObject:num];
						}
						++index;
					}
					break;
				}
					
				case DMGroupTypeValue:
				case DMGroupTypeValueModifier:
					if( numAttribs < maxAttribs )
					{
						NSUInteger index = 0;
						for( DMNumber* number in group.items )
						{
							if( number.display )
							{
								NSString* labelName = [group.keys objectAtIndex:index];
								UILabel* attribLabel = [_attribLabels objectAtIndex:numAttribs];
								UITextField* attribValue = [_attribValues objectAtIndex:numAttribs];
								attribLabel.text = ( labelName.length <= 3 ) ? labelName : [labelName substringToIndex:3];
								attribLabel.hidden = NO;
								attribValue.text = [NSString stringWithFormat:@"%d", (int)number.modifier];
								attribValue.hidden = NO;
								attribValue.tag = CreateCellTag( groupIndex, index );

								++numAttribs;
								if( numAttribs == maxAttribs )
									break;
							}
							++index;
						}
					}
					break;
					
				default:
					break;
			};
			
			++groupIndex;
		}
	}
	
	_statesTableView.hidden = ( _states.count == 0 );
	while( numAttribs < maxAttribs )
	{
		UILabel* attribLabel = [_attribLabels objectAtIndex:numAttribs];
		UITextField* attribValue = [_attribValues objectAtIndex:numAttribs];
		attribLabel.hidden = YES;
		attribValue.hidden = YES;
		attribValue.tag = -1;
		++numAttribs;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[_HP becomeFirstResponder];
	[_HP selectAll:self];
	
	_closing = NO;

	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (!_closing)
	{
		[self applyModifiers];
		[_delegate addedDamageFromViewController:self
										 toUnits:_units];
		
		[_states removeAllObjects];
		[_units release];
		_units = nil;
	}
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
	[_states removeAllObjects];
}


- (void)dealloc {
	[_states release];
	[_HP release];
	[_attribValues release];
	[_attribLabels release];
	[_statesTableView release];
	[_units release];
    [super dealloc];
}

#pragma mark Table view delegate and source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ( _states.count + 1 ) / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *StatusCellIdentifier = @"DMStatusCell";
	DMStatusCell* statusCell = [tableView dequeueReusableCellWithIdentifier:StatusCellIdentifier];
	if (statusCell == nil)
	{
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:StatusCellIdentifier
															owner:nil
														  options:nil];
		statusCell = [nibObjects objectAtIndex:0];
		UIButton* button = [statusCell.buttons objectAtIndex:0];
		[button addTarget:self
				   action:@selector(selectState:)
		 forControlEvents:UIControlEventTouchUpInside];
		button = [statusCell.buttons objectAtIndex:1];
		[button addTarget:self
				   action:@selector(selectState:)
		 forControlEvents:UIControlEventTouchUpInside];
	}
	
	NSArray* statusIcons = [DMDataManager statusIcons];
	const NSUInteger rowIndex = indexPath.row;
	const NSUInteger maxStates = _states.count;
	for( NSUInteger i = 0 ; i < 2 ; ++i )
	{
		NSNumber* num = ( rowIndex * 2 + i < maxStates ) ? [_states objectAtIndex:rowIndex * 2 + i] : nil;
		UIButton* button = [statusCell.buttons objectAtIndex:i];
		UILabel* label = [statusCell.labels objectAtIndex:i];

		if( num )
		{
			const NSUInteger tag = num.integerValue;
			NSUInteger groupIndex = GroupIndexFromTag( tag );
			NSUInteger statusIndex = StatusIndexFromTag( tag );
			DMUnit* unit = [_units objectAtIndex:0];
			DMGroup* group = [unit.groups objectAtIndex:groupIndex];
			NSAssert( group.type == DMGroupTypeBoolean, @"invalid group type" );
			NSString* key = [group.keys objectAtIndex:statusIndex];
			DMBoolean* boolean = [group.items objectAtIndex:statusIndex];
			
			button.tag = tag;
			[button setImage:[statusIcons objectAtIndex:boolean.display]
					forState:UIControlStateNormal];
			button.highlighted = boolean.value;
			button.hidden = NO;
			label.text = key;
			label.hidden = NO;
		}
		else
		{
			button.tag = -1;
			[button setImage:nil
					forState:UIControlStateNormal];
			button.hidden = YES;
			label.hidden = YES;
		}
	}
	
	return statusCell;
}


@end
