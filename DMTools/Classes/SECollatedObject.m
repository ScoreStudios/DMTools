//
//  SECollatedObject.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 5/4/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "SECollatedObject.h"

@implementation SECollatedObject

@synthesize sectionIndex = _sectionIndex;

- (id) init
{
	self = [super init];
	if( self )
	{
		_sectionIndex = NSNotFound;
	}
	
	return self;
}

@end
