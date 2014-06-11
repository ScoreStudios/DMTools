//
//  UnitEntry.h
//  DM Tools
//
//  Created by Paul Caristino on 6/4/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
	eUnitStateMarked		= (1 << 0),
	eUnitStateDazed			= (1 << 1),
	eUnitStateStunned		= (1 << 2),
	eUnitStateSlowed		= (1 << 3),
	eUnitStateDeafened		= (1 << 4),
	eUnitStateBlinded		= (1 << 5),
	eUnitStateWeakened		= (1 << 6),
	eUnitStateImmobilized	= (1 << 7),
	eUnitStateProne			= (1 << 8)
};

@interface UnitEntry : NSObject<NSCoding> {
	NSString *	name;
	NSInteger	HP;
	NSInteger	maxHP;
	NSInteger	initiative;
	NSInteger	initMod;
	NSInteger	AC;
	NSInteger	fortitude;
	NSInteger	reflex;
	NSInteger	will;
	NSString *	notes; // notes on monster
	BOOL		player; // player flag
	NSInteger	hitModifier;
	NSInteger	acModifier;
	NSInteger	ongoing;
	NSUInteger	stateFlags;
	BOOL		selected;	// used in the initiative table
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, assign) NSInteger HP;
@property (nonatomic, assign) NSInteger maxHP;
@property (nonatomic, assign) NSInteger initiative;
@property (nonatomic, assign) NSInteger initMod;
@property (nonatomic, assign) NSInteger ac;
@property (nonatomic, assign) NSInteger fort;
@property (nonatomic, assign) NSInteger reflex;
@property (nonatomic, assign) NSInteger will;
@property (nonatomic, assign) BOOL player;
@property (nonatomic, assign) NSInteger hitModifier;
@property (nonatomic, assign) NSInteger acModifier;
@property (nonatomic, assign) NSInteger ongoing;
@property (nonatomic, assign) NSUInteger stateFlags;
@property (nonatomic, assign) BOOL selected;

@end

@interface Encounter : NSObject<NSCoding> {
	NSString *			_name;
	NSMutableArray *	_units;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, readonly) NSArray * units;

@end
