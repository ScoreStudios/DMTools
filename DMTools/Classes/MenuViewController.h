//
//  MenuViewController.h
//  DM Tools
//
//  Created by hamouras on 12/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEWebViewController.h"
#import "DMUnitViewController.h"

@class LibraryViewController;
@class SessionsViewController;
@class NotesViewController;
@class DMSettingsViewController;
@class DMLibrary;

@interface MenuViewController : UITableViewController<UINavigationControllerDelegate, UIActionSheetDelegate, SEWebViewControllerDelegate, DMUnitViewControllerDelegate>
{
	LibraryViewController*		_libraryViewController;
	SessionsViewController*		_sessionsViewController;
	NotesViewController*		_notesViewController;
	SEWebViewController*		_manualViewController;
	DMSettingsViewController*	_settingsViewController;
	DMLibrary*					_currentLibrary;
}

@property (nonatomic, retain) IBOutlet LibraryViewController * libraryViewController;
@property (nonatomic, retain) IBOutlet SessionsViewController * sessionsViewController;
@property (nonatomic, retain) IBOutlet NotesViewController * notesViewController;
@property (nonatomic, retain) IBOutlet SEWebViewController * manualViewController;
@property (nonatomic, retain) IBOutlet DMSettingsViewController * settingsViewController;

- (void)reloadData;

@end
