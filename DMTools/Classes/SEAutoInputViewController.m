//
//	SEAutoInputViewController.m
//	Piczle Lines
//
//	Created by hamouras on 05/07/2010.
//	Copyright 2010 Score Studios. All rights reserved.
//

#import "SEAutoInputViewController.h"

@interface SEAutoInputViewController()
@property (nonatomic, retain) UIView *originalView;
@end

#define kTextBoxRescalePadding		5.0f
#define kKeyboardAnimationDuration	0.3f
#define kMinimumScrollFraction		0.2f
#define kMaximumScrollFraction		0.8f

@implementation SEAutoInputViewController

@synthesize originalView;

/*
 // The designated initializer.	 Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


/* // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
*/
/*
- (void)viewDidUnload
{
 [super viewDidUnload];
}
 */

- (void) adjustCurrentResponder
{
	UIWindow *window = self.view.window;
	UIView *rootView = self.view;
	UIView *parentView = rootView.superview;
	while (parentView
		   && parentView != window)
	{
		rootView = parentView;
		parentView = rootView.superview;
	}
	CGRect viewRect = [rootView convertRect:self.view.bounds
								   fromView:self.view];
	CGRect textRect = [rootView convertRect:currentResponder.bounds
								   fromView:currentResponder];

	CGRect screenSize = [[UIScreen mainScreen] bounds];
	const UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	const BOOL landscape = (orientation == UIDeviceOrientationLandscapeLeft
							|| orientation == UIDeviceOrientationLandscapeRight);
	const CGFloat screenHeight = landscape ? screenSize.size.width : screenSize.size.height;
	const CGFloat keyboardOrigin = screenHeight - keyboardHeight;
	if (viewRect.origin.y + viewRect.size.height < keyboardOrigin)
	{
		animatedTextBoxHeight = 0.0f;
		animatedViewDistance = 0.0f;
		return;
	}
	
	if ([currentResponder isKindOfClass:[UITextField class]])
	{
		const CGFloat midline = textRect.origin.y + 0.5f * textRect.size.height;
		const CGFloat numerator = midline - viewRect.origin.y - kMinimumScrollFraction * viewRect.size.height;
		const CGFloat denominator = (kMaximumScrollFraction - kMinimumScrollFraction) * viewRect.size.height;
		CGFloat heightFraction = numerator / denominator;
		if (heightFraction < 0.0f)
			heightFraction = 0.0f;
		else if (heightFraction > 1.0f)
			heightFraction = 1.0f;
		CGFloat overlappedHeight = viewRect.origin.y + viewRect.size.height - keyboardOrigin;
		if (overlappedHeight < 0.0f)
			overlappedHeight = 0.0f;
		
		animatedTextBoxHeight = 0.0f;
		animatedViewDistance = overlappedHeight * heightFraction;
	}
	else
	{
		const CGFloat maxHeight = keyboardOrigin - viewRect.origin.y - 2.0f * kTextBoxRescalePadding;
		animatedTextBoxHeight = (textRect.size.height > maxHeight) ? (textRect.size.height - maxHeight) : 0.0f;
		const CGFloat targetPosition = keyboardOrigin - kTextBoxRescalePadding - (textRect.size.height - animatedTextBoxHeight);
		animatedViewDistance = (textRect.origin.y > targetPosition) ? (textRect.origin.y - targetPosition) : 0.0f;
	}

	CGRect textFrame = currentResponder.frame;
    textFrame.size.height -= animatedTextBoxHeight;
 	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedViewDistance;
    
    [UIView beginAnimations:nil
					context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    
    [currentResponder setFrame:textFrame];
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void) revertCurrentResponder
{
	CGRect textFrame = currentResponder.frame;
    textFrame.size.height += animatedTextBoxHeight;
 	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedViewDistance;
    
    [UIView beginAnimations:nil
					context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    
    [currentResponder setFrame:textFrame];
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
	if (keyboardVisible)
        return;
	keyboardVisible = YES;
	
	NSDictionary* info = [notification userInfo];
	NSValue* value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
	keyboardHeight = keyboardSize.height;
	
	[self adjustCurrentResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!keyboardVisible)
        return;
	keyboardVisible = NO;
	
	if (currentResponder)
		[self revertCurrentResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidAppear:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

/*
- (void)dealloc
{
	[super dealloc];
}
*/

#pragma mark Keyboard delegate functions

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	currentResponder = textField;
	
	if (keyboardVisible)
		[self adjustCurrentResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	if (keyboardVisible)
		[self revertCurrentResponder];

	currentResponder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	const NSInteger tag = textField.tag;
	UIView *nextResponder = tag ? [self.view viewWithTag:(tag + 1)] : nil;
	if ([nextResponder isKindOfClass:[UITextField class]]
		|| [nextResponder isKindOfClass:[UITextView class]])
		[nextResponder becomeFirstResponder];
	else
		[textField resignFirstResponder];
	
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	currentResponder = textView;
	
	if (keyboardVisible)
		[self adjustCurrentResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
	if (keyboardVisible)
		[self revertCurrentResponder];
	
	currentResponder = nil;
}

#pragma mark animation delegate functions

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation
								   duration:duration];
	[currentResponder resignFirstResponder];
}


@end
