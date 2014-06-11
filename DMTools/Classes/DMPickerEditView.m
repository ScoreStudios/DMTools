//
//  DMPickerEditView.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/8/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMPickerEditView.h"

@implementation DMPickerEditView

@synthesize title = _title, picker = _picker, delegate = _delegate;

+ (DMPickerEditView *) pickerEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									withImages:(NSArray*)images
							 withSelectedIndex:(NSUInteger)selectedIndex
{
	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"DMPickerEditView"
														owner:nil
													  options:nil];
	DMPickerEditView *pickerEditView = (DMPickerEditView *) [nibObjects objectAtIndex:0];
	
	pickerEditView->_items = [images retain];
	pickerEditView->_itemType = ItemTypeImage;
	
	pickerEditView.title.text = title;
	pickerEditView.title.enabled = !readOnlyTitle;
	pickerEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	pickerEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	[pickerEditView.picker selectRow:selectedIndex
						 inComponent:0
							animated:NO];
	
	[pickerEditView.picker becomeFirstResponder];

	return pickerEditView;
}

+ (DMPickerEditView *) pickerEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
								   withStrings:(NSArray*)strings
							 withSelectedIndex:(NSUInteger)selectedIndex
{
	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"DMPickerEditView"
														owner:nil
													  options:nil];
	DMPickerEditView *pickerEditView = (DMPickerEditView *) [nibObjects objectAtIndex:0];
	
	pickerEditView->_items = [strings retain];
	pickerEditView->_itemType = ItemTypeString;
	
	pickerEditView.title.text = title;
	pickerEditView.title.enabled = !readOnlyTitle;
	pickerEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	pickerEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	[pickerEditView.picker selectRow:selectedIndex
						 inComponent:0
							animated:NO];
	
	[pickerEditView.picker becomeFirstResponder];
	
	return pickerEditView;
}


- (void)dealloc
{
	[_title release];
	[_picker release];
	[_items release];
	
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
	NSUInteger selectedIndex = [_picker selectedRowInComponent:0];
	[_delegate pickerEditViewDone:self
						withTitle:_title.text
				withSelectedIndex:selectedIndex];
	
	[super hide];
}

- (void) cancel
{
	[_delegate pickerEditViewCancelled:self];
	
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
	if( [_delegate respondsToSelector:@selector(editView:isValidTitle:)] )
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	return _items.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	switch (_itemType)
	{
		case ItemTypeImage:
		{
			UIImageView* imageView;
			UIImage* image = [_items objectAtIndex:row];
			if( [view isKindOfClass:[UIImageView class]] )
			{
				imageView = (UIImageView*) view;
				imageView.image = image;
			}
			else
				imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
			
			return imageView;
		}
		
		case ItemTypeString:
		{
			UILabel* label;
			if( [view isKindOfClass:[UILabel class]] )
			{
				label = (UILabel*) view;
			}
			else
			{
				CGRect frame = CGRectMake( 0.0f, 0.0f, 0.0f, 0.0f);
				label = [[[UILabel alloc] initWithFrame:frame] autorelease];
				label.backgroundColor = [UIColor clearColor];
				label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
				label.textAlignment = UITextAlignmentCenter;
			}
			
			label.text = [_items objectAtIndex:row];
			return label;
		}
	};
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[self becomeFirstResponder];
}


@end
