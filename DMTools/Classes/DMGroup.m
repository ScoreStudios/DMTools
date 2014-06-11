//
//  DMGroup.m
//  DM Tools
//
//  Created by hamouras on 3/23/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMGroup.h"
#import "DMNumber.h"

@implementation DMGroup
@synthesize name = _name, type = _type, keys = _keys, items = _items;
@synthesize canDisplayAttribs = _canDisplayAttribs, canDisplayStates = _canDisplayStates;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		_keys = [NSMutableArray new];
		_items = [NSMutableArray new];
	}
	
	return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
	if ((self = [super init]) != nil)
	{
		_keys = [NSMutableArray new];
		_items = [NSMutableArray new];
		
		self.name = [[dictionary objectForKey:@"name"] stringByReplacingXMLEscapeChars];
		NSString *typeStr = [dictionary objectForKey:@"type"];
		if ([typeStr isEqualToString:@"string"])
			_type = DMGroupTypeString;
		else if ([typeStr isEqualToString:@"boolean"])
			_type = DMGroupTypeBoolean;
		else if ([typeStr isEqualToString:@"value"])
			_type = DMGroupTypeValue;
		else if ([typeStr isEqualToString:@"value:modifier"])
			_type = DMGroupTypeValueModifier;
		else if ([typeStr isEqualToString:@"counter"])
			_type = DMGroupTypeCounter;
		else
			return nil;
	}
	
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	DMGroup *group = [[[self class] allocWithZone:zone] init];
	group.name = _name;
	group.type = _type;
	for( NSString* key in _keys )
	{
		NSString* newKey = [key copyWithZone:zone];
		[group.keys addObject:newKey];
		[newKey release];
	}
	for( id item in _items )
	{
		id newItem = [item copyWithZone:zone];
		[group.items addObject:newItem];
		[newItem release];
	}
	
	return group;
}

- (void) dealloc
{
	[_items release];
	[_keys release];
	[_name release];
	
	[super dealloc];
}

- (id) objectWithKey:(NSString*)key
{
	NSUInteger index = 0;
	for (NSString *curKey in _keys)
	{
		if( [curKey isEqualToString:key] )
			return [_items objectAtIndex:index];
		++index;
	}
	return nil;
}

- (NSInteger) objectIndexWithKey:(NSString*)key
{
	NSInteger index = 0;
	for (NSString *curKey in _keys)
	{
		if( [curKey isEqualToString:key] )
			return index;
		++index;
	}
	return -1;
}

- (BOOL) canDisplayAttribs
{
	return ( _type == DMGroupTypeValue || _type == DMGroupTypeValueModifier || _type == DMGroupTypeCounter );
}

- (BOOL) canDisplayStates
{
	return _type == DMGroupTypeBoolean;
}

@end
