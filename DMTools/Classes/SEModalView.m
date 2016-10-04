//
//  SEModalView.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 3/26/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "SEModalView.h"
#import "DMSettings.h"
#import "DMToolsAppDelegate.h"

@interface SEModalViewController : UIViewController
@end

@implementation SEModalViewController
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
    return [DMSettings portraitLock] ? (interfaceOrientation == UIInterfaceOrientationPortrait) : YES;
}

@end

@implementation SEModalView

- (void) setupModalView
{
	self.exclusiveTouch = YES;
	// create a view controller to support autorotate
	SEModalViewController* vc = [SEModalViewController new];
	// Initialization code
	_modalWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_modalWindow.windowLevel = UIWindowLevelAlert;
	_modalWindow.rootViewController = vc;
	[vc release];
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
		[self setupModalView];
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self setupModalView];
	}
    return self;
}

- (void) show
{
	_modalWindow.rootViewController.view = self;
	[_modalWindow makeKeyAndVisible];
}

- (void) hide
{
	[self retain];
	[self becomeFirstResponder];
	
	_modalWindow.hidden = YES;
	_modalWindow.rootViewController.view = nil;

	// make original window the key window
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelegate.window makeKeyAndVisible];
	
	[self autorelease];
}

- (void) dealloc
{
	[_modalWindow release];
	[super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
