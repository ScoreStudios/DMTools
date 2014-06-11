//
//  DMEncounter.m
//  DM Tools
//
//  Created by hamouras on 27/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "DMEncounter.h"
#import "DMUnit.h"
#import "NSMutableString+DMToolsExport.h"

@implementation DMEncounter

@synthesize name = _name;
@synthesize units = _units;
@synthesize dirty = _dirty;
@dynamic mutableUnits;

-(id)initWithName:(NSString *)newname
{
	if ((self = [super init]) != nil)
	{
		_name = [newname copy];
		_units = [[NSMutableArray alloc] init];
		_dirty = YES;
	}
	return self;
}

- (void) dealloc
{
	[_units release];
	[_name release];

	[super dealloc];
}

- (NSMutableArray*) mutableUnits
{
	_dirty = YES;
	return _units;
}

- (NSComparisonResult)compare:(id)otherObject
{
	DMEncounter *otherEncounter = otherObject;
	return [_name caseInsensitiveCompare:otherEncounter.name];
}

- (BOOL) isDirty
{
	if( _dirty )
		return YES;
	for( DMUnit* unit in _units )
	{
		if( unit.isDirty )
			return YES;
	}
	return NO;
}

- (NSData*) saveToData
{
	NSMutableString *xmlText = [NSMutableString new];
	[xmlText appendDMToolsHeader];
	[xmlText appendEncounter:self
					 atLevel:0];
	[xmlText appendDMToolsFooter];
	
	NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
	[xmlText release];
	return data;
}

- (void) saveToFile:(NSString *)path
{
	NSData *data = [self saveToData];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager createFileAtPath:path
						 contents:data
					   attributes:nil];

	[self clearDirtyStates];
}

- (void) clearDirtyStates
{
	// clear all dirty flags
	for( DMUnit* unit in _units )
	{
		unit.dirty = NO;
	}
	_dirty = NO;
}

- (void) replaceUnitsArray:(NSMutableArray*)newUnits
{
	_dirty = YES;
	[_units release];
	_units = [newUnits retain];
}

- (NSUInteger) numberOfPlayers
{
	NSUInteger count  = 0;
	for( DMUnit* unit in _units )
	{
		if( unit.isPlayer )
			++count;
	}
	return count;
}

- (NSUInteger) numberOfMonsters
{
	NSUInteger count  = 0;
	for( DMUnit* unit in _units )
	{
		if( !unit.isPlayer )
			++count;
	}
	return count;
}

@end
