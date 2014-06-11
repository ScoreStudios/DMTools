//
//  InitiativeViewController.m
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import "InitiativeViewController.h"
#import "LibraryViewController.h"
#import "DMDataManager.h"
#import "DMEncounter.h"
#import "DMUnit.h"
#import "DMNumber.h"
#import "SessionsViewController.h"
#import "DMSettingsViewController.h"
#import "DamageViewController.h"
#import "RollViewController.h"
#import "DMUnitCell.h"
#import "DMToolsAppDelegate.h"
#import "DMUnitViewController.h"

#define kNoButtonIndex			-1
#define kPreviousButtonIndex	0
#define kRollButtonIndex		1
#define kDamageButtonIndex		2
#define kNextButtonIndex		3
#define kiPhoneNextButtonIndex	2

@interface InitiativeViewController ()
@property (nonatomic, retain) UIPopoverController *naviPopoverController;
@property (nonatomic, retain) UIPopoverController *toolbarPopoverController;

- (void) updateInitiative:(id)sender;
- (void) updateDamageButton;
- (void) editActionOverride:(id)sender;
@end


@implementation InitiativeViewController

@synthesize naviPopoverController = _naviPopoverController;
@synthesize toolbarPopoverController = _toolbarPopoverController;
@dynamic initiativeCount;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]) != nil)
	{
        // Custom initialization
		_rollArray = [[NSMutableArray alloc] init];
		
		_curInitiative = -1;
		_curInitiativeCount = 0;
	}
    return self;
}

- (void) createPopoverViewWithTitle:(NSString *)title withViewController:(UIViewController *)viewController
{
	if (_toolbarPopoverController)
	{
		[_toolbarPopoverController dismissPopoverAnimated:YES];
		[self popoverControllerDidDismissPopover:_toolbarPopoverController];
	}
	
	CGRect rect = CGRectMake( ( self.view.frame.size.width - 320.0f ) * 0.5f, 0.0f, 320.0f, 480.0f );
	SENavigationController *navi = [[SENavigationController alloc] initWithRootViewController:viewController];
	[navi setNavigationBarHidden:NO
						animated:YES];
	navi.delegate = self;
	navi.navigationBar.topItem.title = title;
	navi.contentSizeForViewInPopover = viewController.contentSizeForViewInPopover;
	self.toolbarPopoverController = [[[UIPopoverController alloc] initWithContentViewController:navi] autorelease];
	_toolbarPopoverController.delegate = self;
	// use the split controller's second view to avoid bug with popover's size for scrollable views
	UIView* inView = [[self.splitViewController.viewControllers objectAtIndex:1] view];
	[_toolbarPopoverController presentPopoverFromRect:rect
											   inView:inView
							 permittedArrowDirections:0
											 animated:YES];
	[navi release];
}

#pragma mark -
#pragma mark initiative functions

- (NSInteger) initiativeCount
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	return encounter.units.count;
}

- (BOOL) unitExists:(NSString *)name
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	for( DMUnit* unit in encounter.units )
	{
		if ([unit.name isEqualToString:name])
			return YES;
	}
	return NO;
}

- (void) sortByInitiative
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	[encounter.mutableUnits sortUsingSelector:@selector(compareInitiative:)];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
				  withRowAnimation:UITableViewRowAnimationFade];
}

- (NSUInteger) findInsertIndexForUnit:(DMUnit *)unit
{
	const NSInteger initiative = unit.initiative.value + unit.initiative.modifier;
	DMEncounter* encounter = [DMDataManager currentEncounter];
	NSUInteger index = 0;
	for( DMUnit* unit in encounter.units )
	{
		const NSInteger curInit = unit.initiative.value + unit.initiative.modifier;
		if (initiative > curInit)
			return index;
		++index;
	}
	
	return index;
}

- (void) addUnitToView:(DMUnit *)unit
{ 
	const NSUInteger insertIndex = [self findInsertIndexForUnit:unit];
	DMEncounter* encounter = [DMDataManager currentEncounter];
	[encounter.mutableUnits insertObject:unit
								 atIndex:insertIndex];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertIndex
												inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationFade];
	
	if (_curInitiative >= 0)
	{
		// update initiative values
		if (insertIndex <= _curInitiative)
		{
			++_curInitiative;
			[self updateInitiative:nil];
		}
		else if (insertIndex < _curInitiative + _curInitiativeCount)
		{
			_curInitiativeCount = insertIndex - _curInitiative;
			[self updateInitiative:nil];
		}
	}
	
	[DMUnitViewController setDefaultDisplayForUnit:unit];
}

- (void) addUniqueUnit:(DMUnit *)unit withInitiative:(NSInteger)initiative withModifier:(NSInteger)modifier
{
	NSInteger instance = 1;
	NSString *name = unit.name;
	// check init array for unique monster
	while ([self unitExists:name])
	{
		name = [NSString stringWithFormat:@"%@ %d", unit.name, ++instance];
	}
		
	DMUnit *newUnit = [unit copy];
	newUnit.name = name;
	newUnit.initiative.value = initiative;
	newUnit.initiative.modifier = modifier;

	[self addUnitToView:newUnit];
	
	[newUnit release];
}

- (void) addUnit:(DMUnit *)unit withInitiative:(NSInteger)initiative withModifier:(NSInteger)modifier
{
	DMUnit *newUnit = [unit copy];
	newUnit.initiative.value = initiative;
	newUnit.initiative.modifier = modifier;
	
	[self addUnitToView:newUnit];
	
	[newUnit release];
}

- (BOOL) previousInitiative
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	const NSInteger maxUnits = encounter.units.count;
	if (maxUnits == 0)
		return NO;
	if (_curInitiative <= 0
		&& _curRound == 0)
		return NO;	// can't step before start of encounter
	
	--_curInitiative;
	if (_curInitiative < 0)
	{
		_curInitiative = maxUnits - 1;
		--_curRound;
		DMEncounter* encounter = [DMDataManager currentEncounter];
		// update view's name
		self.navigationItem.title = [encounter.name stringByAppendingFormat:@" [%d]", _curRound];
	}
	_curInitiativeCount = 1;
	
	DMUnit *curmon = [encounter.units objectAtIndex:_curInitiative];
	for( NSInteger i = _curInitiative - 1 ; i >= 0 ; --i )
	{
		DMUnit *prevmon = [encounter.units objectAtIndex:i];
		if( prevmon == nil
			|| ![prevmon.name isEqualToString:curmon.name] )
			break;
		--_curInitiative;
		++_curInitiativeCount;
	}
	
	return YES;
}

- (BOOL) nextInitiative
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	const NSInteger maxUnits = encounter.units.count;
	if (maxUnits == 0)
		return NO;
	
	if (_curInitiative < 0)
		_curInitiative = 0;
	else
	{
		_curInitiative += _curInitiativeCount;
		if (_curInitiative >= maxUnits)
		{
			_curInitiative = 0;
			++_curRound;
			DMEncounter* encounter = [DMDataManager currentEncounter];
			// update view's name
			self.navigationItem.title = [encounter.name stringByAppendingFormat:@" [%d]", _curRound];
		}
	}
	_curInitiativeCount = 1;
	
	DMUnit *curmon = [encounter.units objectAtIndex:_curInitiative];
	NSArray *searchArray = [encounter.units subarrayWithRange:NSMakeRange(_curInitiative + 1, maxUnits - (_curInitiative + 1))];
	for( DMUnit *nextmon in searchArray )
	{
		if( nextmon == nil
			|| ![nextmon.name isEqualToString:curmon.name] )
			break;
		++_curInitiativeCount;
	}
	
	return YES;
}

- (void) updateInitiative:(id)sender
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	const NSInteger maxUnits = encounter.units.count;
	if (maxUnits == 0)
	{
		_curInitiative = -1;
		_curInitiativeCount = 0;
	}
	NSInteger selectedSegmentIndex = kNoButtonIndex;
	if (sender)
	{
		UISegmentedControl *segmentedControl = sender;
		selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
		if ([[UIDevice currentDevice] isIPhone]
			&& selectedSegmentIndex >= kDamageButtonIndex)	// damage button doesn't exist on iPhone
			++selectedSegmentIndex;
	}
	switch (selectedSegmentIndex)
	{
		case kPreviousButtonIndex:
		{
			if ([self previousInitiative])
				break;
			else
				return;
		}

		case kRollButtonIndex:
		{
			RollViewController *diceViewController = [[RollViewController alloc] initWithRollArray:_rollArray
																					  withDelegate:self];
			if ([[UIDevice currentDevice] isIPad])
			{
				[self createPopoverViewWithTitle:@"Roll"
							  withViewController:diceViewController];
			}
			else
				[self.navigationController pushViewController:diceViewController
													 animated:YES];
			[diceViewController release];
			return;
		}
			
		case kDamageButtonIndex:
		{
			if (maxUnits == 0)
				return;
			NSMutableArray *selectedArray = [NSMutableArray array];
			for (DMUnit *unit in encounter.units)
			{
				if (unit.selected)
					[selectedArray addObject:unit];
			}
			
			if (selectedArray.count == 0)
				return;
			
			DamageViewController *adv = [[DamageViewController alloc] initWithUnits:selectedArray];
			adv.delegate = self;
			if ([[UIDevice currentDevice] isIPad])
			{
				[self createPopoverViewWithTitle:@"Add Damage"
							  withViewController:adv];
			}
			else
				[self.navigationController pushViewController:adv
													 animated:YES];
			[adv release];
			return;
		}
			
		case kNextButtonIndex:
		{
			if ([self nextInitiative])
				break;
			else
				return;
		}
			
		case kNoButtonIndex:
			break;
			
		default:
			return;
	}
	
	if (_curInitiative >= 0
		&& _curInitiativeCount)
	{
		NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
		NSInteger cellCount = visibleCells.count;
		if (cellCount)
		{
			NSIndexPath *startCell = [visibleCells objectAtIndex:0]; 
			NSIndexPath *endCell = [visibleCells objectAtIndex:cellCount - 1];
			
			NSInteger startIndex = [startCell indexAtPosition:1];
			NSInteger endIndex = [endCell indexAtPosition:1];
			
			if (endIndex - startIndex > _curInitiativeCount) 
			{
				NSInteger endInitiative = _curInitiative + _curInitiativeCount - 1;
				if (_curInitiative <= startIndex)
				{
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_curInitiative
																inSection:0];
					[self.tableView scrollToRowAtIndexPath:indexPath
										  atScrollPosition:UITableViewScrollPositionTop
												  animated:YES];
				}
				if (endInitiative >= endIndex)
				{
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:endInitiative
																inSection:0];
					[self.tableView scrollToRowAtIndexPath:indexPath
										  atScrollPosition:UITableViewScrollPositionBottom
												  animated:YES];
				}
			}
			else
			{
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_curInitiative
															inSection:0];
				[self.tableView scrollToRowAtIndexPath:indexPath
									  atScrollPosition:UITableViewScrollPositionTop
											  animated:YES];
			}
		}
	}
		
	[self.tableView reloadData];
}

- (void) updateDamageButton
{
	if ([[UIDevice currentDevice] isIPad])
	{
		BOOL enableDamage = NO;
		DMEncounter* encounter = [DMDataManager currentEncounter];
		for (DMUnit *curUnit in encounter.units)
		{
			if (curUnit.selected)
			{
				enableDamage = YES;
				break;
			}
		}
		
		UISegmentedControl *segmentedControl = (UISegmentedControl *) _initiativeButton.customView;
		[segmentedControl setEnabled:enableDamage
				   forSegmentAtIndex:kDamageButtonIndex];
	}
}

- (void) reloadData
{
	_curInitiative = -1;
	_curInitiativeCount = 0;
	_curRound = 0;
	DMEncounter* encounter = [DMDataManager currentEncounter];
	// set view's name
	self.navigationItem.title = [encounter.name stringByAppendingString:@" [0]"];
	[self.tableView reloadData];
	
	[self updateDamageButton];
}

- (void) clearTable
{
	_curInitiative = -1;
	_curInitiativeCount = 0;
	_curRound = 0;
	DMEncounter* encounter = [DMDataManager currentEncounter];
	[encounter.mutableUnits removeAllObjects];
	// set view's name
	self.navigationItem.title = [encounter.name stringByAppendingString:@" [0]"];
	[self.tableView reloadData];
	
	[self updateDamageButton];
}

- (void) clearAll
{
	[self clearTable];
	self.tableView.tableHeaderView = nil;
	// disable editing by performing the edit action
	[self performSelector:_editActionOriginal
			   withObject:self.navigationItem.rightBarButtonItem];
}

- (void) clearAllRequest
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Table"
													message:@"Are you sure you want to clear the initiative table?"
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes", nil];
	[alert show];
	[alert release];
}

- (void) saveEncounter:(id)sender
{
	DMTextEditView *textEditView = [DMTextEditView textEditViewWithTitle:@"Save Encounter"
														 titleIsReadOnly:YES
																withText:@""];
	textEditView.delegate = self;
	[textEditView show];
}

- (void) editActionOverride:(id)sender
{
	NSArray *visibleCells = [self.tableView visibleCells];

	if (self.tableView.tableHeaderView)
	{
		self.tableView.tableHeaderView = nil;

		// hide initiative labels
		for( DMUnitCell *cell in visibleCells )
		{
			cell.initiative.alpha = 0.0f;
		}
	}
	else
	{
		UISegmentedControl *clearButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Clear All"]];
		clearButton.segmentedControlStyle = UISegmentedControlStyleBar;
		clearButton.momentary = YES;
		[clearButton addTarget:self
						action:@selector(clearAllRequest)
			  forControlEvents:UIControlEventValueChanged];
		self.tableView.tableHeaderView = clearButton;
		[clearButton release];

		[UIView beginAnimations:nil
						context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.5f];
		// show initiative labels
		for( DMUnitCell *cell in visibleCells )
		{
			cell.initiative.alpha = 1.0f;
		}
		[UIView commitAnimations];
	}
	
	[self performSelector:_editActionOriginal
			   withObject:self.navigationItem.rightBarButtonItem];
}

#pragma mark -
#pragma mark DMTextEditViewDelegate functions

- (void) textEditViewDone:(DMTextEditView *)textEditView withTitle:(NSString *)title withText:(NSString *)text
{
	if( [DMDataManager canSaveEncounterWithName:text] )
	{
		DMEncounter* encounter = [DMDataManager currentEncounter];
		[DMDataManager saveEncounter:encounter
							withName:text];
		
		DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
		[appDelegate.sessionsViewController reloadData];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Encoutner"
														message:[NSString stringWithFormat:@"An encounter named %@ already exists", text]
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) textEditViewCancelled:(DMTextEditView *)textEditView
{
}

#pragma mark -
#pragma mark UIAlertViewDelegate functions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) // cancel button
		return;
	
	[self clearAll];
}

#pragma mark -
#pragma mark damage/roll delegate function

- (void) rollViewControllerRerollInitiative:(RollViewController *)rollViewController
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	for( DMUnit* unit in encounter.units )
	{
		unit.initiative.value = (rand() % 20 + 1);
	}
	[self sortByInitiative];
	
	[self.navigationController popViewControllerAnimated:YES]; 
}

- (void) addedDamageFromViewController:(DamageViewController *)damageView toUnits:(NSArray *)units
{
	const NSInteger count = units.count;
	for (NSInteger i = 0 ; i < count ; ++i)
	{
		DMUnit *unit = [units objectAtIndex:i];
		if (unit.selected)
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i
														inSection:0];
			DMUnitCell *cell = (DMUnitCell *) [self.tableView cellForRowAtIndexPath:indexPath];
			cell.accessoryButton.selected = NO;
			unit.selected = NO;
		}
	}
	[self.tableView reloadData];
	damageView.delegate = nil;
	
	if ([[UIDevice currentDevice] isIPad])
	{
		[_toolbarPopoverController dismissPopoverAnimated:YES];
		[self popoverControllerDidDismissPopover:_toolbarPopoverController];
	}
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (void) unitViewController:(DMUnitViewController *)unitViewController finishedEditingUnit:(DMUnit *) unit
{
	if( unit.isDirty )
	{
		DMEncounter* encounter = [DMDataManager currentEncounter];
		const NSUInteger index = [encounter.units indexOfObjectIdenticalTo:unit];
		if( index != NSNotFound )
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index
																							   inSection:0]]
								  withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void) unitViewController:(DMUnitViewController *)unitViewController refreshUnit:(DMUnit *) unit
{
	if( unit.isDirty )
	{
		DMEncounter* encounter = [DMDataManager currentEncounter];
		const NSUInteger index = [encounter.units indexOfObjectIdenticalTo:unit];
		if( index != NSNotFound )
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index
																							   inSection:0]]
								  withRowAnimation:UITableViewRowAnimationNone];
	}
}

#pragma mark -
#pragma mark navigation view controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	viewController.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
}

#pragma mark -
#pragma mark table view support

- (void) accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
	
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}


- (void) proneButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
	// TODO: fix this state
#if 0
	NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
	
	DMRuntimeUnit *unit = [initiativeArray objectAtIndex:[indexPath indexAtPosition:1]];
	if (unit.stateFlags & eUnitStateProne)
		unit.stateFlags &= ~eUnitStateProne;
	else
		unit.stateFlags |= eUnitStateProne;
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
#endif
}

- (void) statesButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
	
	DMEncounter* encounter = [DMDataManager currentEncounter];
	DMUnit *unit = [encounter.units objectAtIndex:[indexPath indexAtPosition:1]];
	encounter.dirty = YES;
	unit.selected = YES;
	
	DamageViewController *adv = [[DamageViewController alloc] initWithUnits:[NSArray arrayWithObject:unit]];
	adv.delegate = self;
	if ([[UIDevice currentDevice] isIPad])
	{
		[self createPopoverViewWithTitle:@"Add Damage"
					  withViewController:adv];
	}
	else
		[self.navigationController pushViewController:adv
											 animated:YES];
	[adv release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"DMUnitCell";
    DMUnitCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		const BOOL isIPad = [[UIDevice currentDevice] isIPad];
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:isIPad ? @"DMUnitCellHD" : @"DMUnitCell"
															owner:nil
														  options:nil];
		cell = [nibObjects objectAtIndex:0];
	}
	
	// Set up the cell...
	NSInteger row = [indexPath indexAtPosition:1];
	DMEncounter* encounter = [DMDataManager currentEncounter];
	DMUnit *unit = [encounter.units objectAtIndex:row];

	[cell setupWithUnit:unit
		 forActiveTable:YES];
	[cell.statusButton addTarget:self
						  action:@selector(statesButtonTapped:withEvent:)
				forControlEvents:UIControlEventTouchUpInside];
	cell.accessoryButton.selected = unit.selected;
	[cell.accessoryButton addTarget:self
							 action:@selector(accessoryButtonTapped:withEvent:)
	 forControlEvents:UIControlEventTouchUpInside];

	return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSInteger fromrow = [fromIndexPath indexAtPosition:1];
	NSInteger torow = [toIndexPath indexAtPosition:1];
	if (fromrow == torow) {
		return;
	}
	DMEncounter* encounter = [DMDataManager currentEncounter];
	//	[self.initArray exchangeObjectAtIndex:fromrow withObjectAtIndex:torow];
	DMUnit *moving = [[encounter.units objectAtIndex:fromrow] retain];
	[encounter.mutableUnits removeObjectAtIndex:fromrow];
	[encounter.mutableUnits insertObject:moving
								 atIndex:torow];
	[moving release];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath indexAtPosition:1];
	DMEncounter* encounter = [DMDataManager currentEncounter];
	DMUnit *unit = [encounter.units objectAtIndex:row];
	if (row >= _curInitiative
		&& row < _curInitiative + _curInitiativeCount)
		cell.backgroundColor = unit.HP.value > 0 ? [UIColor lightGrayColor] : [UIColor yellowColor];
	else
		cell.backgroundColor = unit.HP.value > 0 ? [UIColor whiteColor] : [UIColor orangeColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	DMEncounter* encounter = [DMDataManager currentEncounter];
	return encounter.units.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath indexAtPosition:1];
	DMEncounter* encounter = [DMDataManager currentEncounter];
	DMUnit *unit = [encounter.units objectAtIndex:row];
	DMUnitViewController *uvc = [[DMUnitViewController alloc] initWithUnit:unit];
	uvc.delegate = self;
	if ([[UIDevice currentDevice] isIPad])
	{
		[self createPopoverViewWithTitle:unit.name
					  withViewController:uvc];
	}
	else
		[self.navigationController pushViewController:uvc
											 animated:YES];
	[uvc release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath indexAtPosition:1];
	DMEncounter* encounter = [DMDataManager currentEncounter];
	DMUnit *unit = [encounter.units objectAtIndex:row];
	encounter.dirty = YES;
	unit.selected ^= YES;
	DMUnitCell *cell = (DMUnitCell *) [self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryButton.selected = unit.selected;
	
	[self updateDamageButton];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// remove dummy item
	NSInteger row = indexPath.row;
	DMEncounter* encounter = [DMDataManager currentEncounter];
	[encounter.mutableUnits removeObjectAtIndex:row];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationFade];

	if (_curInitiative >= 0)
	{
		// update initiative values
		if (row < _curInitiative)
		{
			--_curInitiative;
			[self updateInitiative:nil];
		}
		else if (row >= _curInitiative
				 && row < _curInitiative + _curInitiativeCount)
		{
			--_curInitiativeCount;
			if (_curInitiativeCount == 0)
				[self nextInitiative];
			[self updateInitiative:nil];
		}
	}
}

#pragma mark -
#pragma mark popover support

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath)
		[self.tableView deselectRowAtIndexPath:indexPath
									  animated:YES];
	_toolbarPopoverController.delegate = nil;
	self.toolbarPopoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popover
{
	return YES;
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
	barButtonItem.title = aViewController.title;
	[self.navigationItem setLeftBarButtonItem:barButtonItem
									 animated:YES];
    self.naviPopoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	if ([aViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *naviController = (UINavigationController *) aViewController;
		naviController.navigationBar.barStyle = UIBarStyleBlack;
		naviController.toolbar.barStyle = UIBarStyleBlack;
	}
	[self.navigationItem setLeftBarButtonItem:nil
									 animated:YES];
    self.naviPopoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

- (void)createViewItems
{
	const BOOL isIPad = [[UIDevice currentDevice] isIPad];
	UISegmentedControl* segmentedControl;
	if( isIPad )
	{
		segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																	  [UIImage imageNamed:@"arrow_left"],
																	  @"Roll",
																	  @"Damage",
																	  [UIImage imageNamed:@"arrow_right"],
																	  nil]];
		[segmentedControl setWidth:60.0f
				 forSegmentAtIndex:kPreviousButtonIndex];
		[segmentedControl setWidth:100.0f
				 forSegmentAtIndex:kRollButtonIndex];
		[segmentedControl setWidth:100.0f
				 forSegmentAtIndex:kDamageButtonIndex];
		[segmentedControl setWidth:60.0f
				 forSegmentAtIndex:kNextButtonIndex];
		[segmentedControl setEnabled:NO
				   forSegmentAtIndex:kDamageButtonIndex];
	}
	else
	{
		segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																	  [UIImage imageNamed:@"arrow_left"],
																	  @"Roll",
																	  [UIImage imageNamed:@"arrow_right"],
																	  nil]];
		[segmentedControl setWidth:40.0f
				 forSegmentAtIndex:kPreviousButtonIndex];
		[segmentedControl setWidth:40.0f
				 forSegmentAtIndex:kRollButtonIndex];
		[segmentedControl setWidth:40.0f
				 forSegmentAtIndex:kiPhoneNextButtonIndex];
	}
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.tintColor = [UIColor colorWithRed:0.25f
												 green:0.25f
												  blue:0.25f
												 alpha:1.0f];
	segmentedControl.momentary = YES;
	[segmentedControl addTarget:self
						 action:@selector(updateInitiative:)
			   forControlEvents:UIControlEventValueChanged];
	
	_initiativeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	[segmentedControl release];
	
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																				target:self
																				action:@selector(saveEncounter:)];
	
	UIBarButtonItem* flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				target:nil
																				action:nil];
	if( isIPad )
	{
		self.toolbarItems = [NSArray arrayWithObjects:
							 saveButton,
							 flexButton,
							 _initiativeButton,
							 flexButton,
							 nil];
	}
	else
	{
		self.toolbarItems = [NSArray arrayWithObjects:
							 flexButton,
							 _initiativeButton,
							 flexButton,
							 nil];
		self.navigationItem.leftBarButtonItem = saveButton;
	}
	[flexButton release];
	[saveButton release];
	
	UIBarButtonItem* editButton = self.editButtonItem;
	_editActionOriginal = editButton.action;
	editButton.action = @selector(editActionOverride:);
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)releaseViewItems
{
	[_initiativeButton release];
	_initiativeButton = nil;
	
	self.toolbarItems = nil;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self createViewItems];
	
	self.tableView.rowHeight = [[UIDevice currentDevice] isIPad] ? 64.0f : 44.0f;
	self.tableView.allowsSelectionDuringEditing = YES;

 	// preload nib files
	if( [self.tableView respondsToSelector:@selector(registerNib:forCellReuseIdentifier:)] )
	{
		const BOOL isIPad = [[UIDevice currentDevice] isIPad];
		UINib* nib = [UINib nibWithNibName:isIPad ? @"DMUnitCellHD" : @"DMUnitCell"
									bundle:nil];
		[self.tableView registerNib:nib
			 forCellReuseIdentifier:@"DMUnitCell"];
	}

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	@try
	{
		_curRound = [userDefaults integerForKey:@"kInitRound"];
		
		NSData *rawInitData = [userDefaults dataForKey:@"Rolls"];
		if( rawInitData )
			[_rollArray addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:rawInitData]];
	}
	@catch (NSException * e)
	{
		[userDefaults removeObjectForKey:@"kInitRound"];
		[userDefaults removeObjectForKey:@"Rolls"];
	}

	if (_rollArray.count == 0)
	{
		RollEntry *initRoll = [[RollEntry alloc] init];
		initRoll.initiative = YES;
		[_rollArray addObject:initRoll];
		[initRoll release];
		
		RollEntry *d100 = [[RollEntry alloc] init];
		d100.percentage = YES;
		[_rollArray addObject:d100];
		[d100 release];
		
		RollEntry *d20 = [[RollEntry alloc] init];
		[d20 addDice:DiceType_D20];
		[_rollArray addObject:d20];
		[d20 release];
	}
	else
	{
		RollEntry *firstRoll = [_rollArray objectAtIndex:0];
		if( !firstRoll.initiative )
		{
			RollEntry *initRoll = [[RollEntry alloc] init];
			initRoll.initiative = YES;
			[_rollArray insertObject:initRoll
							 atIndex:0];
			[initRoll release];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	self.navigationController.tabBarItem.badgeValue = nil;
	[self.tableView reloadData];

	DMEncounter* encounter = [DMDataManager currentEncounter];
	// update view's name
	self.navigationItem.title = [encounter.name stringByAppendingFormat:@" [%d]", _curRound];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[DMDataManager saveCurrentEncounter];

	[userDefaults setInteger:_curRound
					  forKey:@"kInitRound"];
	if( _rollArray && _rollArray.count )
	{
		NSData *rawInitData = [NSKeyedArchiver archivedDataWithRootObject:_rollArray];
		[userDefaults setObject:rawInitData
						 forKey:@"Rolls"];
	}
	else
	{
		[userDefaults removeObjectForKey:@"Rolls"];
	}
	[userDefaults synchronize];

    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload
{
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self releaseViewItems];
    self.naviPopoverController = nil;
	self.toolbarPopoverController = nil;
	
	[_rollArray removeAllObjects];
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc
{
	[_initiativeButton release];
	[_rollArray release];
	[_naviPopoverController release];
	[_toolbarPopoverController release];
	
	[super dealloc];
}

@end
