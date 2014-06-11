//
//  DMEncounter.h
//  DM Tools
//
//  Created by hamouras on 27/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SECollatedObject.h"

// keeping NSCoding protocol as legacy code
@interface DMEncounter : SECollatedObject
{
	NSString *			_name;
	NSMutableArray *	_units;
	BOOL				_dirty;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, readonly) NSArray * units;
@property (nonatomic, readonly) NSMutableArray * mutableUnits;
@property (nonatomic, getter=isDirty) BOOL dirty;

-(id)initWithName:(NSString *)name;

- (NSComparisonResult)compare:(id) otherObject;

- (void) saveToFile:(NSString *)path;
- (NSData*) saveToData;

- (void) replaceUnitsArray:(NSMutableArray*)newUnits;

- (NSUInteger) numberOfPlayers;
- (NSUInteger) numberOfMonsters;

- (void) clearDirtyStates;

@end
