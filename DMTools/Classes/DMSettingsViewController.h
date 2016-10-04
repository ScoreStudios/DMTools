//
//  DMSettingsViewController.h
//  DM Tools
//
//  Created by hamouras on 4/3/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SESettingsViewController.h"

@interface DMSettingsViewController : SESettingsViewController<UIAlertViewDelegate> {
	NSURL*			_iTunesURL;
    NSDictionary*	_xmlPaths;	// paths, revisions
    NSArray*		_iconPaths;
    NSString*		_syncHash;
	NSUInteger		_pendingCount;
	enum
	{
		StatusIdle	= 0,
		StatusImporting,
		StatusExporting
	} _status;
}

- (void) exportToMail:(NSIndexPath*)indexPath;
- (void) importFromITunes:(NSIndexPath*)indexPath;
- (void) exportToITunes:(NSIndexPath*)indexPath;
- (void) rateDMTools:(NSIndexPath*)indexPath;
- (void) linkToScore:(NSIndexPath*)indexPath;
- (void) linkToForums:(NSIndexPath*)indexPath;
- (void) mailToScore:(NSIndexPath*)indexPath;

@end
