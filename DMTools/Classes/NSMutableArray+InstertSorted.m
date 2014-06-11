//
//  NSMutableArray+InstertSorted.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/16/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "NSMutableArray+InstertSorted.h"

@implementation NSMutableArray (InstertSorted)

- (NSUInteger) insertSorted:(id)object
{
	NSUInteger index = 0;
	
	for( id curObj in self )
	{
		if( [object compare:curObj] == NSOrderedAscending )
		{
			[self insertObject:object
					   atIndex:index];
			return index;
		}
		
		++index;
	}

	[self addObject:object];
	return index;
}

- (NSUInteger) insertSorted:(id)object usingSelector:(SEL)selector
{
	NSUInteger index = 0;
	
	for( id curObj in self )
	{
		if( ((int) [object performSelector:selector
								withObject:curObj] ) == NSOrderedAscending )
		{
			[self insertObject:object
					   atIndex:index];
			return index;
		}
		
		++index;
	}
	
	[self addObject:object];
	return index;
}

@end
