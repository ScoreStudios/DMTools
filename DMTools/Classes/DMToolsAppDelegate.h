//
//  DMToolsAppDelegate.h
//  DM Tools
//
//  Created by Paul Caristino on 6/3/10.
//  Copyright Score Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuViewController;
@class LibraryViewController;
@class SessionsViewController;
@class NotesViewController;
@class InitiativeViewController;
@class DMSettingsViewController;
@class SEWebViewController;

@interface DMToolsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate>
{
    UIWindow*					_window;
	UIViewController*			_rootViewController;
	UISplitViewController*		_splitViewController;
	UITabBarController*			_tabBarController;
	
	MenuViewController*			_menuViewController;
	LibraryViewController*		_libraryViewController;
	SessionsViewController*		_sessionsViewController;
	NotesViewController*		_notesViewController;
	InitiativeViewController*	_initiativeViewController;
	DMSettingsViewController*	_settingsViewController;
	SEWebViewController*		_manualViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet MenuViewController* menuViewController;
@property (nonatomic, retain) IBOutlet LibraryViewController* libraryViewController;
@property (nonatomic, retain) IBOutlet SessionsViewController* sessionsViewController;
@property (nonatomic, retain) IBOutlet NotesViewController* notesViewController;
@property (nonatomic, retain) IBOutlet InitiativeViewController* initiativeViewController;
@property (nonatomic, retain) IBOutlet DMSettingsViewController* settingsViewController;
@property (nonatomic, retain) IBOutlet SEWebViewController* manualViewController;

+ (NSString*) resourcePath;
+ (NSString*) documentsPath;
+ (NSString*) applicationSupportPath;
+ (NSString*) cachePath;
+ (NSString*) temporaryPath;

@end
