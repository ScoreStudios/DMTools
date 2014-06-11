//
//  DMAvatarCell.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/18/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMAvatarCell.h"

@implementation DMAvatarCell

@synthesize avatars = _avatars;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) dealloc
{
	[_avatars release];
	[super dealloc];
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

@end
