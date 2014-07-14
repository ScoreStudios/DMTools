//
//  DMUnitViewController.m
//  DM Tools
//
//  Created by hamouras on 3/20/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMUnitViewController.h"
#import "SEAutoFocusView.h"
#import "DMToolsAppDelegate.h"
#import "DMUnitInfoCell.h"
#import "DMTableViewCell.h"
#import "DMDataManager.h"
#import "DMLibrary.h"
#import "DMUnit.h"
#import "DMGroup.h"
#import "DMNumber.h"
#import "DMHitPoints.h"

#define kFieldInfo			0
#define kFieldPlayer		1
#define kFieldLevel			2
#define kFieldHP			3
#define kFieldInitiative	4
#define kFieldMax			5

#define kControlPadding			6.0f
#define kHeaderPaddingX			12.0f
#define kHeaderPaddingY			4.0f
#define kRowHeight				40.0f
#define kInfoRowHeight			131.0f
#define kNotesRowHeight			120.0f

#define kInfoSectionIndex			0
#define kNotesSectionIndex			1
#define kGroupSectionsStartIndex	2

#define kEyeButtonSize		32.0f

#define DIRTY_CELL	0x80000000

static inline NSUInteger CreateCellTag( NSUInteger sectionIndex, NSUInteger rowIndex )
{
	return ( ( sectionIndex << 16 ) | rowIndex );
}

static inline NSUInteger SectionIndexFromTag( NSUInteger tag )
{
	return ( ( tag >> 16 ) & 0x7FFF );
}

static inline NSUInteger RowIndexFromTag( NSUInteger tag )
{
	return ( tag & 0xFFFF );
}

@interface DMSection : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;
@property (nonatomic, assign, getter = isEditable) BOOL editable;
@end

@implementation DMSection
@synthesize name = _name, itemCount = _itemCount, expanded = _expanded, editable = _editable;

- (void) dealloc
{
	[_name release];
	[super dealloc];
}
@end


@interface DMUnitViewController()
- (void) editActionOverride:(id)sender;
- (DMSection*) addSection:(NSUInteger)section withHeaderName:(NSString *)headerName withItemCount:(NSInteger)itemCount isEditable:(BOOL)editable;
@end

@implementation DMUnitViewController
@synthesize library = _library, unit = _unit, delegate = _delegate;

+ (void) setDefaultDisplayForUnit:(DMUnit*)unit
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* expandKey = [NSString stringWithFormat:@"expand:%@", unit.name];
	[userDefaults setInteger:1
					  forKey:expandKey];
	NSString* posKey = [NSString stringWithFormat:@"viewPos:%@", unit.name];
	[userDefaults setInteger:0
					  forKey:posKey];
}

- (id)initWithUnit:(DMUnit *)unit
{
	NSAssert( unit, @"unit shouldn't be nil" );
    if ((self = [super initWithStyle:UITableViewStyleGrouped]) != nil)
	{
        // Custom initialization
		_unit = [unit retain];
		
		const NSInteger sectionsCount = kGroupSectionsStartIndex + _unit.groups.count;
		_sections = [[NSMutableArray arrayWithCapacity:sectionsCount] retain];
		
		DMSection* section = [self addSection:kInfoSectionIndex
							   withHeaderName:@"Info"
								withItemCount:kFieldMax
								   isEditable:NO];
		section.expanded = YES;
		
		[self addSection:kNotesSectionIndex
		  withHeaderName:@"Notes"
		   withItemCount:1
			  isEditable:NO];
		
		for (NSInteger i = kGroupSectionsStartIndex ; i < sectionsCount ; ++i)
		{
			DMGroup *group = [_unit.groups objectAtIndex:i - kGroupSectionsStartIndex];
			[self addSection:i
			  withHeaderName:group.name
			   withItemCount:group.keys.count
				  isEditable:YES];
		}
		
		[self addSection:sectionsCount
		  withHeaderName:@"Add New Section"
		   withItemCount:0
			  isEditable:NO];
	}
    return self;
}

- (id)initWithLibrary:(DMLibrary*)library
{
	NSAssert( library, @"unit shouldn't be nil" );
    if ((self = [super initWithStyle:UITableViewStyleGrouped]) != nil)
	{
        // Custom initialization
		_unit = [library.baseTemplate retain];
		_library = [library retain];
		
		const NSInteger sectionsCount = kGroupSectionsStartIndex + _unit.groups.count;
		_sections = [[NSMutableArray arrayWithCapacity:sectionsCount] retain];
		
		DMSection* section = [self addSection:kInfoSectionIndex
							   withHeaderName:@"Info"
								withItemCount:kFieldMax
								   isEditable:NO];
		section.expanded = YES;
		
		[self addSection:kNotesSectionIndex
		  withHeaderName:@"Notes"
		   withItemCount:1
			  isEditable:NO];
		
		for (NSInteger i = kGroupSectionsStartIndex ; i < sectionsCount ; ++i)
		{
			DMGroup *group = [_unit.groups objectAtIndex:i - kGroupSectionsStartIndex];
			[self addSection:i
			  withHeaderName:group.name
			   withItemCount:group.keys.count
				  isEditable:YES];
		}
		
		[self addSection:sectionsCount
		  withHeaderName:@"Add New Section"
		   withItemCount:0
			  isEditable:NO];
	}
    return self;
}

- (void)dealloc
{
	[_sections release];
	[_unit release];
	[_library release];
	[_headerColor release];
	[_groupTypes release];
	[_openEye release];
	[_closedEye release];
	[super dealloc];
}

/*
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
 
	// Release any cached data, images, etc that aren't in use.
}
 */

#pragma mark - View lifecycle

- (void)loadView
{
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*)[[UIApplication sharedApplication] delegate];
	CGRect frame = appDelegate.rootViewController.view.frame;
	// replace our view with an auto-focus view
	SEAutoFocusTableView* autoFocusView = [[SEAutoFocusTableView alloc] initWithFrame:frame
																				style:UITableViewStyleGrouped];
	self.tableView = autoFocusView;
	[autoFocusView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *editButton = self.editButtonItem;
	_editActionOriginal = editButton.action;
	editButton.action = @selector(editActionOverride:);
	self.navigationItem.rightBarButtonItem = editButton;
	
	self.navigationItem.title = _unit.name;
	
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
	self.tableView.allowsSelectionDuringEditing = YES;
	
	_openEye = [[UIImage imageNamed:@"visible_on.png"] retain];
	_closedEye = [[UIImage imageNamed:@"visible_off.png"] retain];
	_groupTypes = [[NSArray arrayWithObjects:
					@"String",
					@"Boolean",
					@"Counter",
					@"Value",
					@"Value + Modifier",
					nil] retain];
	_headerColor = [[UIColor colorWithRed:0.9f
									green:0.9f
									 blue:0.8f
									alpha:1.0f] retain];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
	_editActionOriginal = nil;

	[_headerColor release];
	[_groupTypes release];
	[_openEye release];
	[_closedEye release];
	_headerColor = nil;
	_groupTypes = nil;
	_openEye = nil;
	_closedEye = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}

#pragma mark SEPushPopViewControllerProtocol functions

- (void)willBePushedByNavigationController:(UINavigationController *)navigationController
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString* expandKey = [NSString stringWithFormat:@"expand:%@", _unit.name];
	NSInteger expanded = [userDefaults integerForKey:expandKey];
	NSInteger bit = 0;
	for( DMSection* section in _sections )
	{
		if( expanded & (1 << bit) )
			section.expanded = YES;
		++bit;
		if( bit > 32 )
			break;
	}
	[userDefaults removeObjectForKey:expandKey];
	
	NSString* posKey = [NSString stringWithFormat:@"viewPos:%@", _unit.name];
	NSInteger position = [userDefaults integerForKey:posKey];
	if( position )
	{
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:RowIndexFromTag(position)
													inSection:SectionIndexFromTag(position)];
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
	}
	[userDefaults removeObjectForKey:posKey];
}

- (void)willBePoppedByNavigationController:(UINavigationController *)navigationController
{
	[self.tableView becomeFirstResponder];
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* expandKey = [NSString stringWithFormat:@"expand:%@", _unit.name];
	NSInteger expanded = 0;
	NSInteger bit = 0;
	for( DMSection* section in _sections )
	{
		if( section.isExpanded )
			expanded |= (1 << bit);
		++bit;
		if( bit > 32 )
			break;
	}
	[userDefaults setInteger:expanded
					  forKey:expandKey];
	
	NSString* posKey = [NSString stringWithFormat:@"viewPos:%@", _unit.name];
	NSInteger position = 0;
	NSArray* array = [self.tableView indexPathsForVisibleRows];
	if( array.count )
	{
		NSIndexPath* indexPath = [array objectAtIndex:0];
		position = CreateCellTag(indexPath.section, indexPath.row);
	}
	[userDefaults setInteger:position
					  forKey:posKey];
	
	[userDefaults synchronize];
	
	[_delegate unitViewController:self
			  finishedEditingUnit:_unit];
}

#pragma mark actions/events

- (void) editActionOverride:(id)sender
{
	// required so that textfield callbacks are called before tableEditing flag changes
	[self.tableView becomeFirstResponder];
	
	_tableEditing =!_tableEditing;
	[self performSelector:_editActionOriginal
			   withObject:self.navigationItem.rightBarButtonItem];
	
	[self.tableView reloadData];
}

- (void) tableViewCellImageAction:(DMTableViewCell *)tableViewCell
{
	const NSInteger tag = tableViewCell.tag;
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	NSAssert( sectionIndex >= kGroupSectionsStartIndex, @"invalid section index for tappable image view" );
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	NSAssert( rowIndex, @"invalid row index for tappable image view" );
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex
												inSection:sectionIndex];

	const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
	NSAssert( groupIndex < _unit.groups.count, @"invalid section index for tappable image view" );
	DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
	const NSUInteger itemIndex = rowIndex - 1;
	NSAssert( itemIndex < group.keys.count, @"invalid row index for tappable image view" );
	NSAssert( group.type != DMGroupTypeString, @"invalid group type for tappable imag" );
	if (group.type == DMGroupTypeBoolean )
	{
		DMBoolean *boolean = [group.items objectAtIndex:itemIndex];
		if( boolean.display == 0 )
		{
			// open the dialog to select image
			NSString *key = [group.keys objectAtIndex:itemIndex];
			NSArray* statusIcons = [DMDataManager statusIcons];
			const NSUInteger selectedIndex = Min( boolean.display, statusIcons.count - 1 );
			DMPickerEditView *pickerEditView = [DMPickerEditView pickerEditViewWithTitle:key
																		 titleIsReadOnly:NO
																			  withImages:statusIcons
																	   withSelectedIndex:selectedIndex];
			pickerEditView.tag = CreateCellTag( sectionIndex, rowIndex );
			pickerEditView.delegate = self;
			[pickerEditView show];
			return;
		}
		else
			boolean.display = 0;
	}
	else
	{
		DMNumber *number = [group.items objectAtIndex:itemIndex];
		// flip display flag
		number.display = !number.display;
	}
	_unit.dirty = YES;
	// set dirty cell tag
	tableViewCell.tag |= DIRTY_CELL;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	_unit.notes = textView.text;
	_unit.dirty = YES;
}

- (void) switchChangedEvent:(id)sender
{
	const NSInteger tag = [sender tag];
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	NSAssert( rowIndex, @"invalid row index for switch" );
	const NSUInteger itemIndex = rowIndex - 1;
	UISwitch *onoff = sender;
	
	if( sectionIndex >= kGroupSectionsStartIndex )
	{
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for switch" );
		// section is a DMGroup
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		NSAssert( group.type == DMGroupTypeBoolean, @"invalid group type for switch" );
		DMBoolean *boolean = [group.items objectAtIndex:itemIndex];
		boolean.value = onoff.on;
	}
	else if( sectionIndex == kInfoSectionIndex )
	{
		// process Info group
		NSAssert( itemIndex == kFieldPlayer, @"invalid item for switch event in Info group");
		_unit.player = onoff.on;
	}
	_unit.dirty = YES;
}

#pragma mark editor view delegate functions

- (void) avatarViewController:(DMAvatarViewController*)avatarViewController selectedAvatar:(UIImage*)avatar named:(NSString*)avatarName
{
	_unit.avatarName = avatarName;
	_unit.dirty = YES;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:kFieldInfo + 1
												inSection:kInfoSectionIndex];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	// set dirty cell tag
	cell.tag |= DIRTY_CELL;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
	
	if( [_delegate respondsToSelector:@selector(unitViewController:refreshUnit:)] )
	   [_delegate unitViewController:self
						 refreshUnit:_unit];
}

- (void) unitInfoCellHasModifiedUnit:(DMUnitInfoCell *)unitInfoCell
{
	_unit.dirty = YES;
}

- (BOOL) editView:(DMPickerEditView *)sectionEditView isValidTitle:(NSString*)title
{
	const NSInteger tag = sectionEditView.tag;
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	
	if( rowIndex )
	{
		NSAssert( sectionIndex >= kGroupSectionsStartIndex, @"invalid section index for editor view" );
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for editor view" );
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		const NSUInteger itemIndex = rowIndex - 1;
		NSString* curKey = [group.keys objectAtIndex:itemIndex];
		for( NSString* key in group.keys )
		{
			if( key != curKey
			   && [key isEqualToString:title] )
				return NO;
		}
	}
	else
	{
		DMSection* curSection = [_sections objectAtIndex:sectionIndex];
		for( DMSection* section in _sections )
		{
			if( section != curSection
			   && [section.name isEqualToString:title] )
				return NO;
		}
	}
	return YES;
}

- (void) pickerEditViewDone:(DMPickerEditView *)pickerEditView withTitle:(NSString *)title withSelectedIndex:(NSUInteger)selectedIndex
{
	const NSInteger tag = pickerEditView.tag;
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	NSAssert( sectionIndex >= kGroupSectionsStartIndex, @"invalid section index for editor view" );
	const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
	NSAssert( groupIndex < _unit.groups.count, @"invalid section index for editor view" );
	DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
	
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if( title.length == 0 )
		title = @"Empty";
	NSString* baseTitle = title;
	NSUInteger counter = 1;
	while( ![self editView:pickerEditView
			  isValidTitle:title] )
	{
		title = [baseTitle stringByAppendingFormat:@" %d", counter++];
	}
	
	if( rowIndex == 0 )
	{
		DMSection* section = [_sections objectAtIndex:sectionIndex];
		section.name = title;
		group.name = title;
		
		// only allow to change type when there are no items in the group
		if( !group.items.count )
			group.type = selectedIndex;
	}
	else
	{
		const NSUInteger itemIndex = rowIndex - 1;
		NSAssert(group.type == DMGroupTypeBoolean, @"invalid group type");
		
		[group.keys replaceObjectAtIndex:itemIndex
							  withObject:[[title copy] autorelease]];
		
		DMBoolean *boolean = [group.items objectAtIndex:itemIndex];
		boolean.display = selectedIndex;
	}
	
	_unit.dirty = YES;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex
												inSection:sectionIndex];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	// set dirty cell tag
	cell.tag |= DIRTY_CELL;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
}

- (void) pickerEditViewCancelled:(DMPickerEditView *)numberEditView
{
}

- (void) numberEditViewDone:(DMNumberEditView *)numberEditView withTitle:(NSString*)title withValue:(NSInteger)value withModifier:(NSInteger)modifier
{
	const NSInteger tag = numberEditView.tag;
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	NSAssert( rowIndex, @"invalid row index for editor view" );
	const NSUInteger itemIndex = rowIndex - 1;
	
	if( sectionIndex >= kGroupSectionsStartIndex )
 	{
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for editor view" );
		// section is a DMGroup
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		NSAssert( group.type == DMGroupTypeCounter
				 || group.type == DMGroupTypeValue
				 || group.type == DMGroupTypeValueModifier, @"invalid group type" );
		DMNumber *number = [group.items objectAtIndex:itemIndex];
		number.value = value;
		number.modifier = modifier;
		
		title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if( title.length )
		{
			if( [self editView:numberEditView
				  isValidTitle:title] )
			{
				[group.keys replaceObjectAtIndex:itemIndex
									  withObject:[[title copy] autorelease]];
			}
		}
	}
	else if( sectionIndex == kInfoSectionIndex )
	{
		switch (itemIndex)
		{
			case kFieldLevel:	// level
				_unit.level = value;
				break;
				
			case kFieldHP:	// HP
				_unit.HP.value = value;
				_unit.HP.maxValue = value;
				break;
				
			case kFieldInitiative:	// initiative
				_unit.initiative.value = value;
				_unit.initiative.modifier = modifier;
				break;
				
			default:
				NSAssert(0, @"invalid item for event in Info group");
				break;
		};
	}
	
	_unit.dirty = YES;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex
												inSection:sectionIndex];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	// set dirty cell tag
	cell.tag |= DIRTY_CELL;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
}

- (void) numberEditViewCancelled:(DMNumberEditView *)numberEditView
{
}

- (void) textEditViewDone:(DMTextEditView *)textEditView withTitle:(NSString *)title withText:(NSString *)text
{
	const NSInteger tag = textEditView.tag;
	const NSUInteger sectionIndex = SectionIndexFromTag(tag);
	const NSUInteger rowIndex = RowIndexFromTag(tag);
	NSAssert( rowIndex, @"invalid row index for editor view" );
	const NSUInteger itemIndex = rowIndex - 1;
	
	if( sectionIndex >= kGroupSectionsStartIndex )
 	{
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for editor view" );
		// section is a DMGroup
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		NSAssert( group.type == DMGroupTypeString, @"invalid group type" );
		
		title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if( title.length )
		{
			if( [self editView:textEditView
				  isValidTitle:title] )
			{
				[group.keys replaceObjectAtIndex:itemIndex
									  withObject:[[title copy] autorelease]];
			}
		}
		
		// also update the string
		[group.items replaceObjectAtIndex:itemIndex
							   withObject:[[text copy] autorelease]];
	}
	
	_unit.dirty = YES;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex
												inSection:sectionIndex];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	// set dirty cell tag
	cell.tag |= DIRTY_CELL;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
}

- (void) textEditViewCancelled:(DMTextEditView *)textEditView
{
}


#pragma mark create UI components

- (UISwitch*) createSwitchControlInContentRect:(CGRect)contentRect
{
	UISwitch* onoff = [[UISwitch new] autorelease];
	CGRect rect = onoff.frame;
	rect.origin.x = contentRect.size.width - (rect.size.width + kControlPadding);
	rect.origin.y = floorf( ( kRowHeight - rect.size.height ) * 0.5f );
	// setup volatile params
	onoff.frame = rect;
	onoff.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	// set event handler
	[onoff addTarget:self
			  action:@selector(switchChangedEvent:)
	forControlEvents:UIControlEventValueChanged];
	return onoff;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// enable the last section only when editing
	return _sections.count - ( _tableEditing ? 0 : 1 );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	DMSection* section = [_sections objectAtIndex:sectionIndex];
	NSUInteger count = 1;
	if( section.isExpanded )
	{
		count += section.itemCount;
		count += ( section.isEditable && _tableEditing ) ? 1 : 0;
	}
	return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	const NSUInteger rowIndex = indexPath.row;
	if( rowIndex == 0 )
		return kRowHeight;
	else
	{
		switch (sectionIndex)
		{
			case kInfoSectionIndex:
			{
				const NSUInteger itemIndex = rowIndex - 1;
				return ( itemIndex == kFieldInfo ) ? kInfoRowHeight : kRowHeight;
			}
			case kNotesSectionIndex:
				return kNotesRowHeight;
				
			default:
				return kRowHeight;
				break;
		};
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	const NSUInteger rowIndex = indexPath.row;
	const NSUInteger cellTag = CreateCellTag( sectionIndex, rowIndex );
	
	if( sectionIndex == kInfoSectionIndex
	   && rowIndex == kFieldInfo + 1 )
	{
		static NSString *InfoCellIdentifier = @"DMUnitInfoCell";
		DMUnitInfoCell* infoCell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
		if (infoCell == nil)
		{
			NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:InfoCellIdentifier
																owner:nil
															  options:nil];
			infoCell = [nibObjects objectAtIndex:0];
            infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
			[infoCell setInfoObject:_library ? _library : _unit];
			infoCell.viewController = self;
			infoCell.delegate = self;
			infoCell.tag = cellTag;
		}
		else
			[infoCell reloadAvatar];
		
		return infoCell;
	}
	else if( sectionIndex == kNotesSectionIndex
			&& rowIndex == 1 )
	{
		static NSString *NotesCellIdentifier = @"NotesCell";
		UITableViewCell* notesCell = [tableView dequeueReusableCellWithIdentifier:NotesCellIdentifier];
		if (notesCell == nil)
		{
			notesCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												reuseIdentifier:NotesCellIdentifier] autorelease];
			notesCell.contentView.contentMode = UIViewContentModeScaleToFill;
#ifdef CELL_DEBUG
			NSLog( @"created new notes cell at %d, %d", sectionIndex, rowIndex );
#endif
			notesCell.contentView.backgroundColor = [UIColor colorWithWhite:0.8f
																	  alpha:1.0f];
			CGRect contentRect = notesCell.contentView.bounds;
			contentRect.origin.x = kControlPadding;
			contentRect.origin.y = kControlPadding;
			contentRect.size.width -= kControlPadding * 2.0f;
			contentRect.size.height = kNotesRowHeight - kControlPadding * 2.0f;
			
			UITextView* textView = [[UITextView alloc] initWithFrame:contentRect];
			textView.textAlignment = UITextAlignmentLeft;
			// set text input params
			textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
			textView.autocorrectionType = UITextAutocorrectionTypeDefault;
			textView.keyboardType = UIKeyboardTypeDefault;
			textView.returnKeyType = UIReturnKeyDefault;
			textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			textView.text = _unit.notes;
			textView.delegate = self;
			// set tag to cell
			[notesCell.contentView addSubview:textView];
			// bind to cell
			textView.tag = cellTag;
			notesCell.tag = cellTag;
		}
		
		return notesCell;
	}
	else
	{
		static NSString *CellIdentifier = @"DMCell";
		DMTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
		{
			cell = [[[DMTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										   reuseIdentifier:CellIdentifier
											  withDelegate:self] autorelease];
			cell.contentView.contentMode = UIViewContentModeRight;
#ifdef CELL_DEBUG
			NSLog( @"created new cell at %d, %d", sectionIndex, rowIndex );
#endif
		}
		else
		{
			if( cell.tag == cellTag )
			{
#ifdef CELL_DEBUG
				NSLog( @"using unmodified cell at %d, %d", sectionIndex, rowIndex );
#endif
				return cell;
			}
		}
		
		static NSString* emptyString = @"";
		NSString* textLabel = emptyString;
		NSString* detailTextLabel = emptyString;
		UIImage* cellImage = nil;
		id control = nil;
		
		if( rowIndex == 0 )
		{
			DMSection* section = [_sections objectAtIndex:sectionIndex];
			cell.backgroundColor = _headerColor;
			cell.editingAccessoryType = ( sectionIndex == _sections.count - 1 )? UITableViewCellAccessoryNone : UITableViewCellAccessoryDetailDisclosureButton;
			textLabel = section.name;
			if( sectionIndex >= kGroupSectionsStartIndex
			   && sectionIndex < kGroupSectionsStartIndex + _unit.groups.count )
			{
				const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
				// section is a DMGroup
				DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
				detailTextLabel = [_groupTypes objectAtIndex:group.type];
			}
		}
		else
		{
			cell.backgroundColor = [UIColor whiteColor];
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			// Configure the cell...
			const NSUInteger itemIndex = rowIndex - 1;
			switch (sectionIndex)
			{
				case kInfoSectionIndex:
				{
					switch (itemIndex)
					{
						case kFieldPlayer:	// player
						{
							textLabel = @"Player";
							// reuse control if previous type is of the same class
							if( [cell.control isMemberOfClass:[UISwitch class]] )
								control = cell.control;
							else
								control = [self createSwitchControlInContentRect:cell.contentView.bounds];
							[control setOn:_unit.player];
							break;
						}
							
						case kFieldLevel:	// level
							textLabel = @"Level";
							detailTextLabel = [NSString stringWithFormat:@"%d", _unit.level];
							break;
							
						case kFieldHP:	// HP
							textLabel = @"HP";
							detailTextLabel = [_unit.HP toString];
							break;
							
						case kFieldInitiative:	// initiative
							textLabel = @"Initiative";
							detailTextLabel = [_unit.initiative totalToString];
							break;
					};
					break;
				}
					
				case kNotesSectionIndex:
					break;
					
				default:
				{
					const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
					NSAssert( groupIndex < _unit.groups.count, @"invalid section index for text field" );
					// section is a DMGroup
					DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
					if( itemIndex == group.keys.count )
					{
						textLabel = @"Add New Item";
					}
					else
					{
						textLabel = [group.keys objectAtIndex:itemIndex];
						switch (group.type)
						{
							case DMGroupTypeString:
							{
								detailTextLabel = [group.items objectAtIndex:itemIndex];
								break;
							}
								
							case DMGroupTypeBoolean:
							{
								DMBoolean *boolean = [group.items objectAtIndex:itemIndex];
								// reuse control if previous type is the same
								if( [cell.control isMemberOfClass:[UISwitch class]] )
									control = cell.control;
								else
									control = [self createSwitchControlInContentRect:cell.contentView.bounds];
								[control setOn:boolean.value];
								
								NSUInteger imageIndex = boolean.display;
								NSArray* statusIcons = [DMDataManager statusIcons];
								imageIndex = imageIndex < statusIcons.count ? imageIndex : 0;
								cellImage = [statusIcons objectAtIndex:imageIndex];
								break;
							}
								
							case DMGroupTypeValue:
							{
								DMNumber *number = [group.items objectAtIndex:itemIndex];
								detailTextLabel = [number valueToString];
								cellImage = number.display ? _openEye : _closedEye;
								break;
							}
								
							case DMGroupTypeValueModifier:
							{
								DMNumber *number = [group.items objectAtIndex:itemIndex];
								detailTextLabel = [number toString];
								cellImage = number.display ? _openEye : _closedEye;
								break;
							}
								
							case DMGroupTypeCounter:
							{
								DMNumber *number = [group.items objectAtIndex:itemIndex];
								detailTextLabel = [number valueToString];
								break;
							}
						};
					}
					break;
				}
					
			};
		}
		
		if( control != cell.control )
		{
			// remove previous control from superview
			if( cell.control )
				[cell.control removeFromSuperview];
			// set the new cell control
			cell.control = control;
			if( control )
			{
				[cell.contentView addSubview:control];
				// bind to cell
				[control setTag:cellTag];
			}
#ifdef CELL_DEBUG
			NSLog( @"changing type for cell at %d, %d", sectionIndex, rowIndex );
#endif
		}
		cell.imageView.image = cellImage;
		cell.imageViewInteractive = ( cellImage != nil );
		cell.textLabel.text = textLabel;
		cell.detailTextLabel.text = detailTextLabel;
		// set tag to cell
		cell.tag = cellTag;
		
		return cell;
	}
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	DMSection* section = [_sections objectAtIndex:sectionIndex];
	if( _tableEditing && sectionIndex == _sections.count - 1 )
		return YES;
	else
		return section.isEditable;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	DMSection* section = [_sections objectAtIndex:sectionIndex];
	if( !section.isEditable )
		return;
	const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
	NSAssert( groupIndex < _unit.groups.count, @"invalid section index for text field" );
	DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
	
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.tableView becomeFirstResponder];
		
		const NSUInteger rowIndex = indexPath.row;
		if( rowIndex )
		{
			const NSUInteger itemIndex = rowIndex - 1;
			// Delete the row from the data source
			[group.keys removeObjectAtIndex:itemIndex];
			[group.items removeObjectAtIndex:itemIndex];
			--section.itemCount;
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
		}
		else
		{
			// delete the whole section
			[_unit.mutableGroups removeObjectAtIndex:groupIndex];
			[_sections removeObjectAtIndex:sectionIndex];
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					 withRowAnimation:UITableViewRowAnimationFade];
		}
	}
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		if( _tableEditing && sectionIndex == _sections.count - 1 )
		{
			[self tableView:tableView
	didSelectRowAtIndexPath:indexPath];
		}
		else
		{
			NSString* name = @"New Item";
			id newItem = nil;
			switch (group.type)
			{
				case DMGroupTypeString:
					newItem = @"";
					break;
					
				case DMGroupTypeBoolean:
					newItem = [DMBoolean booleanWithValue:NO];
					break;
					
				case DMGroupTypeCounter:
				case DMGroupTypeValue:
				case DMGroupTypeValueModifier:
					newItem = [DMNumber numberWithValue:0
										   withModifier:0];
					break;
			};
			if( newItem )
			{
				[group.keys addObject:name];
				[group.items addObject:newItem];
				++section.itemCount;
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								 withRowAnimation:UITableViewRowAnimationFade];
				[self tableView:tableView
		didSelectRowAtIndexPath:indexPath];
			}
		}
    }   
	_unit.dirty = YES;
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	DMSection* section = [_sections objectAtIndex:sectionIndex];
	if( _tableEditing && sectionIndex == _sections.count - 1 )
		return UITableViewCellEditingStyleInsert;
	else if( section.isEditable )
	{
		const NSUInteger rowIndex = indexPath.row;
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for text field" );
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		return (rowIndex == 1 + group.keys.count) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
	}
	else
		return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	const NSUInteger rowIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil)
		return;
	
	[cell setSelected:NO
			 animated:YES];
	
	if( rowIndex == 0 )
	{
		if( _tableEditing && sectionIndex == _sections.count - 1 )
		{
			// handle special case of adding a new section
			DMGroup* group = [DMGroup new];
			group.name = @"New Section";
			group.type = DMGroupTypeValue;
			[_unit.mutableGroups addObject:group];
			[group release];
			_unit.dirty = YES;
			
			DMSection* section = [self addSection:sectionIndex
								   withHeaderName:@"New Section"
									withItemCount:0
									   isEditable:YES];
			section.expanded = YES;
			
			// set dirty cell tag
			cell.tag |= DIRTY_CELL;
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
			[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		}
		else
		{
			DMSection* sectionData = [_sections objectAtIndex:sectionIndex];
			sectionData.expanded = !sectionData.expanded;
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
		}
	}
	else
	{
		const NSUInteger itemIndex = rowIndex - 1;
		switch (sectionIndex)
		{
			case kInfoSectionIndex:
			{
				switch (itemIndex)
				{
					case kFieldInfo:	// info
						break;
						
					case kFieldPlayer:	// player
					{
						// flip value
						_unit.player ^= 1;
						// update control
						UISwitch *onoff = (UISwitch*) [cell.contentView viewWithTag:CreateCellTag( sectionIndex, rowIndex )];
						[onoff setOn:_unit.player
							animated:YES];
						_unit.dirty = YES;
						break;
					}
						
					case kFieldLevel:	// level
					{
						DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:@"Level"
																					 titleIsReadOnly:YES
																						   withValue:_unit.level];
						numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
						numberEditView.delegate = self;
						[numberEditView show];
						break;
					}
						
					case kFieldHP:	// HP
					{
						DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:@"HP"
																					 titleIsReadOnly:YES
																						 withCounter:_unit.HP.value];
						numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
						numberEditView.delegate = self;
						[numberEditView show];
						break;
					}
						
					case kFieldInitiative:	// initiative
					{
						DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:@"Initiative"
																					 titleIsReadOnly:YES
																						   withValue:_unit.initiative.value
																						withModifier:_unit.initiative.modifier
																					 hasModeSelector:NO];
						numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
						numberEditView.delegate = self;
						[numberEditView show];
						break;
					}
				};
				break;
			}
				
			case kNotesSectionIndex:
			{
				UITextView *textView = (UITextView*) [cell.contentView viewWithTag:CreateCellTag( sectionIndex, rowIndex )];
				[textView becomeFirstResponder];
				break;
			}
				
			default:
			{
				const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
				NSAssert( groupIndex < _unit.groups.count, @"invalid section index for text field" );
				DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
				if( itemIndex < group.keys.count )
				{
					switch (group.type)
					{
						case DMGroupTypeString:
						{
							NSString *key = [group.keys objectAtIndex:itemIndex];
							NSString *text = [group.items objectAtIndex:itemIndex];
							DMTextEditView *textEditView = [DMTextEditView textEditViewWithTitle:key
																				 titleIsReadOnly:NO
																						withText:text];
							textEditView.tag = CreateCellTag( sectionIndex, rowIndex );
							textEditView.delegate = self;
							[textEditView show];
							break;
						}
						case DMGroupTypeBoolean:
						{
							NSString *key = [group.keys objectAtIndex:itemIndex];
							DMBoolean *boolean = [group.items objectAtIndex:itemIndex];
							NSArray* statusIcons = [DMDataManager statusIcons];
							const NSUInteger selectedIndex = Min( boolean.display, statusIcons.count - 1 );
							DMPickerEditView *pickerEditView = [DMPickerEditView pickerEditViewWithTitle:key
																						 titleIsReadOnly:NO
																							  withImages:statusIcons
																					   withSelectedIndex:selectedIndex];
							pickerEditView.tag = CreateCellTag( sectionIndex, rowIndex );
							pickerEditView.delegate = self;
							[pickerEditView show];
							break;
						}
						case DMGroupTypeCounter:
						{
							NSString *key = [group.keys objectAtIndex:itemIndex];
							DMNumber *number = [group.items objectAtIndex:itemIndex];
							DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:key
																						 titleIsReadOnly:NO
																							 withCounter:number.value];
							numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
							numberEditView.delegate = self;
							[numberEditView show];
							break;
						}			
						case DMGroupTypeValue:
						{
							NSString *key = [group.keys objectAtIndex:itemIndex];
							DMNumber *number = [group.items objectAtIndex:itemIndex];
							DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:key
																						 titleIsReadOnly:NO
																							   withValue:number.value];
							numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
							numberEditView.delegate = self;
							[numberEditView show];
							break;
						}			
						case DMGroupTypeValueModifier:
						{
							NSString *key = [group.keys objectAtIndex:itemIndex];
							DMNumber *number = [group.items objectAtIndex:itemIndex];
							DMNumberEditView *numberEditView = [DMNumberEditView numberEditViewWithTitle:key
																						 titleIsReadOnly:NO
																							   withValue:number.value
																							withModifier:number.modifier
																						 hasModeSelector:NO];
							numberEditView.tag = CreateCellTag( sectionIndex, rowIndex );
							numberEditView.delegate = self;
							[numberEditView show];
							break;
						}			
					}
				}
				else if( _tableEditing )
				{
					// set dirty cell tag
					cell.tag |= DIRTY_CELL;
					// clicked the add button while editing
					// so call the callback to add a new item 
					[self tableView:tableView
				 commitEditingStyle:UITableViewCellEditingStyleInsert
				  forRowAtIndexPath:indexPath];
				}
				break;
			}
		};
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger sectionIndex = indexPath.section;
	const NSUInteger rowIndex = indexPath.row;
	
	if( rowIndex == 0
	   && sectionIndex >= kGroupSectionsStartIndex )
	{
		const NSUInteger groupIndex = sectionIndex - kGroupSectionsStartIndex;
		NSAssert( groupIndex < _unit.groups.count, @"invalid section index for text field" );
		DMGroup *group = [_unit.groups objectAtIndex:groupIndex];
		// edit section header
		DMPickerEditView *pickerEditView = [DMPickerEditView pickerEditViewWithTitle:group.name
																	 titleIsReadOnly:NO
																		 withStrings:_groupTypes
																   withSelectedIndex:group.type];
		pickerEditView.tag = CreateCellTag( sectionIndex, rowIndex );
		pickerEditView.delegate = self;
		[pickerEditView show];
	}
}

#pragma mark -
#pragma mark expand/collapse function

- (DMSection*) addSection:(NSUInteger)section
		   withHeaderName:(NSString *)headerName
			withItemCount:(NSInteger)itemCount
			   isEditable:(BOOL)editable
{
	DMSection *sectionData = [DMSection new];
	sectionData.name = headerName;
	sectionData.itemCount = itemCount;
	sectionData.expanded = NO;
	sectionData.editable = editable;
	[_sections insertObject:sectionData
					atIndex:section];
	[sectionData release];
	
	return sectionData;
}

@end
