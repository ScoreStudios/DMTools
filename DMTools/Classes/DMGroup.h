//
//  DMGroup.h
//  DM Tools
//
//  Created by hamouras on 3/23/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DMGroupType
{
	DMGroupTypeString	= 0,
	DMGroupTypeBoolean,
	DMGroupTypeCounter,
	DMGroupTypeValue,
	DMGroupTypeValueModifier
} DMGroupType;

@interface DMGroup : NSObject<NSCopying> {
	NSString *			_name;
	DMGroupType			_type;
	NSMutableArray *	_keys;
	NSMutableArray *	_items;
	BOOL				_canDisplayAttribs;
	BOOL				_canDisplayStates;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) DMGroupType type;
@property (nonatomic, readonly) NSMutableArray * keys;
@property (nonatomic, readonly) NSMutableArray * items;
@property (nonatomic, readonly) BOOL canDisplayAttribs;
@property (nonatomic, readonly) BOOL canDisplayStates;

- (id) initWithDictionary:(NSDictionary *)dictionary;

- (id) objectWithKey:(NSString*)key;
- (NSInteger) objectIndexWithKey:(NSString*)key;

@end
