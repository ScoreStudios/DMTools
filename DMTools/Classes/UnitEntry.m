//
//  UnitEntry.m
//  DM Tools
//
//  Created by Paul Caristino on 6/4/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "UnitEntry.h"

@implementation UnitEntry
@synthesize name;
@synthesize HP;
@synthesize maxHP;
@synthesize initiative;
@synthesize initMod;
@synthesize ac;
@synthesize fort;
@synthesize reflex;
@synthesize will;
@synthesize notes;
@synthesize player;
@synthesize hitModifier;
@synthesize acModifier;
@synthesize ongoing;
@synthesize stateFlags;
@synthesize selected;

-(id) initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]) != nil)
	{
		self.name = [decoder decodeObjectForKey:@"kName"];
		self.notes = [decoder decodeObjectForKey:@"kNotes"];
		self.HP = [decoder decodeIntForKey:@"kHP"];
		self.maxHP = [decoder decodeIntForKey:@"kMaxHP"];
		self.initiative = [decoder decodeIntForKey:@"kInitiative"];
		self.initMod = [decoder decodeIntForKey:@"kInitMod"];
		self.ac = [decoder decodeIntForKey:@"kAC"];
		self.fort = [decoder decodeIntForKey:@"kFort"];
		self.reflex = [decoder decodeIntForKey:@"kReflex"];
		self.will = [decoder decodeIntForKey:@"kWill"];
		self.player = [decoder decodeBoolForKey:@"kPlayer"];
		self.hitModifier = [decoder decodeIntForKey:@"kHitModifier"];
		self.acModifier = [decoder decodeIntForKey:@"kACModifier"];
		self.ongoing = [decoder decodeIntForKey:@"kOngoing"];
		self.stateFlags = [decoder decodeIntForKey:@"kStates"];
		self.selected = [decoder decodeBoolForKey:@"kSelected"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
	NSAssert(0, @"legacy code");
}

- (void)dealloc
{
	[name release];
	[notes release];
	[super dealloc];
}

@end

@implementation Encounter
@synthesize name = _name;
@synthesize units = _units;

-(id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]) != nil)
	{
		_name = [[decoder decodeObjectForKey:@"kName"] copy];
		_units = [[decoder decodeObjectForKey:@"kMonsters"] retain];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
	NSAssert(0, @"legacy code");
}

- (void) dealloc
{
	[_units release];
	[_name release];
	
	[super dealloc];
}

@end
