//
//  DMHitPoints.h
//  DM Tools
//
//  Created by hamouras on 3/22/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DMHitPoints : NSObject<NSCopying> {
    NSInteger	_value;
	NSInteger	_maxValue;
}

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger maxValue;

+ (DMHitPoints *) hitPointsWithValue:(NSInteger) value withMaxValue:(NSInteger) maxValue;
+ (DMHitPoints *) hitPointsFromString:(NSString *) string;

- (NSString *) toString;
- (NSString *) toShortString;

@end
