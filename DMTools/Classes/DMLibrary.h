//
//  DMLibrary.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/13/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMUnit;

@interface DMLibrary : NSObject {
	DMUnit *			_baseTemplate;
	NSMutableArray *	_players;
	NSMutableArray *	_monsters;
	NSString *			_savename;
	BOOL				_dirty;
	BOOL				_readonlyTemplate;
}

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) DMUnit * baseTemplate;
@property (nonatomic, readonly) NSArray * players;
@property (nonatomic, readonly) NSArray * monsters;
@property (nonatomic, readonly) NSMutableArray * mutablePlayers;
@property (nonatomic, readonly) NSMutableArray * mutableMonsters;
@property (nonatomic, copy) NSString * savename;
@property (nonatomic, getter=isDirty) BOOL dirty;
@property (nonatomic, getter=isReadonlyTemplate) BOOL readonlyTemplate;

- (id)initWithReadonlyTemplate:(DMUnit*)baseTemplate;
- (id)initWithTemplate:(DMUnit*)baseTemplate;
- (id)initWithName:(NSString*)name;

- (NSData*) saveToData;
- (void) saveToFile:(NSString *)path;

- (void) clearDirtyStates;

- (NSComparisonResult) compare:(id)otherObject;

@end
