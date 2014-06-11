//
//  DMUnit.h
//  DM Tools
//
//  Created by hamouras on 3/16/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMHitPoints.h"
#import "DMGroup.h"
#import "SECollatedObject.h"

@class UnitEntry;
@class DMNumber;
@class DMHitPoints;

@interface DMUnit : SECollatedObject<NSCopying> {
	NSString *			_name;
	NSString *			_avatarName;
	NSString *			_race;
	NSString *			_charClass;
	BOOL				_player;
	NSInteger			_level;
	DMHitPoints *		_HP;
	DMNumber *			_initiative;
	NSMutableArray *	_groups;
	NSString *			_notes;
	UIImage *			_avatar;
	BOOL				_selected;
	BOOL				_dirty;
}

@property (nonatomic, copy) NSString *						name;
@property (nonatomic, copy) NSString *						avatarName;
@property (nonatomic, copy) NSString *						race;
@property (nonatomic, copy) NSString *						charClass;
@property (nonatomic, assign, getter = isPlayer) BOOL		player;
@property (nonatomic, assign) NSInteger						level;
@property (nonatomic, copy) DMHitPoints *					HP;
@property (nonatomic, copy) DMNumber *						initiative;
@property (nonatomic, readonly) NSArray *					groups;
@property (nonatomic, readonly) NSMutableArray *			mutableGroups;
@property (nonatomic, copy) NSString *						notes;
// runtime data
@property (nonatomic, readonly) NSString *					detailString;
@property (nonatomic, readonly) UIImage *					avatar;
@property (nonatomic, assign, getter = isSelected) BOOL		selected;
@property (nonatomic, assign, getter = isDirty) BOOL		dirty;


- (id) initWithName:(NSString*)name;
- (id) initWithUnitEntry:(UnitEntry *)unit;

- (void) setInfoFromDictionary:(NSDictionary *)dictionary;

- (void) clearCache;

- (NSData*) saveToData;

- (NSComparisonResult) compare:(id)otherObject;
- (NSComparisonResult) compareInitiative:(DMUnit*)unit;

@end
