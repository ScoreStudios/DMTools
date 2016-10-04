//
//  MenuViewController.m
//  DM Tools
//
//  Created by hamouras on 12/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "MenuViewController.h"
#import "LibraryViewController.h"
#import "SessionsViewController.h"
#import "NotesViewController.h"
#import "DMSettingsViewController.h"
#import "DMToolsAppDelegate.h"
#import "SEWebViewController.h"
#import "DMDataManager.h"
#import "DMLibrary.h"
#import "DMUnit.h"

#define kEncountersIndex	0
#define kNotesIndex			1
#define kManualIndex		2
#define kSettingsIndex		3

#define kIPhoneIndexCount	2
#define kIPadIndexCount		4

@implementation MenuViewController

@synthesize libraryViewController = _libraryViewController;
@synthesize sessionsViewController = _sessionsViewController;
@synthesize notesViewController = _notesViewController;
@synthesize manualViewController = _manualViewController;
@synthesize settingsViewController = _settingsViewController;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
	{
    }
    return self;
}
*/
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.preferredContentSize = CGSizeMake(320.0, 480.0);
	
	// setup buttons
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				  target:self
																				  action:@selector(createLibrary:)];
	self.toolbarItems = [NSArray arrayWithObject:createButton];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[createButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)reloadData
{
	[self.tableView reloadData];
}

- (void)createLibrary:(id)sender
{
	NSDictionary* libraries = [DMDataManager libraries];
	NSString* prefix = @"New template";
	NSString* newName = prefix;
	NSUInteger counter = 1;
	while( [libraries objectForKey:newName] )
	{
		newName = [prefix stringByAppendingFormat:@" %d", (int)counter++];
	}
	DMLibrary* library = [[DMLibrary alloc] initWithName:newName];
	[self addLibrary:library];
	[self editLibrary:library];
	[library release];
}

- (void) openOrDuplicateTemplate:(DMLibrary*)library
{
	_currentLibrary = [library retain];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:library.name
															 delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil, nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
	[actionSheet addButtonWithTitle:@"Edit Template"];
	[actionSheet addButtonWithTitle:@"Copy Template"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	[actionSheet setCancelButtonIndex:2];
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[actionSheet showInView:appDelegate.window.rootViewController.view];
	[actionSheet release];
}

- (NSURL*) webViewControllerRequestURL:(SEWebViewController *)webViewController
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"DMToolsHelpVersion"];
	NSString *url = [NSString stringWithFormat:@"http://score-studios.jp/dmhelp/%@/", version];
	return [NSURL URLWithString:url];
}

- (void) addLibrary:(DMLibrary*)library
{
	[DMDataManager addLibrary:library];
	[DMUnitViewController setDefaultDisplayForUnit:library.baseTemplate];
	[self reloadData];
}

- (void) editLibrary:(DMLibrary*)library
{
	DMUnitViewController *uvc = [[DMUnitViewController alloc] initWithLibrary:library];
	uvc.delegate = self;
	[self.navigationController pushViewController:uvc
										 animated:YES];
	[uvc release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return ( section ? @"" : @"Libraries" );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 )
	{
		NSArray* libraryNames = [DMDataManager sortedLibraryNames];
		return libraryNames.count;
	}
	else
		return ( [[UIDevice currentDevice] isIPad] ? kIPadIndexCount : kIPhoneIndexCount );
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.textLabel.textColor = [UIColor colorWithRed:113.0f/255.0f
											   green:120.0f/255.0f
												blue:128.0f/255.0f
											   alpha:1.0f];
    
	const NSUInteger section = indexPath.section;
	const NSUInteger row = indexPath.row;
    // Configure the cell...
	if( section == 0 )
	{
		NSArray* libraryNames = [DMDataManager sortedLibraryNames];
		cell.textLabel.text = [libraryNames objectAtIndex:row];
		cell.imageView.image = [UIImage imageNamed:@"menu_library_off.png"];
	}
	else
	{
		switch( row )
		{
			case kEncountersIndex:
				cell.textLabel.text = @"Saved Sessions";
				cell.imageView.image = [UIImage imageNamed:@"menu_encounters_off.png"];
				break;
			case kNotesIndex:
				cell.textLabel.text = @"Notes";
				cell.imageView.image = [UIImage imageNamed:@"menu_notes_off.png"];
				break;
			case kManualIndex:
				cell.textLabel.text = @"Manual";
				cell.imageView.image = [UIImage imageNamed:@"menu_manual_off.png"];
				break;
			case kSettingsIndex:
				cell.textLabel.text = @"Settings";
				cell.imageView.image = [UIImage imageNamed:@"menu_settings_off.png"];
				break;
			default:
				NSLog(@"cell shouldn't exist");
				break;
		};
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if( indexPath.section == 0 )
	{
		NSArray* libraryNames = [DMDataManager sortedLibraryNames];
		NSString* libraryName = [libraryNames objectAtIndex:indexPath.row];
		DMLibrary* library = [[DMDataManager libraries] objectForKey:libraryName];
		return !library.isReadonlyTemplate;
	}
	return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSArray* libraryNames = [DMDataManager sortedLibraryNames];
		NSString* libraryName = [libraryNames objectAtIndex:indexPath.row];
		DMLibrary* library = [[DMDataManager libraries] objectForKey:libraryName];
		[DMDataManager removeLibrary:library];

        // Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger section = indexPath.section;
	const NSUInteger row = indexPath.row;
	if( section == 0 )
	{
		if( self.isEditing )
		{
			NSArray* libraryNames = [DMDataManager sortedLibraryNames];
			NSString* libraryName = [libraryNames objectAtIndex:indexPath.row];
			DMLibrary* library = [[DMDataManager libraries] objectForKey:libraryName];
			[self openOrDuplicateTemplate:library];
		}
		else
		{
			NSArray* libraryNames = [DMDataManager sortedLibraryNames];
			NSString* libraryName = [libraryNames objectAtIndex:row];
			_libraryViewController.library = [[DMDataManager libraries] objectForKey:libraryName];
			[self.navigationController pushViewController:_libraryViewController
												 animated:YES];
		}
	}
	else
	{
		switch( row )
		{
			case kEncountersIndex:
				[self.navigationController pushViewController:_sessionsViewController
													 animated:YES];
				break;
			case kNotesIndex:
				[self.navigationController pushViewController:_notesViewController
													 animated:YES];
				break;
			case kManualIndex:
				[self.navigationController pushViewController:_manualViewController
													 animated:YES];
				break;
			case kSettingsIndex:
				[self.navigationController pushViewController:_settingsViewController
													 animated:YES];
				break;
			default:
				NSLog(@"cell shouldn't exist");
				break;
		};
	}
}

#pragma mark - DMUnitViewController delegate functions

- (void) unitViewController:(DMUnitViewController *)unitViewController finishedEditingUnit:(DMUnit *)unit
{
	[self reloadData];
}

#pragma mark -
#pragma mark UIActionSheetDelegate functions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	BOOL cancelled = NO;
	DMLibrary* library = _currentLibrary;
	switch (buttonIndex)
	{
		case 1:
		{
			DMUnit* unit = [library.baseTemplate copy];
			unit.name = [unit.name stringByAppendingString:@" copy"];
			library = [[DMLibrary alloc] initWithTemplate:unit];
			[self addLibrary:library];
			[library release];
			[unit release];
			// fall through to next case
		}
		case 0:
			[self editLibrary:library];
			break;
			
		default:
			cancelled = YES;
			break;
	};
	
	[_currentLibrary release];
	_currentLibrary = nil;
	
	[actionSheet dismissWithClickedButtonIndex:buttonIndex
									  animated:cancelled];
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
*/


- (void)viewDidUnload
{
	[super viewDidUnload];

	self.navigationItem.rightBarButtonItem = nil;
	self.toolbarItems = nil;
}

- (void)dealloc {
	[_settingsViewController release];
	[_manualViewController release];
	[_notesViewController release];
	[_sessionsViewController release];
	[_libraryViewController release];
	
    [super dealloc];
}


@end

