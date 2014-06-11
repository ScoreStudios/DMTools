//
//  DMToolsAppDelegate.m
//  DM Tools
//
//  Created by Paul Caristino on 6/3/10.
//  Copyright Score Studios 2010. All rights reserved.
//

//#define VERSION_UPGRADE_TEST

#import "DMToolsAppDelegate.h"
#import "InitiativeViewController.h"
#import "MenuViewController.h"
#import "NotesViewController.h"
#import "NoteEntry.h"
#import "SETableData.h"
#import "DMDataManager.h"
#import "DMSettings.h"
#import "DMSettingsViewController.h"
#import "LibraryViewController.h"

@interface UITabBarController(OverrideAutorotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation UITabBarController(OverrideAutorotation)
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return [DMSettings portraitLock] ? (interfaceOrientation == UIInterfaceOrientationPortrait) : YES;
 }

@end

@interface UISplitViewController(OverrideAutorotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation UISplitViewController(OverrideAutorotation)
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return [DMSettings portraitLock] ? (interfaceOrientation == UIInterfaceOrientationPortrait) : YES;	
}

@end


@implementation DMToolsAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;
@synthesize splitViewController = _splitViewController;
@synthesize tabBarController = _tabBarController;
@synthesize menuViewController = _menuViewController;
@synthesize libraryViewController = _libraryViewController;
@synthesize sessionsViewController = _sessionsViewController;
@synthesize notesViewController = _notesViewController;
@synthesize initiativeViewController = _initiativeViewController;
@synthesize settingsViewController = _settingsViewController;
@synthesize manualViewController = _manualViewController;

+ (NSString*) resourcePath
{
	NSBundle* bundle = [NSBundle mainBundle];
	return [bundle resourcePath];
}

+ (NSString*) documentsPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString*) applicationSupportPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:identifier];
}

+ (NSString*) cachePath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:identifier];
}

+ (NSString*) temporaryPath
{
	NSString* tempPath = NSTemporaryDirectory();
	NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
	return [tempPath stringByAppendingPathComponent:identifier];
}

void interruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	(void)inClientData;
	
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		// disable audio session
		AudioSessionSetActive(false);
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
		// enable audio session
		AudioSessionSetActive(true);
	}
}

- (void) saveData
{
	static volatile BOOL saving = NO;
	if (saving)
		return;
	saving = YES;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#ifndef VERSION_UPGRADE_TEST
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
	[userDefaults setObject:version
					 forKey:@"kVersion"];
#endif
#ifdef _DEBUG
	[userDefaults setBool:YES
				   forKey:@"ShowDebugInfo"];
#endif
	
	[[DMSettings settings] save:NO];
	[DMDataManager saveData];
	
	[userDefaults synchronize];
	saving = NO;
}

- (void) loadData
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	@try
	{
		// get data version
		NSString *version = [userDefaults objectForKey:@"kVersion"];
		if (version == nil)
			version = @"2.0";	// if there's no version key assume its an old version
		
		if( [DMDataManager loadData:version] )
			// data was modified and need saving
			[self saveData];
	}
	@catch (NSException * e)
	{
		[userDefaults removeObjectForKey:@"kVersion"];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	srand((unsigned int) [NSDate timeIntervalSinceReferenceDate]);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString* documentsPath = [DMToolsAppDelegate documentsPath];
	NSString* applicationSupportPath = [DMToolsAppDelegate applicationSupportPath];
	NSString* cachePath = [DMToolsAppDelegate cachePath];
	NSString* temporaryPath = [DMToolsAppDelegate temporaryPath];

	NSLog( @"Documents Path: %@", documentsPath );
	NSLog( @"Application Support Path: %@", applicationSupportPath );
	NSLog( @"Cache Path: %@", cachePath );
	NSLog( @"Temporary Path: %@", temporaryPath );
	
	[fileManager createDirectoryAtPath:documentsPath
		   withIntermediateDirectories:YES
							attributes:nil
								 error:NULL];

	[fileManager createDirectoryAtPath:applicationSupportPath
		   withIntermediateDirectories:YES
							attributes:nil
								 error:NULL];
	
	[fileManager createDirectoryAtPath:cachePath
		   withIntermediateDirectories:YES
							attributes:nil
								 error:NULL];
	
	[fileManager createDirectoryAtPath:temporaryPath
		   withIntermediateDirectories:YES
							attributes:nil
								 error:NULL];
	
	// create & enable audio session
	AudioSessionInitialize(NULL, kCFRunLoopDefaultMode, interruptionListener, self);
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(UInt32), &sessionCategory);
	AudioSessionSetActive(true);

 	DBSession* session = [[DBSession alloc] initWithAppKey:@"v6vdl8dt5b7126h"
												 appSecret:@"5vzbbrrx9ix6agi"
													  root:kDBRootAppFolder];
	session.delegate = self;
	[DBSession setSharedSession:session];
	[session release];
	
	// to disable the gresture we need to manually set the rootViewController of the window
	// after we set presentsWithGesture to NO, otherwise it doesn't work
	// also do this before we start loading data so that views area available during that time
	if( [_splitViewController respondsToSelector:@selector(presentsWithGesture)] )
		_splitViewController.presentsWithGesture = NO;
	_window.rootViewController = _rootViewController;
	
	[self loadData];
	
	// Add the root controller's current view as a subview of the window
	[_window makeKeyAndVisible];
	
	[self.menuViewController reloadData];
	[self.initiativeViewController reloadData];
	[self.notesViewController reloadData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self applicationDidFinishLaunching:application];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	if( [[DBSession sharedSession] handleOpenURL:url] )
	{
		[self.settingsViewController updateDropboxButtons];
		return YES;
	}
	
	return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// enable audio session
	AudioSessionSetActive(true);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// disable audio session
	AudioSessionSetActive(false);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self.notesViewController reloadData];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[DMDataManager clearCache];
	UIApplication *app = [UIApplication sharedApplication];
	UIBackgroundTaskIdentifier identifier = [app beginBackgroundTaskWithExpirationHandler:nil];
	if (identifier == UIBackgroundTaskInvalid)
	{
		[self saveData];
		NSLog( @"background task finished" );
	}
	else
	{
		dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(aQueue, ^{
			[self saveData];
			NSLog( @"background task finished" );
			[app endBackgroundTask:identifier];
		});		
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveData];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[DMDataManager clearCache];
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
	_relinkUserId = [userId retain];
	[[[[UIAlertView alloc] initWithTitle:@"Dropbox Session Ended"
								 message:@"Do you want to relink?"
								delegate:self
					   cancelButtonTitle:@"Cancel"
					   otherButtonTitles:@"Relink", nil]
	  autorelease]
	 show];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	[controller dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
	if (index != alertView.cancelButtonIndex)
		[[DBSession sharedSession] linkUserId:_relinkUserId];
	
	[_relinkUserId release];
	_relinkUserId = nil;
}

#pragma mark UITabBarControllerDelegate
/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)dealloc
{
	[_menuViewController release];
	[_libraryViewController release];
	[_sessionsViewController release];
	[_notesViewController release];
	[_initiativeViewController release];
	[_settingsViewController release];
	[_manualViewController release];
	[_splitViewController release];
	[_tabBarController release];
	[_rootViewController release];
	[_window release];
	[_relinkUserId release];
    [super dealloc];
}


@end

