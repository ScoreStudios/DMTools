//
//  SessionsViewController.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/13/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InitiativeViewController;
@class DMEncounter;

@interface SessionsViewController : UITableViewController<UIAlertViewDelegate>
{
    InitiativeViewController *	_initiativeViewController;
	NSString*					_currentEncounterName;
}

@property (nonatomic, retain) IBOutlet InitiativeViewController *initiativeViewController;

- (void)reloadData;

@end
