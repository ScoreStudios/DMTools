//
//  DMNumber.m
//  DM Tools
//
//  Created by hamouras on 3/22/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMNumber.h"

@implementation DMBoolean
@synthesize value = _value, display = _display;

+ (DMBoolean *) booleanWithValue:(BOOL) value
{
	DMBoolean *boolean = [DMBoolean new];
	boolean->_value = value;
	boolean->_display = 0;
	
	return [boolean autorelease];
}

+ (DMBoolean *) booleanFromString:(NSString *) string
{
	return [DMBoolean booleanWithValue:[string isEqualToString:@"true"] || [string isEqualToString:@"1"]];
}


- (id) copyWithZone:(NSZone *)zone
{
	DMBoolean *boolean = [[[self class] allocWithZone:zone] init];
	boolean->_value = _value;
	boolean->_display = _display;
	
	return boolean;
}

- (NSString *) toString
{
	return _value ? @"true" : @"false";
}

- (NSString *) toShortString
{
	return _value ? @"1" : @"0";
}

@end

@implementation DMNumber
@synthesize value = _value, modifier = _modifier, display = _display;

+ (DMNumber *) numberWithValue:(NSInteger) value
{
	DMNumber *number = [DMNumber new];
	number->_value = value;
	number->_modifier = 0;
	number->_display = 0;
	
	return [number autorelease];
}

+ (DMNumber *) numberWithValue:(NSInteger) value withModifier:(NSInteger)modifier
{
	DMNumber *number = [DMNumber new];
	number->_value = value;
	number->_modifier = modifier;
	number->_display = 0;
	
	return [number autorelease];
}

+ (DMNumber *) numberFromString:(NSString *) string
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSInteger val = 0;

	[scanner scanInteger:&val];
	return [DMNumber numberWithValue:val];
}

+ (DMNumber *) numberWithModifierFromString:(NSString *) string
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSInteger val = 0, mod = 0;
	
	[scanner scanInteger:&val];
	
	NSString* sign = nil;
	[scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"]
						intoString:&sign];
	[scanner scanInteger:&mod];
	if( [sign isEqualToString:@"-"] )
		mod = -mod;
	return [DMNumber numberWithValue:val
						withModifier:mod];
}

- (id) copyWithZone:(NSZone *)zone
{
	DMNumber *number = [[[self class] allocWithZone:zone] init];
	number->_value = _value;
	number->_modifier = _modifier;
	number->_display = _display;
	
	return number;
}

- (NSString *) toString
{
	if (_modifier >= 0)
		return [NSString stringWithFormat:@"%d + %d", (int)_value, (int)_modifier];
	else
		return [NSString stringWithFormat:@"%d - %d", (int)_value, (int)-_modifier];
}

- (NSString *) toShortString
{
	if (_modifier >= 0)
		return [NSString stringWithFormat:@"%d+%d", (int)_value, (int)_modifier];
	else
		return [NSString stringWithFormat:@"%d-%d", (int)_value, (int)-_modifier];
}

- (NSString *) valueToString
{
	return [NSString stringWithFormat:@"%d", (int)_value];
}

- (NSString *) modifierToString
{
	return [NSString stringWithFormat:@"%d", (int)_modifier];
}

- (NSString *) totalToString
{
	return [NSString stringWithFormat:@"%d", (int)(_value + _modifier)];
}

@end
