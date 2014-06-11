//
//	SEAutoFocusView.m
//	Piczle Lines
//
//	Created by hamouras on 05/07/2010.
//	Copyright 2010 Score Studios. All rights reserved.
//

#import "SEAutoFocusView.h"

@implementation SEAutoFocusView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self becomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder
{
	return YES;
}

@end

@implementation SEAutoFocusScrollView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self becomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder
{
	return YES;
}

@end

@implementation SEAutoFocusTableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches
			  withEvent:event];
	[self becomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder
{
	return YES;
}

@end
