//
//  RollEntry.m
//  DM Tools
//
//  Created by hamouras on 04/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "RollEntry.h"


@implementation RollEntry

static const NSInteger sDiceValue[DiceType_Max] = { 4, 6, 8, 10, 12, 20 };

@synthesize modifier = _modifier;
@synthesize percentage = _percentage;
@synthesize initiative = _initiative;
@dynamic isEmpty;

+ (NSInteger) diceValue:(DiceType)dice
{
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invald dice number");
	return sDiceValue[dice];
}

+ (NSString *) stringForDice:(NSInteger *)diceArray withModifier:(NSInteger)modifier
{
	NSString *text = @"";
	BOOL first = YES;
	for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
	{
		const NSInteger diceCount = diceArray[i];
		if (diceCount == 0)
			continue;
		
		const NSInteger diceValue = sDiceValue[i];
		text = [text stringByAppendingFormat:
				first ? @"%dd%d" : @" + %dd%d",
				(int)diceCount, (int)diceValue];
		first = NO;
	}
	if (modifier)
	{
		text = [text stringByAppendingFormat:
				modifier < 0 ? @" - %d" : (first ? @"%d" : @" + %d"),
				(int)(modifier < 0 ? -modifier : modifier)];
	}
	return text;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]) != nil)
	{
		_percentage = [decoder decodeBoolForKey:@"kPercent"];
		if( !_percentage )
		{
			_initiative = [decoder decodeBoolForKey:@"KInitiative"];
			if( !_initiative )
			{
				_diceArray[DiceType_D4] = [decoder decodeIntegerForKey:@"kD4"];
				_diceArray[DiceType_D6] = [decoder decodeIntegerForKey:@"kD6"];
				_diceArray[DiceType_D8] = [decoder decodeIntegerForKey:@"kD8"];
				_diceArray[DiceType_D10] = [decoder decodeIntegerForKey:@"kD10"];
				_diceArray[DiceType_D12] = [decoder decodeIntegerForKey:@"kD12"];
				_diceArray[DiceType_D20] = [decoder decodeIntegerForKey:@"kD20"];
				_modifier = [decoder decodeIntegerForKey:@"kModifier"];
			}
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if (_percentage)
		[encoder encodeBool:YES
					 forKey:@"kPercent"];
	else if (_initiative)
		[encoder encodeBool:YES
					 forKey:@"KInitiative"];
	else 
	{
		[encoder encodeInteger:_diceArray[DiceType_D4]
						forKey:@"kD4"];
		[encoder encodeInteger:_diceArray[DiceType_D6]
						forKey:@"kD6"];
		[encoder encodeInteger:_diceArray[DiceType_D8]
						forKey:@"kD8"];
		[encoder encodeInteger:_diceArray[DiceType_D10]
						forKey:@"kD10"];
		[encoder encodeInteger:_diceArray[DiceType_D12]
						forKey:@"kD12"];
		[encoder encodeInteger:_diceArray[DiceType_D20]
						forKey:@"kD20"];
		[encoder encodeInteger:_modifier
						forKey:@"kModifier"];
	}
}

- (id) copyWithZone:(NSZone *)zone
{
	RollEntry *newroll = [[[self class] allocWithZone:zone] init];
	memcpy(newroll->_diceArray, _diceArray, sizeof(_diceArray));
	newroll->_modifier = _modifier;
	newroll->_percentage = _percentage;
	newroll->_initiative = _initiative;
	
	return newroll;
}

- (void) addDice:(DiceType)dice
{
	NSAssert(_initiative == NO && _percentage == NO, @"can't add dice to percentage or initiative roll");
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invald dice number");
	++_diceArray[dice];
}

- (void) removeDice:(DiceType)dice
{
	NSAssert(_initiative == NO && _percentage == NO, @"can't remove dice from percentage or initiative roll");
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invald dice number");
	if (_diceArray[dice])
		--_diceArray[dice];
}

- (void) clear
{
	memset(_diceArray, 0, sizeof(_diceArray));
	_modifier = 0;
}

- (NSInteger) roll
{
	if (_initiative)
		return 0;
	else if (_percentage)
	{
		const NSInteger roll1 = rand() % 10;
		const NSInteger roll2 = rand() % 10;
		return (roll1 || roll2) ? (roll1 * 10 + roll2) : 100;
	}
	else
	{
		NSInteger value = _modifier;
		for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
		{
			const NSInteger diceValue = sDiceValue[i];
			const NSInteger diceCount = _diceArray[i];
			for (NSInteger j = 0 ; j < diceCount ; ++j)
			{	
				value += rand() % diceValue + 1;
			}
		}
		return value;
	}
}

- (NSString *) rollToString
{
	if (_initiative)
		return nil;
	if (_percentage)
	{
		const NSInteger roll1 = rand() % 10;
		const NSInteger roll2 = rand() % 10;
		return [NSString stringWithFormat:
				@"(%d, %d) = %d",
				(int)roll1, (int)roll2,
				(int)((roll1 || roll2) ? (roll1 * 10 + roll2) : 100)];
	}
	else
	{
		NSString *text = @"";
		NSInteger value = 0;
		BOOL first = YES;
		for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
		{
			const NSInteger diceCount = _diceArray[i];
			if (diceCount == 0)
				continue;
			
			text = [text stringByAppendingString:first ? @"(" : @" + ("];
			first = NO;
			
			BOOL firstNum = YES;
			const NSInteger diceValue = sDiceValue[i];
			for (NSInteger j = 0 ; j < diceCount ; ++j)
			{
				const NSInteger curValue = rand() % diceValue + 1;
				text = [text stringByAppendingFormat:
						firstNum ? @"%d" : @" + %d",
						(int)curValue];
				value += curValue;
				firstNum = NO;
			}
			text = [text stringByAppendingString:@")"];
		}
		if (_modifier)
		{
			text = [text stringByAppendingFormat:
					_modifier < 0 ? @" - %d" : (first ? @"%d" : @" + %d"),
					(int)(_modifier < 0 ? -_modifier : _modifier)];
			value += _modifier;
		}
		text = [text stringByAppendingFormat:@" = %d", (int)value];
		return text;
	}
}

- (NSString *) toString
{
	if (_percentage)
		return @"Percentage";
	else if (_initiative)
		return @"Roll Initiative";
	else
		return [RollEntry stringForDice:_diceArray
						   withModifier:_modifier];
}

- (BOOL) isEmpty
{
	if (_percentage)
		return NO;
	
	for (NSInteger i = 0 ; i < DiceType_Max ; ++i)
	{
		if (_diceArray[i])
			return NO;
	}
	
	return YES;
}

- (NSInteger) dice:(DiceType)dice
{
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invald dice number");
	return _diceArray[dice];
}

- (void) setDice:(DiceType)dice toValue:(NSInteger)value
{
	NSAssert(dice >= 0 && dice < DiceType_Max, @"invald dice number");
	_diceArray[dice] = value;
}

@end
