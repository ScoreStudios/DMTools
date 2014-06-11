//
//  SECollatedViewController.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 5/4/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SECollatedObject;

@interface SECollatedViewController : UITableViewController
{
	NSMutableArray*		_sections;
	SEL					_collationSelector;
}

@property (nonatomic, assign) SEL collationSelector;

- (void)updateSectionsFromObjects:(NSArray*)objects withSelectedObject:(id)selectedObject scrollAnimated:(BOOL)scrollAnimated;

- (NSIndexPath*)indexPathForObject:(SECollatedObject*)object;

@end
