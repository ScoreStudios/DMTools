//
//  SEAutoInputViewController.h
//  Piczle Lines
//
//  Created by hamouras on 05/07/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEAutoInputViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
	UIView *	currentResponder;
	CGFloat		animatedViewDistance;
	CGFloat		animatedTextBoxHeight;
	CGFloat		keyboardHeight;
	BOOL		keyboardVisible;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)textViewDidBeginEditing:(UITextView *)textField;
- (void)textViewDidEndEditing:(UITextView *)textField;

@end
