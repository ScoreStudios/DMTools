//
//  SECollatedViewController.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 5/4/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "SECollatedViewController.h"
#import "SECollatedObject.h"

@implementation SECollatedViewController

@synthesize collationSelector = _collationSelector;

- (void)viewDidLoad
{
    [super viewDidLoad];

	_sections = [NSMutableArray new];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

	[_sections release];
	_sections = nil;
}

- (void)dealloc
{
	[_sections release];
	[super dealloc];
}

#pragma mark - collated data management

- (void)updateSectionsFromObjects:(NSArray*)objects withSelectedObject:(id)selectedObject scrollAnimated:(BOOL)scrollAnimated
{
	// rebuild collated arrays
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	
	for( SECollatedObject* object in objects )
	{
        NSInteger sect = [collation sectionForObject:object
							 collationStringSelector:_collationSelector];
        object.sectionIndex = sect;
    }

	const NSUInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for( NSUInteger i = 0 ; i < sectionCount ; i++ )
	{
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }

 	for( SECollatedObject* object in objects )
	{
       [(NSMutableArray*)[sectionArrays objectAtIndex:object.sectionIndex] addObject:object];
    }

	[_sections removeAllObjects];
    for( NSMutableArray* sectionArray in sectionArrays )
	{
        NSArray* sortedSection = [collation sortedArrayFromArray:sectionArray
										 collationStringSelector:_collationSelector];
        [_sections addObject:sortedSection];
    }
	
	[self.tableView reloadData];
	[self.tableView reloadSectionIndexTitles];
	
	if( selectedObject )
	{
		NSIndexPath* indexPath = [self indexPathForObject:selectedObject];
		if( indexPath )
		{
			[self.tableView scrollToRowAtIndexPath:indexPath
								  atScrollPosition:UITableViewScrollPositionMiddle
										  animated:scrollAnimated];
		}
	}
}

- (NSIndexPath*)indexPathForObject:(SECollatedObject*)object
{
	const NSUInteger section = object.sectionIndex;
	if( section == NSNotFound )
		return nil;
	const NSUInteger row = [[_sections objectAtIndex:section] indexOfObjectIdenticalTo:object];
	if( section == NSNotFound )
		return nil;
	return [NSIndexPath indexPathForRow:row
							  inSection:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_sections objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if( [[_sections objectAtIndex:section] count] > 0 )
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
	}
	id object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.textLabel.text = [object performSelector:_collationSelector];
	return cell;
}

@end
