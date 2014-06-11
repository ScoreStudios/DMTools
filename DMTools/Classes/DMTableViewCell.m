//
//  DMTableViewCell.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/9/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMTableViewCell.h"

@implementation DMTableViewCell

@synthesize control = _control, imageViewInteractive = _imageViewInteractive;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<DMTableViewCellDelegate>)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		_control = nil;
		if( delegate )
		{
			UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.backgroundColor = [UIColor clearColor];
			[button addTarget:self
					   action:@selector(buttonAction:)
			 forControlEvents:UIControlEventTouchUpInside];
			button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			
			_button = [button retain];
			_delegate = delegate;
		}
	}
    return self;
}

- (void) setImageViewInteractive:(BOOL)imageViewInteractive
{
	if( _button
	   && _imageViewInteractive != imageViewInteractive )
	{
		if( imageViewInteractive )
			[self.imageView addSubview:_button];
		else
			[_button removeFromSuperview];

		self.imageView.userInteractionEnabled = imageViewInteractive;
		_imageViewInteractive = imageViewInteractive;
	}
}

- (void) buttonAction:(id)sender
{
	[_delegate tableViewCellImageAction:self];
}

- (void) dealloc
{
	[_button release];
	[_control release];
	[super dealloc];
}

@end
