//
//  NotesViewController.m
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteEntry.h"
#import "NoteViewController.h"
#import "DMSettings.h"
#import "SETableData.h"

@implementation NotesViewController

@synthesize notesTableData = _notesTableData;

- (void) createNote:(id)sender
{
	NoteViewController *amv = [[NoteViewController alloc] initWithNote:nil];
	amv.delegate = self;
	[self.navigationController pushViewController:amv
										 animated:YES];
	[amv release];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup buttons
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				  target:self
																				  action:@selector(createNote:)];
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
	self.navigationController.toolbarHidden = NO;
	self.toolbarItems = [NSArray arrayWithObject:createButton];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[createButton release];
	
	if (_notesTableData.sections.count)
	{
		NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _notesTableData.sections.count)];
		[self.tableView insertSections:(NSIndexSet *)sections
					  withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self saveData];
}
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark expand/collapse function

- (NSUInteger) addSectionWithHeaderName:(NSString *)headerName
{
	const NSUInteger sectionIndex = [_notesTableData addSectionWithHeader:headerName];
	
	CGRect rect = self.tableView.bounds;
	rect.origin.x = 0.0f;
	rect.origin.y = 0.0f;
	rect.size.width = self.tableView.frame.size.width;
	rect.size.height = 24.0f;
	
	NSString *headerTitle = [NSString stringWithFormat:@"- %@", headerName];
	UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	headerButton.adjustsImageWhenDisabled = NO;
	headerButton.adjustsImageWhenHighlighted = NO;
	headerButton.showsTouchWhenHighlighted = NO;
	headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	headerButton.contentEdgeInsets = UIEdgeInsetsMake(1.0f, 4.0f, 1.0f, 4.0f);
	headerButton.frame = rect;
	headerButton.backgroundColor = [UIColor lightGrayColor];
	[headerButton setTitle:headerTitle
				  forState:UIControlStateNormal];
	[headerButton addTarget:self
					 action:@selector(expandButtonTapped:withEvent:)
		   forControlEvents:UIControlEventTouchUpInside];
	
	[_sectionButtons insertObject:headerButton
						  atIndex:sectionIndex];
	
	return sectionIndex;
}

- (void) removeSection:(NSUInteger)sectionIndex
{
	[_notesTableData removeSection:sectionIndex];
	[_sectionButtons removeObjectAtIndex:sectionIndex];
}

- (void) expandSection:(NSInteger)sectionIndex
{
	NSString *headerName = [_notesTableData sectionName:sectionIndex];
	
	// update header's title
	UIButton *headerButton = [_sectionButtons objectAtIndex:sectionIndex];
	[headerButton setTitle:[NSString stringWithFormat:@"- %@", headerName]
				  forState:UIControlStateNormal];
	
	const NSInteger count = [_notesTableData numberOfRowsAtSection:sectionIndex];
	[self.tableView beginUpdates];
	for (NSInteger i = 0 ; i < count ; ++i)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i
													inSection:sectionIndex];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];
}

- (void) collapseSection:(NSInteger)sectionIndex
{
	NSString *headerName = [_notesTableData sectionName:sectionIndex];
	
	// update header's title
	UIButton *headerButton = [_sectionButtons objectAtIndex:sectionIndex];
	[headerButton setTitle:[NSString stringWithFormat:@"+ %@", headerName]
				  forState:UIControlStateNormal];
	
	const NSInteger count = [_notesTableData numberOfRowsAtSection:sectionIndex];
	[self.tableView beginUpdates];
	for (NSInteger i = 0 ; i < count ; ++i)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i
													inSection:sectionIndex];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];
}

- (void) expandButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
	const CGPoint point = [[[event touchesForView:button] anyObject] locationInView:self.tableView];
	
	// search notes headers
	const NSUInteger sectionCount = _notesTableData.sections.count;
	for (NSUInteger sectionIndex = 0 ; sectionIndex < sectionCount ; ++sectionIndex)
	{
		if (CGRectContainsPoint([self.tableView rectForSection:sectionIndex], point))
		{
			SETableSection *section = [_notesTableData section:sectionIndex];
			section.expanded ^= YES;
			
			if (section.expanded)
				[self expandSection:sectionIndex];
			else
				[self collapseSection:sectionIndex];
			return;
		}
	}
}

- (void) reloadData
{
	if( [DMSettings collapseGroups] )
	{
		const NSUInteger sectionCount = _notesTableData.sections.count;
		for (NSUInteger sectionIndex = 0 ; sectionIndex < sectionCount ; ++sectionIndex)
		{
			SETableSection *section = [_notesTableData section:sectionIndex];
			
			section.expanded = NO;
			
			// update header's title
			UIButton *headerButton = [_sectionButtons objectAtIndex:sectionIndex];
			[headerButton setTitle:[NSString stringWithFormat:@"+ %@", section.name]
						  forState:UIControlStateNormal];
		}
	}
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view delegate & data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
	return [_sectionButtons objectAtIndex:sectionIndex];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
	return 24.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _notesTableData.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
		return [_notesTableData numberOfExpandedRowsAtSection:sectionIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	NSInteger sectionIndex = [indexPath indexAtPosition:0];
	NSInteger index = [indexPath indexAtPosition:1];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	NoteEntry *note = [_notesTableData objectAtSection:sectionIndex
												 atRow:index];
	cell.textLabel.text = note.title;
	cell.detailTextLabel.text = note.details;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
		// remove note
		NSInteger sectionIndex = [indexPath indexAtPosition:0];
		NSInteger index = [indexPath indexAtPosition:1];
		
		[self.tableView beginUpdates];
		[_notesTableData removeObjectAtSection:sectionIndex
										 atRow:index];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
		
		// also delete empty sections
		if ([_notesTableData numberOfRowsAtSection:sectionIndex] == 0)
		{
			[self removeSection:sectionIndex];
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
		}
		[self.tableView endUpdates];
	}   
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger sectionIndex = [indexPath indexAtPosition:0];
	NSInteger index = [indexPath indexAtPosition:1];
	NoteEntry *note = [_notesTableData objectAtSection:sectionIndex
												 atRow:index];
	NoteViewController *amv = [[NoteViewController alloc] initWithNote:note];
	amv.delegate = self;
	[self.navigationController pushViewController:amv
										 animated:YES];
	[amv release];
}

#pragma mark -
#pragma mark NoteViewDelegate functions

- (void) noteView:(NoteViewController *)noteView addedNote:(NoteEntry *)note
{
	NSUInteger sectionIndex = [_notesTableData indexOfSectionWithHeader:note.group];
	if (sectionIndex == NSNotFound)
	{
		sectionIndex = [self addSectionWithHeaderName:note.group];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					  withRowAnimation:UITableViewRowAnimationFade];
	}
	const NSUInteger index = [_notesTableData addObject:note
											  atSection:sectionIndex];
	
	if ([_notesTableData sectionHeaderIsExpanded:sectionIndex])
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
													inSection:sectionIndex];
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					  withRowAnimation:UITableViewRowAnimationFade];
		// scroll into view
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionMiddle
									  animated:YES];
	}
	else
	{
		[_notesTableData sectionHeader:sectionIndex
						   setExpanded:YES];
		[self expandSection:sectionIndex];
	}
}

- (void) noteView:(NoteViewController *)noteView modifiedNote:(NoteEntry *)note
{
	const NSUInteger sectionIndex = [_notesTableData indexOfSectionWithHeader:note.group];
	[_notesTableData sortSection:sectionIndex];
	const NSUInteger index = [_notesTableData indexOfObject:note
												  inSection:sectionIndex];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
												inSection:sectionIndex];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
				  withRowAnimation:UITableViewRowAnimationFade];
	// scroll into view
	[self.tableView scrollToRowAtIndexPath:indexPath
						  atScrollPosition:UITableViewScrollPositionMiddle
								  animated:YES];
}

#pragma mark -
#pragma mark Memory management

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]) != nil)
	{
		_sectionButtons = [[NSMutableArray alloc] init];
		_notesTableData = [[SETableData alloc] init];
	}
	return self;
}

- (BOOL) loadData:(NSString *)version
{
	BOOL modified = NO;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	@try
	{
		NSData *rawData = [userDefaults dataForKey:@"NotesRep"];
		if (rawData)
		{
			NSArray *itemsArray = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
			const NSUInteger count = itemsArray.count; 
			for (NSUInteger i = 0 ; i < count ; ++i)
			{
				NSArray *sectionData = [itemsArray objectAtIndex:i];
				NoteEntry *basenote = [sectionData objectAtIndex:0];
				NSString *header = basenote.group;
				[self addSectionWithHeaderName:header];
				for (NoteEntry *note in sectionData)
				{
					NSAssert([header caseInsensitiveCompare:note.group] == NSOrderedSame, @"section header mismatch");
					[_notesTableData addObject:note
									 atSection:i];
				}
			}
		}
	}
	@catch (NSException * e)
	{
		[userDefaults removeObjectForKey:@"NotesRep"];
	}
	
	return modified;
}

- (void) saveData
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *sections = [self.notesTableData sections];
	
	if (sections
		&& sections.count)
	{
		NSMutableArray *notes = [NSMutableArray new];
		for( SETableSection* section in sections )
		{
			[notes addObject:section.rows];
		}
		NSData *rawNotesRepData = [NSKeyedArchiver archivedDataWithRootObject:notes];
		[userDefaults setObject:rawNotesRepData
						 forKey:@"NotesRep"];
		[notes release];
	}
	else
		[userDefaults removeObjectForKey:@"NotesRep"];
	
	[userDefaults synchronize];
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
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)dealloc
{
	[_notesTableData release];
	[_sectionButtons release];
	[super dealloc];
}


@end

