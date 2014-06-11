//
//  SERoundView.m
//  DM Tools
//
//  Created by hamouras on 24/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "SERoundView.h"
#import <QuartzCore/CALayer.h>

@implementation SERoundView


/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

	}
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder:coder])
	{
    }
    return self;
}
*/

- (void)layoutSubviews
{
	if (layoutReady)
		return;
	
	CALayer *layer = self.layer;
	CALayer *mask = [CALayer layer];
	mask.frame = layer.bounds;
	mask.cornerRadius = 10.0f;
	mask.backgroundColor = [[UIColor blackColor] CGColor];
	mask.needsDisplayOnBoundsChange = YES;
	layer.mask = mask;
	
	layer.borderColor = [[UIColor lightGrayColor] CGColor];
	layer.borderWidth = 1.0f;
	layer.cornerRadius = 10.0f;
	layer.needsDisplayOnBoundsChange = YES;

	[mask setNeedsDisplay];
	[layer setNeedsDisplay];
	layoutReady = YES;
}


/*
 // Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/
/*
- (void)dealloc {
    [super dealloc];
}
*/

@end
