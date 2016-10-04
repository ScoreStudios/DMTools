//
//  RollViewController.m
//  DM Tools
//
//  Created by hamouras on 04/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "RollViewController.h"
#import "DiceViewController.h"
#import "RollEntry.h"

@implementation RollViewController

@synthesize rollArray = _rollArray;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark View lifecycle


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id) initWithRollArray:(NSMutableArray *)rolls withDelegate:(id<RollViewControllerDelegate>)delegate
{
	if ((self = [super initWithStyle:UITableViewStylePlain]) != nil)
	{
		// Custom initialization
		_rollArray = [rolls retain];
		_delegate = delegate;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self
																			action:@selector(createRoll:)];
	self.toolbarItems = [NSArray arrayWithObject:button];
	[button release];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.preferredContentSize = CGSizeMake(320.0, 480.0);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return YES;
}

- (IBAction) createRoll:(id)sender
{
	DiceViewController *diceViewController = [[DiceViewController alloc] init];
	diceViewController.delegate = self;
	[self.navigationController pushViewController:diceViewController
										 animated:YES];
	[diceViewController release];
}

#pragma mark -
#pragma mark DiceViewController delegate

- (void) diceView:(DiceViewController *)diceView addedRoll:(RollEntry *)roll
{
	if (roll.isEmpty)
		return;

	[_rollArray addObject:roll];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_rollArray.count - 1
																					   inSection:0]]
						  withRowAnimation:UITableViewRowAnimationFade];
}

- (void) diceView:(DiceViewController *)diceView modifiedRoll:(RollEntry *)roll
{
	NSUInteger index = [_rollArray indexOfObjectIdenticalTo:roll];
	if (index == NSNotFound)
	{
		// add roll instead
		[self diceView:diceView
			 addedRoll:roll];
		return;
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
												inSection:0];
	if (roll.isEmpty)
	{
		// remove object if empty
		[_rollArray removeObjectAtIndex:index];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _rollArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
    }

	NSInteger row = [indexPath indexAtPosition:1];
	// Configure the cell...
	RollEntry *roll = [_rollArray objectAtIndex:row];
	cell.textLabel.text = [roll toString];
	cell.accessoryType = ( !roll.initiative && !roll.percentage ) ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
	cell.editingAccessoryType = ( !roll.initiative && !roll.percentage ) ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
	
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	NSInteger row = [indexPath indexAtPosition:1];
	RollEntry *roll = [_rollArray objectAtIndex:row];
	return ( !roll.initiative && !roll.percentage );
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        // Delete the row from the data source
		[_rollArray removeObjectAtIndex:[indexPath indexAtPosition:1]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath indexAtPosition:1];
	RollEntry *roll = [_rollArray objectAtIndex:row];
	if( roll.initiative )
	{
		[_delegate rollViewControllerRerollInitiative:self];
	}
	else
	{
		NSString *rollString = [roll rollToString];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Dice %@", [roll toString]]
														message:[NSString stringWithFormat:@"Your roll is:\n%@", rollString]
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	RollEntry *roll = [_rollArray objectAtIndex:[indexPath indexAtPosition:1]];
	DiceViewController *diceViewController = [[DiceViewController alloc] initWithRoll:roll];
	diceViewController.delegate = self;
	[self.navigationController pushViewController:diceViewController
										 animated:YES];
	[diceViewController release];
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.toolbarItems = nil;
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)dealloc
{
	[_rollArray release];
    [super dealloc];
}


@end

