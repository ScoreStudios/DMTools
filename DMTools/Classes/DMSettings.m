//
//  DMSettings.m
//  DM Tools
//
//  Created by hamouras on 4/6/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMSettings.h"
#import "DMSettingsViewController.h"

DMSettings *sSettings = nil;

@interface DMSettings()
- (void) load:(NSString *)version;
@end

@implementation DMSettings

+ (DMSettings *) settings
{
	if (!sSettings)
	{
		[[DMSettings new] autorelease];
	}
	return sSettings;
}

+ (BOOL) portraitLock
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
												inSection:0];
	return [[[DMSettings settings] settingAtIndexPath:indexPath] booleanValue];
}

+ (BOOL) uniqueNames
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
												inSection:0];
	return [[[DMSettings settings] settingAtIndexPath:indexPath] booleanValue];
}

+ (BOOL) autoRoll:(BOOL)player
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(player ? 2 : 3)
												inSection:0];
	return [[[DMSettings settings] settingAtIndexPath:indexPath] booleanValue];
}

+ (BOOL) collapseGroups
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4
												inSection:0];
	return [[[DMSettings settings] settingAtIndexPath:indexPath] booleanValue];
}

+ (BOOL) autoMergeLibraries
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
												inSection:1];
	return [[[DMSettings settings] settingAtIndexPath:indexPath] booleanValue];
}

- (id) init
{
	self = [super init];
	if (self)
	{
		sSettings = self;

		[self load:[[NSUserDefaults standardUserDefaults] stringForKey:@"kVersion"]];
	}
	
	return self;
}

- (void) dealloc
{
	sSettings = nil;
	[super dealloc];
}

- (void) load:(NSString *)version
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL modified = NO;
	
	BOOL portraitLock = NO;
	BOOL uniqueNames = YES;
	BOOL autoRollPlayers = YES;
	BOOL autoRollMonsters = YES;
	BOOL collapseGroups = NO;
	BOOL autoMergeLibraries = NO;
	
	if (version == nil)
		version = @"2.0";	// if there's no version key assume its an old version

	@try
	{
		portraitLock = [userDefaults boolForKey:@"kPortraitLock"];
		uniqueNames = [userDefaults boolForKey:@"kUniqueNames"];
		if ([version compare:@"2.4"] == NSOrderedAscending)
		{
			autoRollPlayers = ![userDefaults boolForKey:@"kNoAutoRoll"];
			[userDefaults removeObjectForKey:@"kNoAutoRoll"];
			modified = YES;
		}
		else
		{
			autoRollPlayers = [userDefaults boolForKey:@"kAutoRollPlayers"];
			autoRollMonsters = [userDefaults boolForKey:@"kAutoRollMonsters"];
		}
		collapseGroups = [userDefaults boolForKey:@"kCollapseGroups"];
		autoMergeLibraries = [userDefaults boolForKey:@"kAutoMergeLibraries"];
	}
	@catch (NSException * e)
	{
		[userDefaults removeObjectForKey:@"kPortraitLock"];
		[userDefaults removeObjectForKey:@"kUniqueNames"];
		[userDefaults removeObjectForKey:@"kAutoRollPlayers"];
		[userDefaults removeObjectForKey:@"kAutoRollMonsters"];
		[userDefaults removeObjectForKey:@"kCollapseGroups"];
		[userDefaults removeObjectForKey:@"kAutoMergeLibraries"];
		[userDefaults removeObjectForKey:@"kImportURL"];
		modified = YES;
	}
	
	NSUInteger groupIndex = [self addGroup:@"Options"];
	[self addSetting:[SESetting booleanSetting:@"Portrait Lock"
									 withValue:portraitLock]
		 atGroupIndex:groupIndex];
	[self addSetting:[SESetting booleanSetting:@"Unique Names"
									 withValue:uniqueNames]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting booleanSetting:@"Auto-roll Players"
									 withValue:autoRollPlayers]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting booleanSetting:@"Auto-roll Monsters"
									 withValue:autoRollMonsters]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting booleanSetting:@"Collapse Groups"
									 withValue:collapseGroups]
		atGroupIndex:groupIndex];

	groupIndex = [self addGroup:@"Import/Export"];
	[self addSetting:[SESetting booleanSetting:@"Auto Merge Libraries"
									 withValue:autoMergeLibraries]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Import from iTunes"
							  withDetailLabel:nil
								   withAction:@selector(importFromITunes:)]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Export to iTunes"
							  withDetailLabel:nil
								   withAction:@selector(exportToITunes:)]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Export to Mail"
							  withDetailLabel:nil
								   withAction:@selector(exportToMail:)]
		atGroupIndex:groupIndex];
	
	groupIndex = [self addGroup:@"About"];
	[self addSetting:[SESetting actionSetting:@"Rate DMTools"
							  withDetailLabel:nil
								   withAction:@selector(rateDMTools:)]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Suggestions /  Feedback"
							  withDetailLabel:nil
								   withAction:@selector(mailToScore:)]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Score Studios"
							  withDetailLabel:nil
								   withAction:@selector(linkToScore:)]
		atGroupIndex:groupIndex];
	[self addSetting:[SESetting actionSetting:@"Forums"
							  withDetailLabel:nil
								   withAction:@selector(linkToForums:)]
		atGroupIndex:groupIndex];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
	[self addSetting:[SESetting actionSetting:@"DMTools version"
							  withDetailLabel:appVersion
								   withAction:nil]
		atGroupIndex:groupIndex];
	
	if (modified)
		[self save:NO];
}

- (void) save:(BOOL)synchronize
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setBool:[DMSettings portraitLock]
				   forKey:@"kPortraitLock"];
	[userDefaults setBool:[DMSettings uniqueNames]
				   forKey:@"kUniqueNames"];
	[userDefaults setBool:[DMSettings autoRoll:YES]
				   forKey:@"kAutoRollPlayers"];
	[userDefaults setBool:[DMSettings autoRoll:NO]
				   forKey:@"kAutoRollMonsters"];
	[userDefaults setBool:[DMSettings collapseGroups]
				   forKey:@"kCollapseGroups"];
	[userDefaults setBool:[DMSettings autoMergeLibraries]
				   forKey:@"kAutoMergeLibraries"];
	
	if (synchronize)
		[userDefaults synchronize];
}

@end
