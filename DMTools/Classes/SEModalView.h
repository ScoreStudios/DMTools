//
//  SEModalView.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 3/26/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEModalView : UIView
{
	UIWindow*	_modalWindow;
}

- (void) show;
- (void) hide;

@end
