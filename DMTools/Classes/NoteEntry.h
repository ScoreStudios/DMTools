//
//  NoteEntry.h
//  DM Tools
//
//  Created by Paul Caristino on 6/5/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoteEntry : NSObject<NSCoding, NSCopying>
{

	NSString *	title;    // title of entry
	NSString *  details;  // detail text
	NSString *  notes; // notes on entry
	NSString *  group; // group it belongs to
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSString *group;

- (NSComparisonResult) compare:(id)otherObject;

@end
