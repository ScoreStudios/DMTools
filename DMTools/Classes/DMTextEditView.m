//
//  DMTextEditView.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/10/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMTextEditView.h"

@implementation DMTextEditView

@synthesize title = _title, text = _text, delegate = _delegate;

+ (DMTextEditView *) textEditViewWithTitle:(NSString *)title
						   titleIsReadOnly:(BOOL)readOnlyTitle
								  withText:(NSString *)text
{
	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"DMTextEditView"
														owner:nil
													  options:nil];
	DMTextEditView *textEditView = (DMTextEditView *) [nibObjects objectAtIndex:0];
	
	textEditView.title.text = title;
	textEditView.title.enabled = !readOnlyTitle;
	textEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	textEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	textEditView.text.text = text;
	[textEditView.text becomeFirstResponder];
	
	return textEditView;
}


- (void)dealloc
{
	[_text release];
	[_title release];
   [super dealloc];
}

- (void)show
{
	self.alpha = 0.0f;
	[UIView beginAnimations:nil
					context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
  	[self setAlpha:1.0f];
    [UIView commitAnimations];
	
	[super show];
}

-(BOOL) canBecomeFirstResponder
{
	return YES;
}

#pragma mark -
#pragma mark button events

- (void) done
{
	[_delegate textEditViewDone:self
					  withTitle:_title.text
					   withText:_text.text];
	
	[super hide];
}

- (void) cancel
{
	[_delegate textEditViewCancelled:self];
	
	[super hide];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self becomeFirstResponder];
}

#pragma mark -
#pragma mark delegate functions

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if( textField == _title
	   && [_delegate respondsToSelector:@selector(editView:isValidTitle:)] )
	{
		NSString* newString = [textField.text stringByReplacingCharactersInRange:range
																	  withString:string];
		if( [_delegate editView:self
				   isValidTitle:newString] )
			textField.textColor = [UIColor blackColor];
		else
			textField.textColor = [UIColor redColor];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
