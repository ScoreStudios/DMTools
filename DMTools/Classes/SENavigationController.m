//
//  SENavigationController.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 5/11/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "SENavigationController.h"
#import "SEPushPopViewControllerProtocol.h"

@implementation SENavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
		[viewController performSelector:@selector(willBePushedByNavigationController:)
							 withObject:self];
	[super pushViewController:viewController
					 animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController* viewController = self.topViewController;
	if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
		[viewController performSelector:@selector(willBePoppedByNavigationController:)
							 withObject:self];
	return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	const NSUInteger count = self.viewControllers.count;
	for( NSInteger i = count - 1 ; i > 0 ; --i )
	{
		UIViewController* viewController = [self.viewControllers objectAtIndex:i];
		if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
			[viewController performSelector:@selector(willBePoppedByNavigationController:)
								 withObject:self];
	}
	return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	const NSUInteger count = self.viewControllers.count;
	for( NSInteger i = count - 1 ; i > 0 ; --i )
	{
		UIViewController* curViewcontroller = [self.viewControllers objectAtIndex:i];
		if( curViewcontroller == viewController )
			break;
		
		if( [curViewcontroller conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
			[curViewcontroller performSelector:@selector(willBePoppedByNavigationController:)
									withObject:self];
	}
	return [super popToViewController:viewController
							 animated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	const NSUInteger count = self.viewControllers.count;
	for( NSInteger i = count - 1 ; i >= 0 ; --i )
	{
		UIViewController* viewController = [self.viewControllers objectAtIndex:i];
		if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
			[viewController performSelector:@selector(willBePoppedByNavigationController:)
								 withObject:self];
	}

	for( UIViewController* viewController in viewControllers )
	{
		if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
			[viewController performSelector:@selector(willBePushedByNavigationController:)
								 withObject:self];
	}
	
	[super setViewControllers:viewControllers
					 animated:animated];
}

- (void) viewWillUnload
{
	[super viewWillUnload];
	[self popToRootViewControllerAnimated:NO];
}

- (void)dealloc
{
	const NSUInteger count = self.viewControllers.count;
	for( NSInteger i = count - 1 ; i >= 0 ; --i )
	{
		UIViewController* viewController = [self.viewControllers objectAtIndex:i];
		if( [viewController conformsToProtocol:@protocol(SEPushPopViewControllerProtocol)] )
			[viewController performSelector:@selector(willBePoppedByNavigationController:)
								 withObject:self];
	}
	
	[super dealloc];
}

@end
