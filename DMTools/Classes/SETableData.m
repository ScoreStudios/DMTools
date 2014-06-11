//
//  SETableData.m
//  DM Tools
//
//  Created by hamouras on 06/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "SETableData.h"

@interface SETableSection()
@property (nonatomic, readonly) NSMutableArray* mutableRows;
@end

@implementation SETableSection
@synthesize name = _name;
@synthesize expanded = _expanded;
@synthesize editable = _editable;
@synthesize rows = _rows;
@dynamic mutableRows;

- (id) init
{
	if( ( self = [super init] ) != nil )
	{
		_rows = [NSMutableArray new];
		_editable = YES;
	}
	
	return self;
}

- (void) dealloc
{
	[_rows release];
	[_name release];
	[super dealloc];
}

- (NSMutableArray*) mutableRows
{
	return _rows;
}

- (NSComparisonResult) compare:(id)otherObject
{
	SETableSection* otherSection = otherObject;
	return [_name caseInsensitiveCompare:otherSection.name];
}

@end


@implementation SETableData
@synthesize sections = _sections;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		_sections = [NSMutableArray new];
	}
	
	return self;
}

- (void) dealloc
{
	[_sections release];
	[super dealloc];
}

- (SETableSection *) section:(NSUInteger)sectionIndex
{
	return [_sections objectAtIndex:sectionIndex];
}

- (NSString*) sectionName:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.name;
}

- (BOOL) sectionHeaderIsExpanded:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.isExpanded;
}

- (BOOL) sectionHeaderIsEditable:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.isEditable;
}

- (void) sectionHeader:(NSUInteger)sectionIndex setExpanded:(BOOL)expanded
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	section.expanded = expanded;
}

- (void) sectionHeader:(NSUInteger)sectionIndex setEditable:(BOOL)editable
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	section.editable = editable;
}

- (NSUInteger) numberOfExpandedRowsAtSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.expanded ? section.rows.count : 0;
}

- (NSUInteger) numberOfRowsAtSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.rows.count;
}

- (NSArray *) rowsAtSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return section.rows;
}

- (id) objectAtSection:(NSUInteger)sectionIndex atRow:(NSUInteger)rowIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return [section.rows objectAtIndex:rowIndex];
}

- (BOOL) sectionWithHeaderExists:(NSString *)header
{
	for( SETableSection* section in _sections )
	{
		if ([section.name isEqualToString:header])
			return YES;
	}
	
	return NO;
}

- (NSUInteger) indexOfSectionWithHeader:(NSString *)header
{
	NSUInteger index = 0;
	for( SETableSection* section in _sections )
	{
		if ([section.name isEqualToString:header])
			return index;
		++index;
	}
	
	return NSNotFound;
}

- (NSUInteger) addSectionWithHeader:(NSString *)header
{
	SETableSection *section = [SETableSection new];
	section.name = header;
	section.expanded = YES;
	const NSUInteger index = [_sections insertSorted:section];
	[section release];
	return index;
}

- (void) removeSection:(NSUInteger)sectionIndex
{
	[_sections removeObjectAtIndex:sectionIndex];
}

- (BOOL) objectExists:(id)object inSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	for( id curObj in section.rows )
	{
		if (curObj == object)
			return YES;
	}
	
	return NO;
}

- (NSUInteger) indexOfObject:(id)object inSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	NSUInteger index = 0;
	for( id curObj in section.rows )
	{
		if (curObj == object)
			return index;
		++index;
	}
	
	return NSNotFound;
}

- (NSUInteger) addObject:(id)object atSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	return [section.mutableRows insertSorted:object];
}

- (void) removeObjectAtSection:(NSUInteger)sectionIndex atRow:(NSUInteger)rowIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	[section.mutableRows removeObjectAtIndex:rowIndex];
}

- (void) removeAllObjects
{
	for( SETableSection* section in _sections )
	{
		[section.mutableRows removeAllObjects];
	}
}

- (void) removeAllSections
{
	[_sections removeAllObjects];
}

- (void) sort
{
	for( SETableSection* section in _sections )
	{
		[section.mutableRows sortUsingSelector:@selector(compare:)];
	}
}

- (void) sortSection:(NSUInteger)sectionIndex
{
	SETableSection *section = [_sections objectAtIndex:sectionIndex];
	[section.mutableRows sortUsingSelector:@selector(compare:)];
}

@end
