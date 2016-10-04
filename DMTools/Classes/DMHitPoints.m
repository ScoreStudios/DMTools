//
//  DMHitPoints.m
//  DM Tools
//
//  Created by hamouras on 3/22/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMHitPoints.h"


@implementation DMHitPoints
@synthesize value = _value, maxValue = _maxValue;

+ (DMHitPoints *) hitPointsWithValue:(NSInteger) value withMaxValue:(NSInteger) maxValue;
{
	DMHitPoints *hp = [DMHitPoints new];
	hp.value = value;
	hp.maxValue = maxValue;
	
	return [hp autorelease];
}

+ (DMHitPoints *) hitPointsFromString:(NSString *) string;
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSInteger val = 0, maxVal = 0;
	
	[scanner scanInteger:&val];
	[scanner scanString:@"/"
			 intoString:nil];
	[scanner scanInteger:&maxVal];
	return [DMHitPoints hitPointsWithValue:val
							  withMaxValue:maxVal];
}

- (id) copyWithZone:(NSZone *)zone
{
	DMHitPoints *hp = [[[self class] allocWithZone:zone] init];
	hp.value = _value;
	hp.maxValue = _maxValue;
	
	return hp;
}

- (NSString *) toString
{
	return [NSString stringWithFormat:@"%d / %d", (int)_value, (int)_maxValue];
}

- (NSString *) toShortString
{
	return [NSString stringWithFormat:@"%d/%d", (int)_value, (int)_maxValue];
}

@end
