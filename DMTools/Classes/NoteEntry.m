//
//  NoteEntry.m
//  DM Tools
//
//  Created by Paul Caristino on 6/5/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "NoteEntry.h"


@implementation NoteEntry

@synthesize title;
@synthesize details;
@synthesize notes;
@synthesize group;


-(id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]) != nil)
	{
		self.title = [decoder decodeObjectForKey:@"kTitle"];
		self.details = [decoder decodeObjectForKey:@"kDetails"];
		self.notes = [decoder decodeObjectForKey:@"kNotes"];
		self.group = [decoder decodeObjectForKey:@"kGroup"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:title forKey:@"kTitle"];
	[encoder encodeObject:details forKey:@"kDetails"];
	[encoder encodeObject:notes forKey:@"kNotes"];
	[encoder encodeObject:group forKey:@"kGroup"];
}

- (id) copyWithZone:(NSZone *)zone
{
	NoteEntry *newmon = [[[self class] allocWithZone:zone] init];
	newmon.title = title;
	newmon.details = details;
	newmon.notes = notes;
	newmon.group = group;
	
	return newmon;
}

- (NSComparisonResult)compare:(id)otherObject
{
	NoteEntry *otherNote = otherObject;
	return [title caseInsensitiveCompare:otherNote.title];
}

- (void)dealloc
{
	[title release];
	[details release];
	[notes release];
	[group release];
	[super dealloc];
}

@end
