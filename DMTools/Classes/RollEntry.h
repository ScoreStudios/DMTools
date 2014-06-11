//
//  RollEntry.h
//  DM Tools
//
//  Created by hamouras on 04/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DiceType
{
	DiceType_D4		= 0,
	DiceType_D6,
	DiceType_D8,
	DiceType_D10,
	DiceType_D12,
	DiceType_D20,
	
	DiceType_Max
} DiceType;

@interface RollEntry : NSObject<NSCoding, NSCopying>
{
	NSInteger	_diceArray[DiceType_Max];
	NSInteger	_modifier;
	BOOL		_percentage;
	BOOL		_initiative;
}

@property (nonatomic, assign) NSInteger modifier;
@property (nonatomic, assign, getter=isPercentage) BOOL percentage;
@property (nonatomic, assign, getter=isInitiative) BOOL initiative;
@property (nonatomic, readonly) BOOL isEmpty;

+ (NSInteger) diceValue:(DiceType)dice;
+ (NSString *) stringForDice:(NSInteger *)diceArray withModifier:(NSInteger)modifier;

- (void) addDice:(DiceType)dice;
- (void) removeDice:(DiceType)dice;
- (void) clear;

- (NSInteger) roll;
- (NSString *) rollToString;

- (NSInteger) dice:(DiceType)dice;
- (void) setDice:(DiceType)dice toValue:(NSInteger)value;
- (NSString *) toString;

@end
