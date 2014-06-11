//
//  DMLibrary.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/13/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMLibrary.h"
#import "DMUnit.h"
#import "UnitEntry.h"
#import "DMDataManager.h"
#import "DMToolsAppDelegate.h"
#import "NSMutableString+DMToolsExport.h"


@implementation DMLibrary

@synthesize baseTemplate = _baseTemplate;
@synthesize players = _players, monsters = _monsters;
@dynamic name, mutablePlayers, mutableMonsters;
@synthesize savename = _savename, dirty = _dirty, readonlyTemplate = _readonlyTemplate;

- (id)initWithReadonlyTemplate:(DMUnit*)baseTemplate
{
	if( (self = [super init] ) != nil )
	{
		_baseTemplate = [baseTemplate retain];
		_players = [NSMutableArray new];
		_monsters = [NSMutableArray new];
		_dirty = YES;
		_readonlyTemplate = YES;
	}
	return self;
}

- (id)initWithTemplate:(DMUnit*)baseTemplate
{
	if( (self = [super init] ) != nil )
	{
		_baseTemplate = [baseTemplate retain];
		_players = [NSMutableArray new];
		_monsters = [NSMutableArray new];
		_dirty = YES;
		_readonlyTemplate = NO;
	}
	return self;
}

- (id)initWithName:(NSString*)name
{
	if( (self = [super init] ) != nil )
	{
		_baseTemplate = [DMUnit new];
		_baseTemplate.name = name;
		_players = [NSMutableArray new];
		_monsters = [NSMutableArray new];
		_dirty = YES;
	}
	return self;
}

- (NSString*) name
{
	return _baseTemplate.name;
}

- (NSMutableArray*) mutablePlayers
{
	_dirty = YES;
	return _players;
}

- (NSMutableArray*) mutableMonsters
{
	_dirty = YES;
	return _monsters;
}

- (void) dealloc
{
	[_monsters release];
	[_players release];
	[_savename release];
	[_baseTemplate release];
	
	[super dealloc];
}

- (BOOL) isDirty
{
	if( _dirty
	   || _baseTemplate.isDirty )
		return YES;
	
	for( DMUnit* unit in _players )
	{
		if( unit.isDirty )
			return YES;
	}
	
	for( DMUnit* unit in _monsters )
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
	[xmlText appendLibrary:self
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
	if( [fileManager fileExistsAtPath:path] )
		[fileManager removeItemAtPath:path
								error:nil];
	[fileManager createFileAtPath:path
						 contents:data
					   attributes:nil];
	
	[self clearDirtyStates];
	self.savename = [path lastPathComponent];
}

- (void) clearDirtyStates
{
	_baseTemplate.dirty = NO;
	// clear all dirty flags
	for( DMUnit* unit in _players )
	{
		unit.dirty = NO;
	}
	for( DMUnit* unit in _monsters )
	{
		unit.dirty = NO;
	}
	_dirty = NO;
}

- (NSComparisonResult) compare:(id)otherObject
{
	DMLibrary *other = otherObject;
	return [self.name caseInsensitiveCompare:other.name];
}

@end
