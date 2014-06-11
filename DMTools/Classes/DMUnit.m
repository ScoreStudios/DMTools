//
//  DMUnit.m
//  DM Tools
//
//  Created by hamouras on 3/16/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMUnit.h"
#import "DMDataManager.h"
#import "DMGroup.h"
#import "DMNumber.h"
#import "DMHitPoints.h"
#import "UnitEntry.h"
#import "DMToolsAppDelegate.h"
#import "NSMutableString+DMToolsExport.h"

#define UPGRADE_LEGACY_TO_LEGACY_TEMPLATE

@implementation DMUnit

@synthesize name = _name;
@synthesize avatarName = _avatarName, race = _race, charClass = _charClass;
@synthesize player = _player, level = _level, HP = _HP, initiative = _initiative;
@synthesize groups = _groups, notes = _notes;
@synthesize avatar = _avatar, selected = _selected, dirty = _dirty;
@dynamic detailString, mutableGroups;

#pragma mark creation/destruction

- (id) init
{
	if ((self = [super init]) != nil)
	{
		// allocate needed items
		self.name = @"";
		self.avatarName = @"";
		self.race = @"";
		self.charClass = @"";
		_HP = [DMHitPoints new];
		_initiative = [[DMNumber numberWithValue:10
									withModifier:0] retain];
		_groups = [[NSMutableArray alloc] init];
		self.notes = @"";
		_dirty = YES;
	}
	
	return self;
}

- (id) initWithName:(NSString *)name
{
	if ((self = [super init]) != nil)
	{
		// allocate needed items
		self.name = name;
		self.avatarName = @"";
		self.race = @"";
		self.charClass = @"";
		_HP = [DMHitPoints new];
		_initiative = [[DMNumber numberWithValue:10
									withModifier:0] retain];
		_groups = [[NSMutableArray alloc] init];
		self.notes = @"";
		_dirty = YES;
	}
	
	return self;
}

- (void) setInfoFromDictionary:(NSDictionary *)dictionary
{
	_player = [[dictionary objectForKey:@"player"] boolValue];
	self.avatarName = [[dictionary objectForKey:@"avatar"] stringByReplacingXMLEscapeChars];
	self.race = [[dictionary objectForKey:@"race"] stringByReplacingXMLEscapeChars];
	self.charClass = [[dictionary objectForKey:@"class"] stringByReplacingXMLEscapeChars];
	_level = [[dictionary objectForKey:@"level"] integerValue];
	self.HP = [DMHitPoints hitPointsFromString:[dictionary objectForKey:@"HP"]];
	self.initiative = [DMNumber numberWithModifierFromString:[dictionary objectForKey:@"initiative"]];
	_dirty = YES;
}

- (NSString*) detailString
{
	NSUInteger raceLen = _race.length;
	NSUInteger classLen = _charClass.length;
	if( raceLen && classLen )
		return [NSString stringWithFormat:@"%@, %@", _race, _charClass];
	else if( raceLen )
		return [NSString stringWithFormat:@"%@", _race];
	else if( classLen )
		return [NSString stringWithFormat:@"%@", _charClass];
	else
		return @"";
}

- (id) initWithUnitEntry:(UnitEntry *)unit
{
	NSAssert( unit, @"unit shouldn't be nil" );
	
	if ((self = [super init]) != nil)
	{
		self.name = unit.name;
		self.avatarName = unit.player ? @"avatar_22.png" : @"avatar_21.png";
		self.race = @"";
		self.charClass = @"";
		self.player = unit.player;
		self.level = 1;
		_HP = [[DMHitPoints hitPointsWithValue:unit.HP
								  withMaxValue:unit.maxHP] retain];
		_initiative = [[DMNumber numberWithValue:unit.initiative
									withModifier:unit.initMod] retain];
		
		_groups = [[NSMutableArray alloc] init];
#ifndef UPGRADE_LEGACY_TO_LEGACY_TEMPLATE
		// add abilities
		{
			DMGroup *abilities = [DMGroup new];
			abilities.name = @"Abilities";
			abilities.type = DMGroupTypeValueModifier;
			
			[abilities.keys addObject:@"Strength"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[abilities.keys addObject:@"Constitution"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[abilities.keys addObject:@"Dexterity"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[abilities.keys addObject:@"Intelligence"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[abilities.keys addObject:@"Wisdom"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[abilities.keys addObject:@"Charisma"];
			[abilities.items addObject:[DMNumber numberWithValue:10
													withModifier:0]];
			[_groups addObject:[abilities autorelease]];
		}
#endif
		// add attributes
		{
			DMGroup *attributes = [DMGroup new];
			attributes.name = @"Attributes";
			attributes.type = DMGroupTypeValue;
			
			DMNumber* number = [DMNumber numberWithValue:unit.ac];
			number.display = YES;
			[attributes.keys addObject:@"AC"];
			[attributes.items addObject:number];
			
			number = [DMNumber numberWithValue:unit.fort];
			number.display = YES;
			[attributes.keys addObject:@"Fortitude"];
			[attributes.items addObject:number];
			
			number = [DMNumber numberWithValue:unit.reflex];
			number.display = YES;
			[attributes.keys addObject:@"Reflex"];
			[attributes.items addObject:number];
			
			number = [DMNumber numberWithValue:unit.will];
			number.display = YES;
			[attributes.keys addObject:@"Will"];
			[attributes.items addObject:number];
			
#ifndef UPGRADE_LEGACY_TO_LEGACY_TEMPLATE
			[attributes.keys addObject:@"Speed"];
			[attributes.items addObject:[DMNumber numberWithValue:6]];
			
			[attributes.keys addObject:@"Passive Perception"];
			[attributes.items addObject:[DMNumber numberWithValue:10]];
			
			[attributes.keys addObject:@"Passive Insight"];
			[attributes.items addObject:[DMNumber numberWithValue:10]];
#endif
			
			[_groups addObject:[attributes autorelease]];
		}
#ifndef UPGRADE_LEGACY_TO_LEGACY_TEMPLATE
		// add skills
		{
			DMGroup *skills = [DMGroup new];
			skills.name = @"Skills";
			skills.type = DMGroupTypeValue;
			
			[skills.keys addObject:@"Acrobatics"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Arcana"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Athletics"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Bluff"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Diplomacy"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Dungeoneering"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Endurance"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Heal"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"History"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Insight"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Intimidate"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Nature"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Perception"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Religion"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Stealth"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Streetwise"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			[skills.keys addObject:@"Thievery"];
			[skills.items addObject:[DMNumber numberWithValue:0]];
			
			[_groups addObject:[skills autorelease]];
		}
#endif
		// add states
		{
			const NSUInteger stateFlags = unit.stateFlags;
			DMGroup *states = [DMGroup new];
			states.name = @"States";
			states.type = DMGroupTypeBoolean;
			
			DMBoolean* boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateMarked) != 0];
			boolean.display = 1;
			[states.keys addObject:@"Marked"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateDazed) != 0];
			boolean.display = 2;
			[states.keys addObject:@"Dazed"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateStunned) != 0];
			boolean.display = 3;
			[states.keys addObject:@"Stunned"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateSlowed) != 0];
			boolean.display = 4;
			[states.keys addObject:@"Slowed"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateDeafened) != 0];
			boolean.display = 5;
			[states.keys addObject:@"Deafened"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateBlinded) != 0];
			boolean.display = 6;
			[states.keys addObject:@"Blinded"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateWeakened) != 0];
			boolean.display = 7;
			[states.keys addObject:@"Weakened"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateImmobilized) != 0];
			boolean.display = 8;
			[states.keys addObject:@"Immobilized"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:NO];
			boolean.display = 9;
			[states.keys addObject:@"Charmed"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:(stateFlags & eUnitStateProne) != 0];
			boolean.display = 10;
			[states.keys addObject:@"Prone"];
			[states.items addObject:boolean];
			
			boolean = [DMBoolean booleanWithValue:NO];
			boolean.display = 11;
			[states.keys addObject:@"Poisoned"];
			[states.items addObject:boolean];

			[_groups addObject:[states autorelease]];
		}
#ifndef UPGRADE_LEGACY_TO_LEGACY_TEMPLATE
		// add powers
		{
			DMGroup *powers = [DMGroup new];
			powers.name = @"Powers";
			powers.type = DMGroupTypeString;
			
			[powers.keys addObject:@"Basic"];
			[powers.items addObject:@"Melee, +1 vs AC, 1W+CHA, at-will"];
			
			[_groups addObject:[powers autorelease]];
		}
		// add items
		{
			DMGroup *items = [DMGroup new];
			items.name = @"Items";
			items.type = DMGroupTypeCounter;
			
			[items.keys addObject:@"Gold"];
			[items.items addObject:[DMNumber numberWithValue:100]];
			[items.keys addObject:@"Silver"];
			[items.items addObject:[DMNumber numberWithValue:0]];
			[items.keys addObject:@"Adventurer's Kit"];
			[items.items addObject:[DMNumber numberWithValue:1]];
			
			[_groups addObject:[items autorelease]];
		}
		// add misc
		{
			DMGroup *misc = [DMGroup new];
			misc.name = @"Miscelaneous";
			misc.type = DMGroupTypeString;
			
			[_groups addObject:[misc autorelease]];
		}
#endif
		
		self.notes = unit.notes;
		
		_dirty = YES;
	}
	
	return self;
}

- (void) dealloc
{
	[_avatar release];
	[_notes release];
	[_groups release];
	[_initiative release];
	[_HP release];
	[_charClass release];
	[_race release];
	[_avatarName release];
	[_name release];
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
	DMUnit *newUnit = [[[self class] allocWithZone:zone] init];
	newUnit.name = _name;
	newUnit.avatarName = _avatarName;
	newUnit.race = _race;
	newUnit.charClass = _charClass;
	newUnit.player = _player;
	newUnit.level = _level;
	newUnit.HP = _HP;
	newUnit.initiative = _initiative;
	for( DMGroup* group in _groups )
	{
		DMGroup* newGroup = [group copyWithZone:zone];
		[newUnit->_groups addObject:newGroup];
		[newGroup release];
	}
	newUnit->_avatar = [_avatar retain];
	newUnit.notes = _notes;

	return newUnit;
}

- (NSComparisonResult)compare:(id)otherObject
{
	DMUnit* unit = otherObject;
	return [_name caseInsensitiveCompare:unit.name];
}

- (NSComparisonResult)compareInitiative:(DMUnit*)unit
{
	const NSInteger myInitiative = _initiative.value + _initiative.modifier;
	const NSUInteger otherInitiative = unit.initiative.value + unit.initiative.modifier;
	if( myInitiative > otherInitiative )
		return NSOrderedAscending;
	else if (myInitiative < otherInitiative)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}


- (NSMutableArray*) mutableGroups
{
	_dirty = YES;
	return _groups;
}

- (UIImage*) avatar
{
	if( _avatar )
		return _avatar;
	
	if( _avatarName != nil
	   && _avatarName.length != 0 )
	{
		_avatar = [[DMDataManager avatarNamed:_avatarName] retain];
	}
	return _avatar;
}

- (void) setAvatarName:(NSString*)avatarName
{
	[avatarName retain];
	[_avatarName release];
	[_avatar release];
	_avatar = nil;
	_avatarName = [avatarName copy];
	[avatarName release];
}

- (void) clearCache
{
	[_avatar release];
	_avatar = nil;
}

- (NSData*) saveToData
{
	NSMutableString *xmlText = [NSMutableString new];
	[xmlText appendDMToolsHeader];
	[xmlText appendUnit:self
				atLevel:0];
	[xmlText appendDMToolsFooter];
	
	NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
	[xmlText release];
	return data;
}

@end

