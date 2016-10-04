//
//  SessionsViewController.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/13/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "SessionsViewController.h"
#import "DMDataManager.h"
#import "DMEncounter.h"
#import "DMToolsAppDelegate.h"
#import "InitiativeViewController.h"

@implementation SessionsViewController

@synthesize initiativeViewController = _initiativeViewController;

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]) != nil)
	{
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.preferredContentSize = CGSizeMake(320.0, 480.0);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
	_currentEncounterName = nil;
}

- (void)dealloc
{
	[_initiativeViewController release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reloadData
{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UIAlertViewDelegate functions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex && _currentEncounterName )
	{
		DMEncounter* encounter = [DMDataManager loadSavedEncounter:_currentEncounterName];
		[DMDataManager setCurrentEncounter:encounter];
		
		DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
		[appDelegate.initiativeViewController reloadData];
		
		if ([[UIDevice currentDevice] isIPhone])
		{
			UITabBarItem *initiativeItem = [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem];
			initiativeItem.badgeValue = encounter.name;
		}
	}
	_currentEncounterName = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	NSArray* encounterNames = [DMDataManager sortedSavedEncounterNames];
	return encounterNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
    }
   
    // Configure the cell...
	const NSUInteger row = indexPath.row;
	NSString* encounterName = [[DMDataManager sortedSavedEncounterNames] objectAtIndex:row];
	NSDate* savedDate = [[DMDataManager savedEncounterDates] objectForKey:encounterName];
	cell.textLabel.text = encounterName;
	cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:savedDate
															   dateStyle:NSDateFormatterMediumStyle
															   timeStyle:NSDateFormatterShortStyle];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		const NSUInteger row = indexPath.row;
		NSString* encounterName = [[DMDataManager sortedSavedEncounterNames] objectAtIndex:row];
		[DMDataManager deleteSavedEncounter:encounterName];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger row = indexPath.row;
	NSString* encounterName = [[DMDataManager sortedSavedEncounterNames] objectAtIndex:row];
	_currentEncounterName = encounterName;
	
	NSString* msg = [NSString stringWithFormat:@"Are you sure you want to restore %@'s data? The current initiative list data will be deleted.", _currentEncounterName];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Encoutner"
													message:msg
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes", nil];
	[alert show];
	[alert release];
}

@end
