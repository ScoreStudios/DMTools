//
//  DMSettings.h
//  DM Tools
//
//  Created by hamouras on 4/6/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESettings.h"

#define kLinkDropbox		@"Link Dropbox"
#define kUnlinkDropbox		@"Unlink Dropbox"
#define kImportFromDropbox	@"Import from Dropbox"
#define kExportToDropbox	@"Export to Dropbox"

@interface DMSettings : SESettings
{
	NSUInteger	_dbGroupIndex;
}

+ (DMSettings *) settings;

+ (BOOL) portraitLock;
+ (BOOL) uniqueNames;
+ (BOOL) autoRoll:(BOOL)player;
+ (BOOL) collapseGroups;
+ (BOOL) autoMergeLibraries;

- (void) save:(BOOL)synchronize;

- (NSUInteger) dropboxGroupIndex;

@end
