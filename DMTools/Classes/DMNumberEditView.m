//
//  DMNumberEditView.m
//  DM Tools
//
//  Created by hamouras on 23/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "DMNumberEditView.h"
#import "DMNumber.h"

#define kPickerModeSelect	@"kPickerMode"

@implementation DMNumberEditView

@synthesize title = _title, modeSelector = _modeSelector, picker = _picker, delegate = _delegate;

+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
								   withCounter:(NSInteger)counter
{
	counter = Clamp( counter, -kCounterRange, kCounterRange );

	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"DMNumberEditView"
														owner:nil
													  options:nil];
	DMNumberEditView *numberEditView = (DMNumberEditView *) [nibObjects objectAtIndex:0];
	numberEditView->_mode = ModeCounter;
	numberEditView->_originalModifier = 0;
	
	numberEditView.title.text = title;
	numberEditView.title.enabled = !readOnlyTitle;
	numberEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	numberEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	[numberEditView.picker selectRow:counter >= 0 ? 0 : 1
						 inComponent:0
							animated:NO];
	counter = labs( counter );
	[numberEditView.picker selectRow:(counter / 1000)
						 inComponent:1
							animated:NO];
	counter %= 1000;
	[numberEditView.picker selectRow:(counter / 100)
						 inComponent:2
							animated:NO];
	counter %= 100;
	[numberEditView.picker selectRow:(counter / 10)
						 inComponent:3
							animated:NO];
	counter %= 10;
	[numberEditView.picker selectRow:(counter)
						 inComponent:4
							animated:NO];
	
	[numberEditView.picker becomeFirstResponder];
	return numberEditView;
}

+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									 withValue:(NSInteger)value
{
	value = Clamp( value, kValueMinRange, kValueMaxRange );
	
	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"DMNumberEditView"
														owner:nil
													  options:nil];
	DMNumberEditView *numberEditView = (DMNumberEditView *) [nibObjects objectAtIndex:0];	
	numberEditView->_mode = ModeValue;
	numberEditView->_originalModifier = 0;
	
	numberEditView.title.text = title;
	numberEditView.title.enabled = !readOnlyTitle;
	numberEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	numberEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	[numberEditView.picker selectRow:( value - kValueMinRange )
						 inComponent:0
							animated:NO];
	
	[numberEditView.picker becomeFirstResponder];
	return numberEditView;
}

+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									 withValue:(NSInteger)value
								  withModifier:(NSInteger)modifier
							   hasModeSelector:(BOOL)hasModeSelector
{
	value = Clamp( value, kValueMinRange, kValueMaxRange );
	modifier = Clamp( modifier, kModifierMinRange, kModifierMaxRange );
	
	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:hasModeSelector ? @"DMNumberEditViewEx" : @"DMNumberEditView"
														owner:nil
													  options:nil];
	DMNumberEditView *numberEditView = (DMNumberEditView *) [nibObjects objectAtIndex:0];	
	numberEditView->_mode = ModeValueModifier;
	numberEditView->_originalModifier = modifier;
	
	numberEditView.title.text = title;
	numberEditView.title.enabled = !readOnlyTitle;
	numberEditView.title.borderStyle = readOnlyTitle ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
	numberEditView.title.textColor = readOnlyTitle ? [UIColor whiteColor] : [UIColor blackColor];
	
	NSInteger pickerMode = [[NSUserDefaults standardUserDefaults] integerForKey:kPickerModeSelect];
	if( hasModeSelector && pickerMode )
	{
		[numberEditView.picker selectRow:( value + modifier - kValueModMinRange )
							 inComponent:0
								animated:NO];
	}
	else
	{
		[numberEditView.picker selectRow:( value - kValueMinRange )
							 inComponent:0
								animated:NO];
		[numberEditView.picker selectRow:( modifier - kModifierMinRange )
							 inComponent:1
								animated:NO];
	}

	numberEditView.modeSelector.selectedSegmentIndex = pickerMode;
	[numberEditView.picker reloadAllComponents];
	
	[numberEditView.picker becomeFirstResponder];
	return numberEditView;
}

- (void)dealloc
{
	[_title release];
	[_modeSelector release];
	[_picker release];
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
#pragma mark segmented control events
- (IBAction) modeChanged
{
	NSAssert(_modeSelector && _mode == ModeValueModifier, @"only extended UI suports this event");
	NSInteger pickerMode = _modeSelector.selectedSegmentIndex;
	[[NSUserDefaults standardUserDefaults] setInteger:pickerMode
											   forKey:kPickerModeSelect];

	if (pickerMode)
	{
		NSInteger value = kValueMinRange + [_picker selectedRowInComponent:0];
		NSInteger modifier = kModifierMinRange + [_picker selectedRowInComponent:1];
		_originalModifier = modifier;
		[self becomeFirstResponder];
		[_picker reloadAllComponents];
		[_picker selectRow:(value + modifier - kValueModMinRange)
			   inComponent:0
				  animated:NO];
	}
	else
	{
		NSInteger value = kValueModMinRange + [_picker selectedRowInComponent:0];
		NSInteger modifier = 0;
		DecomposeValue( &value,
					   &modifier,
					   value,
					   _originalModifier,
					   kValueMinRange, kValueMaxRange,
					   kModifierMinRange, kModifierMaxRange );
		[self becomeFirstResponder];
		[_picker reloadAllComponents];
		[_picker selectRow:(value - kValueMinRange)
			   inComponent:0
				  animated:NO];
		[_picker selectRow:(modifier - kModifierMinRange)
			   inComponent:1
				  animated:NO];
	}
}

#pragma mark -
#pragma mark button events

- (void) done
{
	NSInteger value = 0;
	NSInteger modifier = 0;
	if( _mode == ModeCounter )
	{
		value += [_picker selectedRowInComponent:1] * 1000;
		value += [_picker selectedRowInComponent:2] * 100;
		value += [_picker selectedRowInComponent:3] * 10;
		value += [_picker selectedRowInComponent:4];
		value *= [_picker selectedRowInComponent:0] ? -1 : 1;
	}
	else
	{
		value = kValueMinRange + [_picker selectedRowInComponent:0];
		if( _mode == ModeValueModifier )
		{
			if (_modeSelector.selectedSegmentIndex)
				DecomposeValue( &value,
							   &modifier,
							   value,
							   _originalModifier,
							   kValueMinRange, kValueMaxRange,
							   kModifierMinRange, kModifierMaxRange );
			else
				modifier = kModifierMinRange + [_picker selectedRowInComponent:1];
		}
	}
	
	[_delegate numberEditViewDone:self
						withTitle:_title.text
						withValue:value
					 withModifier:modifier];
	
	[super hide];
}

- (void) cancel
{
	[_delegate numberEditViewCancelled:self];
	
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
	if( _mode == ModeCounter )
		return 5;
	else if( _mode == ModeValue )
		return 1;
	else
		return (_modeSelector.selectedSegmentIndex ? 1 : 2);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	if( _mode == ModeCounter )
		return component ? 10 : 2;
	else
	{
		if( _mode == ModeValue )
			return kValueMaxRange - kValueMinRange;
		else
		{
			if( component )
				return kModifierMaxRange - kModifierMinRange;
			else
				return (_modeSelector.selectedSegmentIndex ? ( kValueModMaxRange - kValueModMinRange ) : ( kValueMaxRange - kValueMinRange ));
		}
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
	if( _mode == ModeCounter )
	{
		if( component )
			return [NSString stringWithFormat:@"%d", (int)row];
		else
			return row ? @"-" : @"+";
	}
	else
	{
		NSInteger offset = 0;
		if( _mode == ModeValue )
			offset = kValueMinRange;
		else
		{
			if( component )
				offset = kModifierMinRange;
			else
				offset = (_modeSelector.selectedSegmentIndex ? kValueModMinRange : kValueMinRange);
		}
		
		return [NSString stringWithFormat:@"%d", (int)(offset + row)];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[self becomeFirstResponder];
}


@end
