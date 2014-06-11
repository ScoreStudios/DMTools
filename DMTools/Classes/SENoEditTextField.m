//
//  SENoEditTextField.m
//  DM Tools
//
//  Created by hamouras on 18/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "SENoEditTextField.h"


@implementation SENoEditTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	if (action == @selector(cut:)
		|| action == @selector(copy:)
		|| action == @selector(paste:))
        return NO;
	
	return [super canPerformAction:action
						withSender:sender];
}

@end
