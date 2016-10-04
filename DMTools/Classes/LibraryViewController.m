//
//  LibraryViewController.m
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import "LibraryViewController.h"
#import "InitiativeViewController.h"
#import "DMDataManager.h"
#import "DMLibrary.h"
#import "DMUnit.h"
#import "DMNumber.h"
#import "UnitEntry.h"
#import "DMEncounter.h"
#import "DMSettings.h"
#import "SETableData.h"
#import "DMUnitCell.h"
#import "DMToolsAppDelegate.h"
#import "DMNumberEditView.h"

@interface LibraryViewController()

- (id)selectedObject;
- (NSUInteger)selectedObjectIndex;

@property(nonatomic, assign) DMSelectedGroup selectedGroup;
@property(nonatomic, assign) NSUInteger selectedItem;
@property(nonatomic, assign) NSUInteger selection;

@end

@implementation LibraryViewController

@synthesize initiativeViewController = _initiativeViewController;
@synthesize library = _library;
@dynamic selectedGroup, selectedItem, selection;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
    if (self)
	{
		_collationSelector = @selector(name);
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
	{
		_collationSelector = @selector(name);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.preferredContentSize = CGSizeMake(320.0, 480.0);

	_groupSelector = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																@"Players",
																@"Monsters",
																nil]];
	[_groupSelector addTarget:self
					   action:@selector(groupSelected:)
			 forControlEvents:UIControlEventValueChanged];

	// setup buttons
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				  target:self
																				  action:@selector(createItem:)];
	UIBarButtonItem* flexibleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					target:nil
																					action:nil];
	UIBarButtonItem *groupButton = [[UIBarButtonItem alloc] initWithCustomView:_groupSelector];
	self.toolbarItems = [NSArray arrayWithObjects:
						 createButton,
						 flexibleButton,
						 groupButton,
						 nil];
	[createButton release];
	[flexibleButton release];
	[groupButton release];
	
	// preload nib files
	if( [self.tableView respondsToSelector:@selector(registerNib:forCellReuseIdentifier:)] )
	{
		UINib* nib = [UINib nibWithNibName:@"DMUnitCell"
									bundle:nil];
		[self.tableView registerNib:nib
			 forCellReuseIdentifier:@"DMUnitCell"];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark SEPushPosViewController functions

- (void)willBePushedByNavigationController:(UINavigationController *)navigationController
{
	self.title = _library.name;
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* selectionKey = [NSString stringWithFormat:@"%@:selection", _library.name];
	id selectionObj = [userDefaults objectForKey:selectionKey];
	if( selectionObj )
		self.selection = [selectionObj integerValue];
	else
	{
		selectionKey = [NSString stringWithFormat:@"selection:%@", _library.name];
		selectionObj = [userDefaults objectForKey:selectionKey];
		DMSelection selection;
		if( selectionObj )
		{
			[userDefaults removeObjectForKey:selectionKey];
			DMOldSelection oldSelection;
			oldSelection.value = [selectionObj integerValue];
			// convert old format
			selection.group = ( oldSelection.group == 1 ) ? DMSelectedGroupPlayers : DMSelectedGroupMonsters;
			selection.player = oldSelection.player;
			selection.monster = oldSelection.monster;
		}
		else
		{
			selection.group = DMSelectedGroupMonsters;
			selection.player = 0;
			selection.monster = 0;
		}
		self.selection = selection.value;
	}
	
	_groupSelector.selectedSegmentIndex = self.selectedGroup;
	[self groupSelected:_groupSelector];
}

- (void)willBePoppedByNavigationController:(UINavigationController *)navigationController
{
	self.selectedItem = [self selectedObjectIndex];
	NSString* selectionKey = [NSString stringWithFormat:@"%@:selection", _library.name];
	[[NSUserDefaults standardUserDefaults] setInteger:self.selection
											   forKey:selectionKey];
	
	[DMDataManager saveLibrary:_library];
}

#pragma mark -
#pragma mark scroll position data functions

- (id)selectedObject
{
	NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
	if( visibleCells
	   && visibleCells.count )
	{
		NSIndexPath* middleVisible = [visibleCells objectAtIndex:visibleCells.count >> 1];
		return [[_sections objectAtIndex:middleVisible.section] objectAtIndex:middleVisible.row];
	}
	return  nil;
}

- (NSUInteger)selectedObjectIndex
{
	id object = [self selectedObject];
	NSArray* items;
	switch( _selection.group )
	{
		case kPlayersSection:
			items = _library.players;
			break;
			
		case kMonstersSection:
			items = _library.monsters;
			break;
			
		default:
			return NSNotFound;
	}
	
	return [items indexOfObjectIdenticalTo:object];
}

- (DMSelectedGroup) selectedGroup
{
	return _selection.group;
}

- (void)setSelectedGroup:(DMSelectedGroup)selectedGroup
{
	_selection.group = selectedGroup;
}

- (NSUInteger)selectedItem
{
	switch( _selection.group )
	{
		case kPlayersSection:
			return _selection.player;
			
		case kMonstersSection:
			return _selection.monster;
			
		default:
			return NSNotFound;
	}
}

- (void)setSelectedItem:(NSUInteger)selectedItem
{
	switch( _selection.group )
	{
		case kPlayersSection:
			_selection.player = selectedItem;
			break;
			
		case kMonstersSection:
			_selection.monster = selectedItem;
			break;
			
		default:
			break;
	}
}

- (NSUInteger)selection
{
	return _selection.value;
}

- (void)setSelection:(NSUInteger)selection
{
	_selection.value = selection;
}

#pragma mark -
#pragma mark data management functions

- (void) createUnitFromTemplate:(DMUnit*)unit asPlayer:(BOOL)isPlayer
{
	NSAssert( _currentUnit == nil, @"current unit exists" );
	
	// copy template and generate new name
	DMUnit *newUnit = [unit copy];
	BOOL nameIsUsed;
	NSString* newName;
	NSUInteger instanceIndex = 0;
	do {
		nameIsUsed = NO;
		if( instanceIndex )
			newName = [unit.name stringByAppendingFormat:@" %d", (unsigned int)instanceIndex];
		else
			newName = unit.name;
		
		for( DMUnit* curUnit in _library.players )
		{
			if( [curUnit.name isEqualToString:newName] )
			{
				nameIsUsed = YES;
				break;
			}
		}
		
		for( DMUnit* curUnit in _library.monsters )
		{
			if( [curUnit.name isEqualToString:newName] )
			{
				nameIsUsed = YES;
				break;
			}
		}
		++instanceIndex;
	} while( nameIsUsed );
	newUnit.name = newName;
	newUnit.player = isPlayer;
	
	[DMUnitViewController setDefaultDisplayForUnit:newUnit];
	DMUnitViewController *uvc = [[DMUnitViewController alloc] initWithUnit:newUnit];
	uvc.delegate = self;
	[self.navigationController pushViewController:uvc
										 animated:YES];
	[uvc release];
	
	[newUnit release];
}

- (void) editUnit:(DMUnit*)unit
{
	_currentUnit = unit;
	DMUnitViewController *uvc = [[DMUnitViewController alloc] initWithUnit:unit];
	uvc.delegate = self;
	[self.navigationController pushViewController:uvc
										 animated:YES];
	[uvc release];
}

- (IBAction) createItem:(id)sender
{
	switch( self.selectedGroup )
	{
		case kPlayersSection:
			[self createUnitFromTemplate:_library.baseTemplate
								asPlayer:YES];
			break;
			
		case kMonstersSection:
			[self createUnitFromTemplate:_library.baseTemplate
								asPlayer:NO];
			break;
			
		default:
			break;
	};
}

#pragma mark -
#pragma mark action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	BOOL cancelled = NO;
	DMUnit* unit = _currentUnit;
	_currentUnit = nil;
	
	NSAssert( unit, @"no unit selected" );
	switch( buttonIndex )
	{
		case 0:
			[self editUnit:unit];
			break;
			
		case 1:
			[self createUnitFromTemplate:unit
								asPlayer:unit.isPlayer];
			break;
			
		default:
			cancelled = YES;
			break;
	};

	[actionSheet dismissWithClickedButtonIndex:buttonIndex
									  animated:cancelled];
}

#pragma mark -
#pragma mark group selection event

- (IBAction)groupSelected:(id)sender
{
	if( self.selectedGroup != _groupSelector.selectedSegmentIndex )
	{
		// store current selected object before we change mode
		self.selectedItem = [self selectedObjectIndex];
		self.selectedGroup = (DMSelectedGroup)_groupSelector.selectedSegmentIndex;
	}
	
	NSArray* items;
	switch( self.selectedGroup )
	{
		case kPlayersSection:
			items = _library.players;
			break;
			
		case kMonstersSection:
			items = _library.monsters;
			break;
			
		default:
			return;
	};

	const NSUInteger selectedIndex = self.selectedItem;
	id selectedObject = ( selectedIndex < items.count ) ? [items objectAtIndex:selectedIndex] : nil;
	// update selection
	[self updateSectionsFromObjects:items
				 withSelectedObject:selectedObject
					 scrollAnimated:NO];
}

#pragma mark -
#pragma mark Table view delegate & data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	static NSString *UnitCellIdentifier = @"DMUnitCell";
	DMUnitCell *initCell = [tableView dequeueReusableCellWithIdentifier:UnitCellIdentifier];
	if (initCell == nil)
	{
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:UnitCellIdentifier
															owner:nil
														  options:nil];
		initCell = [nibObjects objectAtIndex:0];
	}
	
	DMUnit *unit = object;
	// Set up the cell...
	[initCell setupWithUnit:unit
			 forActiveTable:NO];
	return initCell;
}


// Override to support conditional editing of the table view.
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
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSMutableArray* items;
		switch( self.selectedGroup )
		{
			case kPlayersSection:
				items = _library.mutablePlayers;
				break;
				
			case kMonstersSection:
				items = _library.mutableMonsters;
				break;

			default:
				return;
		}
		id object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		[items removeObject:object];
		[self updateSectionsFromObjects:items
					 withSelectedObject:nil
						 scrollAnimated:NO];
	}   
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	id object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	_currentUnit = object;
	if ([DMSettings autoRoll:_currentUnit.player])
	{
		[self numberEditViewDone:nil
					   withTitle:@"Initiative"
					   withValue:(rand() % 20 + 1)
					withModifier:_currentUnit.initiative.modifier];
	}
	else
	{
		DMNumberEditView* numberEditView = [DMNumberEditView numberEditViewWithTitle:_currentUnit.name
																	 titleIsReadOnly:YES
																		   withValue:(rand() % 20 + 1)
																		withModifier:_currentUnit.initiative.modifier
																	 hasModeSelector:YES];
		numberEditView.delegate = self;
		[numberEditView show];
	}
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	_currentUnit = object;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_currentUnit.name
															 delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil, nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
	[actionSheet addButtonWithTitle:@"Edit Unit"];
	[actionSheet addButtonWithTitle:@"Copy Unit"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	[actionSheet setCancelButtonIndex:2];
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[actionSheet showInView:appDelegate.window.rootViewController.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark DMUnitViewController functions

- (void) unitViewController:(DMUnitViewController *)unitViewController finishedEditingUnit:(DMUnit *)unit
{
	if( unit.isDirty )
	{
		[unit retain];
		NSMutableArray* items = unit.player ? _library.mutablePlayers : _library.mutableMonsters;
		if( !_currentUnit )
			// new unit created
			[items insertSorted:unit];
		else
		{
			NSAssert( _currentUnit == unit, @"current unit mismatch" );
			
			NSUInteger index = [items indexOfObjectIdenticalTo:unit];
			if( index == NSNotFound )
			{
				NSMutableArray* oldItems = unit.player ? _library.mutableMonsters : _library.mutablePlayers;
				const NSUInteger oldIndex = [oldItems indexOfObjectIdenticalTo:unit];
				NSAssert( oldIndex != NSNotFound, @"unit doens't exist in table data" );

				// update selected item for old array
				const NSUInteger selectedItem = self.selectedItem;
				if( oldIndex <= selectedItem )
					self.selectedItem = selectedItem - 1;
				
				// first remove the item from old position and add it to the new position
				[oldItems removeObjectAtIndex:oldIndex];
				index = [items insertSorted:unit];
				NSAssert( index != NSNotFound, @"unit index not set properly" );

				// set new group and index
				self.selectedGroup = unit.player ? DMSelectedGroupPlayers : DMSelectedGroupMonsters;
				self.selectedItem = index;
				_groupSelector.selectedSegmentIndex = self.selectedGroup;
				// also need to update the user preferences
				NSString* selectionKey = [NSString stringWithFormat:@"%@:selection", _library.name];
				[[NSUserDefaults standardUserDefaults] setInteger:self.selection
														   forKey:selectionKey];
			}
			else
				[items sortUsingSelector:@selector(compare:)];
		}

		[self updateSectionsFromObjects:items
					 withSelectedObject:unit
						 scrollAnimated:YES];
		
		[unit release];
	}
	_currentUnit = nil;
}

#pragma mark -
#pragma mark InitiativePickerController delegate functions

- (void) numberEditViewDone:(DMNumberEditView *)numberEditView withTitle:(NSString*)title withValue:(NSInteger)value withModifier:(NSInteger)modifier
{
	NSAssert( _currentUnit, @"no unit selected" );
	if ([DMSettings uniqueNames])
		[_initiativeViewController addUniqueUnit:_currentUnit
								  withInitiative:value
									withModifier:modifier];
	else
		[_initiativeViewController addUnit:_currentUnit
							withInitiative:value
							  withModifier:modifier];
	
	if ([[UIDevice currentDevice] isIPhone])
	{
		UITabBarItem *initiativeItem = [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem];
		const NSInteger badgeValue = [initiativeItem.badgeValue integerValue];
		initiativeItem.badgeValue = [NSString stringWithFormat:@"%d", (int)badgeValue + 1];
	}
	_currentUnit = nil;
}

- (void) numberEditViewCancelled:(DMNumberEditView *)numberEditView
{
	NSAssert( _currentUnit, @"no unit selected" );
	_currentUnit = nil;
}

#pragma mark -
#pragma mark Memory management

// The designated initializer. Override to perform setup that is required before the view is loaded.
/*
- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]) != nil)
	{
	}
	return self;
}
*/

- (void) setLibrary:(DMLibrary *)library
{
	if( _library != library )
	{
		[_library release];
		_library = [library retain];
		
		_currentUnit = nil;
		[self groupSelected:_groupSelector];
	}
}

/*
 - (void)didReceiveMemoryWarning
 {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Relinquish ownership any cached data, images, etc. that aren't in use.
 }
 */

- (void)viewDidUnload
{
	[super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.toolbarItems = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.library = nil;
	[_groupSelector release];
	_groupSelector = nil;
}

- (void)dealloc
{
	[_library release];
    [_groupSelector release];
    [_initiativeViewController release];
	[_groupSelector release];
	[super dealloc];
}


@end

