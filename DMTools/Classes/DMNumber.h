//
//  DMNumber.h
//  DM Tools
//
//  Created by hamouras on 3/22/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kValueMinRange		(-20)
#define kValueMaxRange		(100)
#define kModifierMinRange	(-20)
#define kModifierMaxRange	(100)
#define kValueModMinRange	(kValueMinRange + kModifierMinRange)
#define kValueModMaxRange	(kValueMaxRange + kModifierMaxRange)
#define kCounterRange		(9999)

NS_INLINE NSInteger Min(NSInteger a, NSInteger b)
{
	return (a < b) ? a : b;
}

NS_INLINE NSInteger Max(NSInteger a, NSInteger b)
{
	return (a > b) ? a : b;
}

NS_INLINE NSInteger Clamp(NSInteger value, NSInteger min, NSInteger max)
{
	return (value < min) ? min : ( (value > max) ? max : value );
}

NS_INLINE void DecomposeValue( NSInteger * __restrict value,
							  NSInteger * __restrict modifier,
							  const NSInteger totalValue,
							  const NSInteger origModifier,
							  const NSInteger min,
							  const NSInteger max,
							  const NSInteger minMod,
							  const NSInteger maxMod )
{
	*value = Clamp( totalValue - origModifier, min, max );
	*modifier = Clamp( totalValue - *value, minMod, maxMod );
}


@interface DMBoolean : NSObject<NSCopying> {
	BOOL		_value;
	NSUInteger	_display;
}

@property (nonatomic, assign) BOOL value;
@property (nonatomic, assign) NSUInteger display;

+ (DMBoolean *) booleanWithValue:(BOOL) value;
+ (DMBoolean *) booleanFromString:(NSString *) string;

- (NSString *) toString;
- (NSString *) toShortString;

@end

@interface DMNumber : NSObject<NSCopying> {
	NSInteger	_value;
	NSInteger	_modifier;
	NSUInteger	_display;
}

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger modifier;
@property (nonatomic, assign) NSUInteger display;

+ (DMNumber *) numberWithValue:(NSInteger) value;
+ (DMNumber *) numberWithValue:(NSInteger) value withModifier:(NSInteger) modifier;
+ (DMNumber *) numberFromString:(NSString *) string;
+ (DMNumber *) numberWithModifierFromString:(NSString *) string;

- (NSString *) toString;
- (NSString *) toShortString;
- (NSString *) valueToString;
- (NSString *) modifierToString;
- (NSString *) totalToString;

@end
