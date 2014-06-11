//
//  DMDataManager.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/15/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMDataManager.h"
#import "UnitEntry.h"
#import "DMUnit.h"
#import "DMEncounter.h"
#import "DMLibrary.h"
#import "DMSettings.h"
#import "DMToolsAppDelegate.h"
#import "MenuViewController.h"
#import "libraryViewController.h"
#import "InitiativeViewController.h"
#import "SessionsViewController.h"
#import "NotesViewController.h"
#import "NSMutableString+DMToolsExport.h"

#define kStatusIconsCount	22
#define kAvatarSize			128.0f
#define kIconSize			32.0f

#define kLegacyTemplateName		@"Basic"
#define kDnD4eTemplateName		@"DnD 4e"
#define kPathfinderTemplateName	@"Pathfinder"
#define kDefaultEncounterName	@"Encounter"
#define kCurrentEncounter		@"CurrentEncounter"	// deprecated at version 3.1

static NSMutableArray* sStatusIcons = nil;
static NSMutableDictionary* sLibraries = nil;
static NSArray* sSortedLibraryNames = nil;
static NSArray* sSortedSavedEncounterNames = nil;
static NSMutableDictionary* sSavedEncounterDates = nil;
static DMEncounter* sCurrentEncounter = nil;
static NSMutableDictionary* sAvatars = nil;

@interface DMDataLoader : NSObject<DMToolsXMLParserDelegate> {
	NSMutableDictionary*	_libraries;
	NSMutableDictionary*	_encounters;
	NSMutableDictionary*	_encounterDates;
	NSUInteger				_librariesCount;
	NSUInteger				_encountersCount;
	BOOL					_hasCurrentEncounter;
	BOOL					_importing;
	NSString*				_filepath;
	NSString*				_filename;
}

@property (nonatomic, retain) NSMutableDictionary *libraries;
@property (nonatomic, retain) NSMutableDictionary *encounters;
@property (nonatomic, retain) NSMutableDictionary *encounterDates;
@property (nonatomic, readonly) NSUInteger librariesCount;
@property (nonatomic, readonly) NSUInteger encountersCount;
@property (nonatomic, readonly) BOOL hasCurrentEncounter;
@property (nonatomic, assign, getter = isImporting) BOOL importing;
@property (nonatomic, copy) NSString* filepath;
@property (nonatomic, copy) NSString* filename;
@end

@implementation DMDataLoader
@synthesize libraries = _libraries, encounterDates = _encounterDates;
@synthesize librariesCount = _librariesCount, encounters = _encounters, encountersCount = _encountersCount;
@synthesize hasCurrentEncounter = _hasCurrentEncounter, importing = _importing;
@synthesize filepath = _filepath, filename = _filename;

- (void) parser:(DMToolsXMLParser *)parser parsedLibrary:(DMLibrary *)library
{
	if( library.baseTemplate )
	{
		[sSortedLibraryNames release];
		sSortedLibraryNames = nil;
		
		DMLibrary* oldLibrary = [_libraries objectForKey:library.name];
		if( [DMSettings autoMergeLibraries]
		   && oldLibrary )
		{
			__block NSArray* testArray = nil;
			BOOL (^testBlock)(id, NSUInteger, BOOL *) = ^(id obj, NSUInteger idx, BOOL *stop) {
				NSString* objName = [obj name];
				for( id testObj in testArray )
				{
					if( [[testObj name] isEqualToString:objName] )
						return NO;
				}
				return YES;
			};
			
			testArray = library.players;
			NSIndexSet* notFoundIndices = [oldLibrary.players indexesOfObjectsPassingTest:testBlock];
			if( notFoundIndices.count )
				[library.mutablePlayers addObjectsFromArray:[oldLibrary.players objectsAtIndexes:notFoundIndices]];

			testArray = library.monsters;
			notFoundIndices = [oldLibrary.monsters indexesOfObjectsPassingTest:testBlock];
			if( notFoundIndices.count )
				[library.mutableMonsters addObjectsFromArray:[oldLibrary.monsters objectsAtIndexes:notFoundIndices]];
		}

		BOOL isDefaultTemplate = ( NSNotFound != [[DMDataManager defaultLibraryNames] indexOfObject:library.name] );
		library.readonlyTemplate = isDefaultTemplate;
		[_libraries setObject:library
					   forKey:library.name];

		if( _importing )
			library.dirty = YES;
		else
			library.savename = _filename;
		++_librariesCount;
	}
}

- (void) parser:(DMToolsXMLParser *)parser parsedEncounter:(DMEncounter *)encounter
{
	if( [_filepath isEqualToString:[DMDataManager currentEncounterPath]] )
	{
		// replace current encounter
		[sCurrentEncounter release];
		sCurrentEncounter = [encounter retain];
	}
	else
	{
		[_encounters setObject:encounter
						forKey:encounter.name];
		// add encounter to list of encoutners
		NSFileManager* fileManager = [NSFileManager defaultManager];
		NSString* filepath = _filepath;
		if( _importing )
		{
			// move the file to saved encounters path
			NSString* filename = [encounter.name stringByReplacingOccurrencesOfString:@" "
																		   withString:@"_"];
			filename = [filename stringByAppendingPathExtension:@"xml"];
			filepath = [[DMDataManager savedEncountersPath] stringByAppendingPathComponent:filename];
			
			if( [fileManager fileExistsAtPath:filepath] )
				[fileManager removeItemAtPath:filepath
										error:nil];
			[fileManager moveItemAtPath:_filepath
								 toPath:filepath
								  error:nil];
		}
		NSDictionary* attribs = [fileManager attributesOfItemAtPath:filepath
															  error:nil];
		[_encounterDates setObject:[attribs fileModificationDate]
							forKey:encounter.name];
	}
	++_encountersCount;
}

- (void) updateViews
{
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
	if( _librariesCount )
	{
		[appDelegate.menuViewController reloadData];
		
		// the library might have been changed/swaped so we do a search by name
		// and replace it in the library view if we find a match
		for( NSString* libraryName in _libraries.allKeys )
		{
			if( [appDelegate.libraryViewController.library.name isEqualToString:libraryName] )
			{
				[appDelegate.libraryViewController setLibrary:[_libraries objectForKey:libraryName]];
				break;
			}
		}
	}
	if( _encountersCount )
	{
		if( _hasCurrentEncounter )
			[appDelegate.initiativeViewController reloadData];
		[appDelegate.sessionsViewController reloadData];
	}
}

- (void) dealloc
{
	[_libraries release];
	[_encounterDates release];
	[_filepath release];
	[_filename release];
	[super dealloc];
}

@end


@implementation DMDataManager

+ (void) fixLegacyPaths
{
	NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"kVersion"];
	if( [version compare:@"3.4"] == NSOrderedAscending )
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString* applicationSupportPath = [paths objectAtIndex:0];
		NSFileManager* fileManager = [NSFileManager defaultManager];
		// fix old paths
		NSString* oldEncounterPath = [applicationSupportPath stringByAppendingPathComponent:kDefaultEncounterName];
		oldEncounterPath = [oldEncounterPath stringByAppendingPathExtension:@"xml"];
		if( [fileManager fileExistsAtPath:oldEncounterPath] )
			[fileManager moveItemAtPath:oldEncounterPath
								 toPath:[self currentEncounterPath]
								  error:nil];
		
		NSString* oldPaths[4] = {
			[applicationSupportPath stringByAppendingPathComponent:@"libraries"],
			[applicationSupportPath stringByAppendingPathComponent:@"encounters"],
			[applicationSupportPath stringByAppendingPathComponent:@"icons"],
			[applicationSupportPath stringByAppendingPathComponent:@"avatars"]
		};
		NSString* newPaths[4] = {
			[self userLibrariesPath],
			[self savedEncountersPath],
			[self userIconsPath],
			[self userAvatarsPath]
		};
		
		for( NSUInteger p = 0 ; p < 4 ; ++p )
		{
			NSString* oldPath = oldPaths[p];
			if( [fileManager fileExistsAtPath:oldPath] )
			{
				NSString* newPath = newPaths[p];
				NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:oldPath];
				NSString *file;
				while( ( file = [enumerator nextObject] ) != nil )
				{
					NSString *filename = [file lastPathComponent];
					NSString* extension = filename.pathExtension;
					if( [extension caseInsensitiveCompare:@"xml"] == NSOrderedSame
					   || [extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame
					   || [extension caseInsensitiveCompare:@"png"] == NSOrderedSame )
					{
						NSString *oldFilepath = [oldPath stringByAppendingPathComponent:filename];
						NSString *newFilepath = [newPath stringByAppendingPathComponent:filename];
						[fileManager moveItemAtPath:oldFilepath
											 toPath:newFilepath
											  error:nil];
					}
				}
				
				[fileManager removeItemAtPath:oldPath
										error:nil];
			}
		}
	}
}

+ (void)initialize
{
    if (self == [DMDataManager class])
	{
        sStatusIcons = [NSMutableArray new];
		sLibraries = [NSMutableDictionary new];
		sSavedEncounterDates = [NSMutableDictionary new];
		sAvatars = [NSMutableDictionary new];
		// create default encounter
		sCurrentEncounter = [[DMEncounter alloc] initWithName:kDefaultEncounterName];
		
		NSFileManager* fileManager = [NSFileManager defaultManager];
		
		// create required paths user paths
		[fileManager createDirectoryAtPath:[self userLibrariesPath]
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
		[fileManager createDirectoryAtPath:[self savedEncountersPath]
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
		[fileManager createDirectoryAtPath:[self userIconsPath]
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
		[fileManager createDirectoryAtPath:[self userAvatarsPath]
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
		
		[self fixLegacyPaths];
	}
    NSAssert( sStatusIcons && sLibraries && sSavedEncounterDates, @"library not initialized" );
}

#pragma mark loading data functions

+ (void) parserLoadData:(DMToolsXMLParser*)parser
			inDirectory:(NSString*)path
			 withLoader:(DMDataLoader*)loader
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
	NSString *template;
	while( ( template = [enumerator nextObject] ) != nil )
	{
		if( [template.pathExtension caseInsensitiveCompare:@"xml"] == NSOrderedSame )
		{
			NSString *filename = [template lastPathComponent];
			NSString *filepath = [path stringByAppendingPathComponent:filename];
			NSData *data = [NSData dataWithContentsOfFile:filepath];
			if( data )
			{
				loader.filepath = filepath;
				loader.filename = filename;
				[parser setData:data];
				[parser parse];
			}
			if( loader.isImporting )
				[[NSFileManager defaultManager] removeItemAtPath:filepath
														   error:nil];
		}
	}
}

+ (DMParserResult) parserLoadData:(DMToolsXMLParser*)parser
						 fromFile:(NSString*)filepath
					   withLoader:(DMDataLoader*)loader
{
	DMParserResult result = DMParserFailed;
	NSString *filename = [filepath lastPathComponent];
	NSData *data = [NSData dataWithContentsOfFile:filepath];
	if( data )
	{
		loader.filepath = filepath;
		loader.filename = filename;
		[parser setData:data];
		result = [parser parse];
	}
	if( loader.isImporting )
		[[NSFileManager defaultManager] removeItemAtPath:filepath
												   error:nil];
	return result;
}

+ (void) convertOldData:(NSString*)version
{
	DMLibrary* library = [self legacyLibrary];
	NSData *encounterData = nil;
	NSData *playerData = nil;
	NSData *monsterData = nil;
	NSData *initiativeData = nil;
	BOOL hasFailedLoading = NO;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* savePath = [DMToolsAppDelegate documentsPath];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	@try
	{
		encounterData = [userDefaults dataForKey:@"EncounterRep"];
		if( encounterData )
		{
			NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:encounterData];
			for (Encounter *oldEncounter in oldSavedArray)
			{
				DMEncounter* encounter = [[DMEncounter alloc] initWithName:oldEncounter.name];
				for( UnitEntry *unitEntry in oldEncounter.units )
				{
					unitEntry.initiative = 0;
					
					DMUnit *unit = [[DMUnit alloc] initWithUnitEntry:unitEntry];
					[encounter.mutableUnits addObject:unit];
					[unit release];
				}
				
				// this is an old format of the library so we need to save the encounter in the saved sessions list
				NSString* encounterName = encounter.name ? encounter.name : @"Unnamed";
				NSString* newEncounterName = [NSString stringWithFormat:@"%@ (%@)", encounterName, library.name];
				[DMDataManager saveEncounter:encounter
									withName:newEncounterName];
				library.dirty = YES;
			}
		}
	}
	@catch (NSException * e)
	{
		hasFailedLoading = YES;
		if( encounterData )
		{
			NSString* path = [savePath stringByAppendingPathComponent:@"encounters.dump"];
			if( [fileManager fileExistsAtPath:path] )
			   [fileManager removeItemAtPath:path
									   error:nil];
			[fileManager createFileAtPath:path
								 contents:encounterData
							   attributes:nil];
		}
	}

	@try
	{
		playerData = [userDefaults dataForKey:@"PlayerRep"];
		if( playerData )
		{
			NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:playerData];
			for (UnitEntry *unitEntry in oldSavedArray)
			{
				unitEntry.initiative = 0;
				
				DMUnit *unit = [[DMUnit alloc] initWithUnitEntry:unitEntry];
				// make sure unit has the correct flag
				unit.player = YES;
				[library.mutablePlayers insertSorted:unit];
				[unit release];
			}
		}
	}
	@catch (NSException * e)
	{
		hasFailedLoading = YES;
		if( playerData )
		{
			NSString* path = [savePath stringByAppendingPathComponent:@"players.dump"];
			if( [fileManager fileExistsAtPath:path] )
				[fileManager removeItemAtPath:path
										error:nil];
			[fileManager createFileAtPath:path
								 contents:playerData
							   attributes:nil];
		}
	}
	
	@try
	{
		monsterData = [userDefaults dataForKey:@"MonsterRep"];
		if( monsterData )
		{
			NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:monsterData];
			for (UnitEntry *unitEntry in oldSavedArray)
			{
				unitEntry.initiative = 0;
				
				DMUnit *unit = [[DMUnit alloc] initWithUnitEntry:unitEntry];
				// make sure unit has the correct flag
				unit.player = NO;
				[library.mutableMonsters insertSorted:unit];
				[unit release];
			}
		}
	}
	@catch (NSException * e)
	{
		hasFailedLoading = YES;
		if( monsterData )
		{
			NSString* path = [savePath stringByAppendingPathComponent:@"monsters.dump"];
			if( [fileManager fileExistsAtPath:path] )
				[fileManager removeItemAtPath:path
										error:nil];
			[fileManager createFileAtPath:path
								 contents:monsterData
							   attributes:nil];
		}
	}
	
	@try
	{
		initiativeData = [userDefaults dataForKey:@"InitRep"];
		if( initiativeData )
		{
			NSArray *initArray = [NSKeyedUnarchiver unarchiveObjectWithData:initiativeData];
			const BOOL fixInitValue = [version compare:@"2.1"] == NSOrderedAscending;
			for (UnitEntry *unitEntry in initArray)
			{
				if (fixInitValue)
					unitEntry.initiative = rand() % 20 + 1;
				
				DMUnit *unit = [[DMUnit alloc] initWithUnitEntry:unitEntry];
				[sCurrentEncounter.mutableUnits addObject:unit];
				[unit release];
			}
		}
	}
	@catch (NSException * e)
	{
		hasFailedLoading = YES;
		if( initiativeData )
		{
			NSString* path = [savePath stringByAppendingPathComponent:@"initiative.dump"];
			if( [fileManager fileExistsAtPath:path] )
				[fileManager removeItemAtPath:path
										error:nil];
			[fileManager createFileAtPath:path
								 contents:initiativeData
							   attributes:nil];
		}
	}
	
	[userDefaults removeObjectForKey:@"EncounterRep"];
	[userDefaults removeObjectForKey:@"PlayerRep"];
	[userDefaults removeObjectForKey:@"MonsterRep"];
	[userDefaults removeObjectForKey:@"InitRep"];
	[userDefaults synchronize];
	if( hasFailedLoading )
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Data Error"
														message:@"Data from an old version have been found on your device but could not be loaded. We have exported the data to iTunes. Please sync with iTunes and submit the data to us and we'll do our best to recover your data."
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

+ (void) loadStatusIcons
{
	[sStatusIcons addObject:[UIImage imageNamed:@"checkbox_1.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_marked.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_dazed.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_stunned.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_slowed.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_deafened.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_blinded.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_weakened.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_immobilised.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_dominated.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_prone.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_poisoned.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_bloodied.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_rand.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_randblood.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_randcross.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_randhand.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_randhead.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_randskull.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_ongoing.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_acmod.png"]];
	[sStatusIcons addObject:[UIImage imageNamed:@"status_hitmod.png"]];
	NSAssert( sStatusIcons.count == kStatusIconsCount, @"status icons not initialized properly" );
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* userStatusIconNames = [userDefaults objectForKey:@"StatusIcons"];
	NSString* iconsPath = [self userIconsPath];
	for (NSString *iconFile in userStatusIconNames)
	{
		UIImage* image = [UIImage imageWithContentsOfFile:[iconsPath stringByAppendingPathComponent:iconFile]];
		[sStatusIcons addObject:image];
	}
}

+ (BOOL) loadData:(NSString*)version
{
	// load status icons
	[self loadStatusIcons];
	
	DMDataLoader *loader = [DMDataLoader new];
	DMToolsXMLParser *parser = [DMToolsXMLParser new];
	parser.delegate = loader;
	
	// load templates
	loader.libraries = sLibraries;
	loader.encounterDates = sSavedEncounterDates;
	
	[self parserLoadData:parser
			 inDirectory:[self librariesPath]
			  withLoader:loader];
	
	BOOL needsSave = NO;
	if( [version compare:@"3.0"] == NSOrderedAscending )
	{
		[self convertOldData:version];
		needsSave = YES;
	}
	else
	{
		// load library units
		[self parserLoadData:parser
				 inDirectory:[self userLibrariesPath]
				  withLoader:loader];
		
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if( [version compare:@"3.3"] == NSOrderedAscending )
		{
			NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
			// move current encounter file from legacy path to new path
			NSString* currentEncounterName = [userDefaults objectForKey:kCurrentEncounter];
			NSString* filename = [currentEncounterName stringByReplacingOccurrencesOfString:@" "
																				 withString:@"_"];
			filename = [filename stringByAppendingPathExtension:@"xml"];
			NSString *filepath = [[self savedEncountersPath] stringByAppendingPathComponent:filename];
			
			if( [fileManager fileExistsAtPath:filepath] )
				[fileManager moveItemAtPath:filepath
									 toPath:[self currentEncounterPath]
									  error:nil];
			
			[userDefaults removeObjectForKey:kCurrentEncounter];
			needsSave = YES;
		}
		
		// parse saved encounters
		[self parserLoadData:parser
				 inDirectory:[self savedEncountersPath]
				  withLoader:loader];
		
		// load current encounter
		// do this after the saved encounters so that if there's a name conflict
		// the current encounter will be selected
		[self parserLoadData:parser
					fromFile:[self currentEncounterPath]
				  withLoader:loader];
	}
	
	// load notes
	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
	if( [appDelegate.notesViewController loadData:version] )
		[appDelegate.notesViewController reloadData];
	
	[loader updateViews];

	[parser release];
	[loader release];
	
	return needsSave;
}

#pragma mark saving data functions

+ (void) saveLibrary:(DMLibrary*)library inDirectory:(NSString*)path
{
	NSAssert( library.name && library.name.length != 0, @"invalid library name" );
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString* filename = [library.name stringByReplacingOccurrencesOfString:@" "
																 withString:@"_"];
	filename = [filename stringByAppendingPathExtension:@"xml"];
	NSString *filepath = [path stringByAppendingPathComponent:filename];
	
	if( library.savename )
	{
		// is data is not dirty and savename exists then just skip save
		if( !library.isDirty )
		{
			NSAssert( [library.savename isEqualToString:filename], @"library name-filename mismatch. check if dirty flag has been set correctly" );
			return;
		}
		
		NSString *oldSavepath = [path stringByAppendingPathComponent:library.savename];
		[fileManager removeItemAtPath:oldSavepath
								error:nil];
	}
	
	[library saveToFile:filepath];
}

+ (void) saveEncounter:(DMEncounter*)encounter atPath:(NSString*)path
{
	NSAssert( encounter.name && encounter.name.length != 0, @"invalid encounter name" );
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if( [fileManager fileExistsAtPath:path] )
		[fileManager removeItemAtPath:path
								error:nil];
	
	[encounter saveToFile:path];
}

+ (void) saveLibrary:(DMLibrary*)library
{
	[self saveLibrary:library
		  inDirectory:[self userLibrariesPath]];
}

+ (void) saveCurrentEncounter
{
	if( sCurrentEncounter.isDirty )
		[self saveEncounter:sCurrentEncounter
					 atPath:[self currentEncounterPath]];
}

+ (void) saveData
{
	NSArray* libraries = sLibraries.allValues;
	NSAssert( sLibraries.allKeys.count == libraries.count, @"keys - values mismatch" );
	for( DMLibrary *library in libraries )
	{
		[self saveLibrary:library
			  inDirectory:[self userLibrariesPath]];
	}
	
	[self saveCurrentEncounter];

	DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelegate.notesViewController saveData];
}

#pragma mark import/export functions

+ (BOOL) importImage:(NSString*)imagePath
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *imageName = [imagePath lastPathComponent];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	NSString* newfilepath = nil;
	if( image )
	{
		CGSize size = image.size;
		if( size.width == kIconSize
		   && size.height == kIconSize )
		{
			newfilepath = [[self userIconsPath] stringByAppendingPathComponent:imageName];
			[fileManager moveItemAtPath:imagePath
								 toPath:newfilepath
								  error:nil];
			
			// reload image from new path coz iOS caches image with original path
			image = [UIImage imageWithContentsOfFile:newfilepath];
			
			// register new icon
			[sStatusIcons addObject:image];

			NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
			NSArray* userStatusIconNames = [userDefaults objectForKey:@"StatusIcons"];
			if( userStatusIconNames )
				userStatusIconNames = [userStatusIconNames arrayByAddingObject:imageName];
			else
				userStatusIconNames = [NSArray arrayWithObject:imageName];

			[userDefaults setObject:userStatusIconNames
							 forKey:@"StatusIcons"];
			[userDefaults synchronize];
		}
		else
		{
			newfilepath = [[self userAvatarsPath] stringByAppendingPathComponent:imageName];
			if( size.width != kAvatarSize
			   && size.height != kAvatarSize )
			{
				const CGFloat maxDimension = ( size.width > size.height ) ? size.width : size.height;
				const CGFloat ratio = kAvatarSize / maxDimension;
				size.width *= ratio;
				size.height *= ratio;
				const CGRect rect = CGRectMake( ( kAvatarSize - size.width ) * 0.5f,
											   ( kAvatarSize - size.height ) * 0.5f, 
											   size.width,
											   size.height );
				// render to our avatar size
				UIGraphicsBeginImageContextWithOptions( CGSizeMake( kAvatarSize, kAvatarSize ), NO, 0.0f );
				// now redraw our image in a smaller rectangle.
				[image drawInRect:rect];
				// make a "copy" of the image from the current context
				image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				NSData* imageData = UIImagePNGRepresentation( image );
				[fileManager createFileAtPath:newfilepath
									 contents:imageData
								   attributes:nil];
				[fileManager removeItemAtPath:imagePath
										error:nil];
			}
			else
			{
				[fileManager moveItemAtPath:imagePath
									 toPath:newfilepath
									  error:nil];
			}
		}
	}
	else
		[fileManager removeItemAtPath:imagePath
								error:nil];
		
	return ( image != nil );
}

+ (NSUInteger) importImages
{
	NSUInteger importCount = 0;
	NSString* importPath = [DMToolsAppDelegate documentsPath];
	NSString* userAvatarsPath = [self userAvatarsPath];
	NSString* userIconsPath = [self userIconsPath];
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* userStatusIconNames = [userDefaults objectForKey:@"StatusIcons"];
	BOOL saveStatusIcons = NO;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:importPath];
	NSString *imageName;
	while( ( imageName = [enumerator nextObject] ) != nil )
	{
		if( [imageName.pathExtension caseInsensitiveCompare:@"png"] == NSOrderedSame
		   || [imageName.pathExtension caseInsensitiveCompare:@"jpg"] == NSOrderedSame )
		{
			imageName = [imageName lastPathComponent];
			NSString *filepath = [importPath stringByAppendingPathComponent:imageName];
			UIImage *image = [UIImage imageWithContentsOfFile:filepath];
			NSString* newfilepath = nil;
			if( image )
			{
				CGSize size = image.size;
				if( size.width == kIconSize
				   && size.height == kIconSize )
				{
					newfilepath = [userIconsPath stringByAppendingPathComponent:imageName];
					[fileManager moveItemAtPath:filepath
										 toPath:newfilepath
										  error:nil];
					filepath = nil;
					
					// reload image from new path coz iOS caches image with original path
					image = [UIImage imageWithContentsOfFile:newfilepath];
					
					// register new icon
					[sStatusIcons addObject:image];
					if( userStatusIconNames )
						userStatusIconNames = [userStatusIconNames arrayByAddingObject:imageName];
					else
						userStatusIconNames = [NSArray arrayWithObject:imageName];
					saveStatusIcons = YES;
				}
				else
				{
					newfilepath = [userAvatarsPath stringByAppendingPathComponent:imageName];
					if( size.width != kAvatarSize
						&& size.height != kAvatarSize )
					{
						const CGFloat maxDimension = ( size.width > size.height ) ? size.width : size.height;
						const CGFloat ratio = kAvatarSize / maxDimension;
						size.width *= ratio;
						size.height *= ratio;
						const CGRect rect = CGRectMake( ( kAvatarSize - size.width ) * 0.5f,
													   ( kAvatarSize - size.height ) * 0.5f, 
													   size.width,
													   size.height );
						// render to our avatar size
						UIGraphicsBeginImageContextWithOptions( CGSizeMake( kAvatarSize, kAvatarSize ), NO, 0.0f );
						// now redraw our image in a smaller rectangle.
						[image drawInRect:rect];
						// make a "copy" of the image from the current context
						image = UIGraphicsGetImageFromCurrentImageContext();
						UIGraphicsEndImageContext();
					
						NSData* imageData = UIImagePNGRepresentation( image );
						[fileManager createFileAtPath:newfilepath
											 contents:imageData
										   attributes:nil];
					}
					else
					{
						[fileManager moveItemAtPath:filepath
											 toPath:newfilepath
											  error:nil];
						filepath = nil;
					}
				}
				++importCount;
			}
			if( filepath )
				[fileManager removeItemAtPath:filepath
										error:nil];
		}
	}

	if( saveStatusIcons )
	{
		[userDefaults setObject:userStatusIconNames
						 forKey:@"StatusIcons"];
		[userDefaults synchronize];
	}
	
	return importCount;
}

+ (DMParserResult) importXml:(NSString*)xmlPath
{
	DMDataLoader *loader = [DMDataLoader new];
	DMToolsXMLParser *parser = [DMToolsXMLParser new];
	parser.delegate = loader;
	
	// load templates
	loader.libraries = sLibraries;
	loader.encounterDates = sSavedEncounterDates;
	loader.importing = YES;
	
	DMParserResult result = [self parserLoadData:parser
										fromFile:xmlPath
									  withLoader:loader];

	[loader updateViews];
	
	[parser release];
	[loader release];
	
	return result;
}

+ (BOOL) importData
{
	__block const NSUInteger imgCount = [self importImages];
	
	DMDataLoader *loader = [DMDataLoader new];
	DMToolsXMLParser *parser = [DMToolsXMLParser new];
	parser.delegate = loader;
	
	// load templates
	loader.libraries = sLibraries;
	loader.encounterDates = sSavedEncounterDates;
	loader.importing = YES;
	
	[self parserLoadData:parser
			 inDirectory:[DMToolsAppDelegate documentsPath]
			  withLoader:loader];
	
	[loader updateViews];

	__block const NSUInteger libCount = loader.librariesCount;
	__block const NSUInteger encCount = loader.encountersCount;
	[parser release];
	[loader release];
	
	if( imgCount || libCount || encCount )
	{
		dispatch_async( dispatch_get_main_queue(), ^{
			
			NSString* msg = [NSString stringWithFormat:@"Successfully imported\n%d images, %d libraries,\nand %d encounters from iTunes",
							 imgCount, libCount, encCount];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Import"
															message:msg
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		} );
		
		return TRUE;
	}
	
	return FALSE;
}

+ (void) exportData
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString* documentsPath = [DMToolsAppDelegate documentsPath];
	NSArray* libraries = sLibraries.allValues;
	NSAssert( sLibraries.allKeys.count == libraries.count, @"keys - values mismatch" );
	for( DMLibrary* library in libraries )
	{
		NSString* savename = [library.name stringByReplacingOccurrencesOfString:@" "
																	 withString:@"_"];
		savename = [documentsPath stringByAppendingPathComponent:savename];
		savename = [savename stringByAppendingPathExtension:@"dml"];
		savename = [savename stringByAppendingPathExtension:@"xml"];
		
		NSMutableString *xmlText = [NSMutableString new];
		[xmlText appendDMToolsHeader];
		[xmlText appendLibrary:library
					   atLevel:0];
		[xmlText appendDMToolsFooter];
		
		NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
		[xmlText release];
		
		[fileManager createFileAtPath:savename
							 contents:data
						   attributes:nil];
	}
	
	// export current encounter
	{
		NSString* savename = [sCurrentEncounter.name stringByReplacingOccurrencesOfString:@" "
																			   withString:@"_"];
		savename = [documentsPath stringByAppendingPathComponent:savename];
		savename = [savename stringByAppendingPathExtension:@"dme"];
		savename = [savename stringByAppendingPathExtension:@"xml"];
		
		NSMutableString *xmlText = [NSMutableString new];
		[xmlText appendDMToolsHeader];
		[xmlText appendEncounter:sCurrentEncounter
						 atLevel:0];
		[xmlText appendDMToolsFooter];
		
		NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
		[xmlText release];
		
		[fileManager createFileAtPath:savename
							 contents:data
						   attributes:nil];
	}
	
	dispatch_async( dispatch_get_main_queue(), ^{
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Export"
														message:@"Successfully exported libraries to iTunes"
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} );
}

+ (void) clearCache
{
	[sSortedLibraryNames release];
	sSortedLibraryNames = nil;
	
	[sSortedSavedEncounterNames release];
	sSortedSavedEncounterNames = nil;

	for( DMUnit* unit in sCurrentEncounter.units )
	{
		[unit clearCache];
	}
	NSArray* libraries = sLibraries.allValues;
	NSAssert( sLibraries.allKeys.count == libraries.count, @"keys - values mismatch" );
	for( DMLibrary *library in libraries )
	{
		for( DMUnit* unit in library.players )
		{
			[unit clearCache];
		}
		for( DMUnit* unit in library.monsters )
		{
			[unit clearCache];
		}
		[library.baseTemplate clearCache];
	}
	
	[sAvatars removeAllObjects];
}

// template functions
+ (NSDictionary *) libraries
{
	return sLibraries;
}

+ (NSArray*) sortedLibraryNames
{
	if( !sSortedLibraryNames )
	{
		sSortedLibraryNames = [[sLibraries keysSortedByValueUsingComparator:^(id obj1, id obj2) {
			return [obj1 compare:obj2];
		}] retain];
	}
	return sSortedLibraryNames;
}

+ (void) addLibrary:(DMLibrary *)library
{
	[sSortedLibraryNames release];
	sSortedLibraryNames = nil;
	[sLibraries setObject:library
				   forKey:library.name];
}

+ (void) removeLibrary:(DMLibrary *)library
{
	[sSortedLibraryNames release];
	sSortedLibraryNames = nil;
	if( library.savename )
	{
		NSString *savepath = [[self userLibrariesPath] stringByAppendingPathComponent:library.savename];
		[[NSFileManager defaultManager] removeItemAtPath:savepath
												   error:nil];
	}
	[sLibraries removeObjectForKey:library.name];
}

+ (BOOL) canCreateLibraryWithName:(NSString *)name
{
	return ( [sLibraries objectForKey:name] == nil );
}

+ (BOOL) canRenameLibrary:(DMLibrary*)library withNewName:(NSString *)name
{
	DMLibrary* oldLibrary = [sLibraries objectForKey:name];
	return ( oldLibrary == nil || oldLibrary == library );
}

+ (BOOL) renameLibrary:(DMLibrary*)library withNewName:(NSString *)name
{
	if( [sLibraries objectForKey:name] )
		return NO;
	
	[sSortedLibraryNames release];
	sSortedLibraryNames = nil;
	[library retain];
	[sLibraries removeObjectForKey:library.name];
	library.baseTemplate.name = name;
	[sLibraries setObject:library
				   forKey:library.name];
	[library release];
	return YES;
}

+ (NSDictionary*) savedEncounterDates
{
	return sSavedEncounterDates;
}

+ (NSArray*) sortedSavedEncounterNames
{
	if( !sSortedSavedEncounterNames )
	{
		sSortedSavedEncounterNames = [[sSavedEncounterDates keysSortedByValueUsingComparator:^(id obj1, id obj2) {
			switch( [obj1 compare:obj2] )
			{
				case NSOrderedAscending:
					return NSOrderedDescending;
				case NSOrderedDescending:
					return NSOrderedAscending;
				default:
					return NSOrderedSame;
			};
		}] retain];
	}
	return sSortedSavedEncounterNames;
}

+ (BOOL) canSaveEncounterWithName:(NSString *)name
{
	return ( [sSavedEncounterDates objectForKey:name] == nil );
}

+ (void) saveEncounter:(DMEncounter *)encounter withName:(NSString*)name
{
	NSString* savename = [name stringByReplacingOccurrencesOfString:@" "
														 withString:@"_"];
	savename = [savename stringByAppendingPathExtension:@"xml"];
	savename = [[self savedEncountersPath] stringByAppendingPathComponent:savename];
	
	// store temporarily the original name since we want to save the encounter with the new name
	NSString* origName = [encounter.name retain];
	encounter.name = name;
	
	[self saveEncounter:encounter
				 atPath:savename];
	
	[sSortedSavedEncounterNames release];
	sSortedSavedEncounterNames = nil;
	
	NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:savename
																			 error:nil];
	[sSavedEncounterDates setObject:[attribs fileModificationDate]
							 forKey:name];
	
	// restore original name
	encounter.name = origName;
	[origName release];
}

+ (void) deleteSavedEncounter:(NSString *)name
{
	NSString* savename = [name stringByReplacingOccurrencesOfString:@" "
														 withString:@"_"];
	savename = [savename stringByAppendingPathExtension:@"xml"];
	savename = [[self savedEncountersPath] stringByAppendingPathComponent:savename];
	[[NSFileManager defaultManager] removeItemAtPath:savename
											   error:nil];
	
	[sSavedEncounterDates removeObjectForKey:name];
	[sSortedSavedEncounterNames release];
	sSortedSavedEncounterNames = nil;
}

+ (DMEncounter*) loadSavedEncounter:(NSString *)name
{
	NSString* savename = [name stringByReplacingOccurrencesOfString:@" "
														 withString:@"_"];
	savename = [savename stringByAppendingPathExtension:@"xml"];
	savename = [[self savedEncountersPath] stringByAppendingPathComponent:savename];

	DMDataLoader *loader = [DMDataLoader new];
	DMToolsXMLParser *parser = [DMToolsXMLParser new];
	parser.delegate = loader;
	
	// load templates
	loader.libraries = sLibraries;
	loader.encounters = [[NSMutableDictionary new] autorelease];
	
	// load current encounter
	[self parserLoadData:parser
				fromFile:savename
			  withLoader:loader];

	DMEncounter* encounter = [loader.encounters objectForKey:name];
	
	// we don't update views from loader here on purpose
	
	[parser release];
	[loader release];
	
	return encounter;
}

+ (NSArray*) defaultLibraryNames
{
	return [NSArray arrayWithObjects:
			kLegacyTemplateName,
			kDnD4eTemplateName,
			kPathfinderTemplateName,
			nil];
}
								  
+ (DMLibrary*) legacyLibrary
{
	return [sLibraries objectForKey:kLegacyTemplateName];
}

+ (DMEncounter*) currentEncounter
{
	return sCurrentEncounter;
}

+ (void) setCurrentEncounter:(DMEncounter*)encounter
{
	if( sCurrentEncounter != encounter )
	{
		[sCurrentEncounter release];
		sCurrentEncounter = [encounter retain];
	}
}

// icon functions
+ (NSArray*) statusIcons
{
	return sStatusIcons;
}

+ (UIImage*) avatarNamed:(NSString*)avatarName
{
	UIImage* avatar = [sAvatars objectForKey:avatarName];
	if( avatar )
		return avatar;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	// load the original image
	NSString* searchPaths[2] = {
		[self userAvatarsPath],
		[self avatarsPath]
	};
	for( int p = 0 ; p < 2 ; ++p )
	{
		NSString* imagesPath = searchPaths[p];
		NSString* imagePath = [imagesPath stringByAppendingPathComponent:avatarName];
		if( [fileManager fileExistsAtPath:imagePath] )
		{
			avatar = [UIImage imageWithContentsOfFile:imagePath];
			[sAvatars setObject:avatar
						 forKey:avatarName];
			return avatar;
		}
	}
	
	return nil;
}

+ (NSString*) librariesPath
{
	return [[DMToolsAppDelegate resourcePath] stringByAppendingPathComponent:@"libraries"];
}

+ (NSString*) iconsPath
{
	return [[DMToolsAppDelegate resourcePath] stringByAppendingPathComponent:@"icons"];
}

+ (NSString*) avatarsPath
{
	return [[DMToolsAppDelegate resourcePath] stringByAppendingPathComponent:@"avatars"];
}

+ (NSString*) userLibrariesPath
{
	return [[DMToolsAppDelegate applicationSupportPath] stringByAppendingPathComponent:@"libraries"];
}

+ (NSString*) currentEncounterPath
{
	NSString* path = [[DMToolsAppDelegate applicationSupportPath] stringByAppendingPathComponent:kDefaultEncounterName];
	return [path stringByAppendingPathExtension:@"xml"];
}

+ (NSString*) savedEncountersPath
{
	return [[DMToolsAppDelegate applicationSupportPath] stringByAppendingPathComponent:@"encounters"];
}

+ (NSString*) userIconsPath
{
	return [[DMToolsAppDelegate applicationSupportPath] stringByAppendingPathComponent:@"icons"];
}

+ (NSString*) userAvatarsPath
{
	return [[DMToolsAppDelegate applicationSupportPath] stringByAppendingPathComponent:@"avatars"];
}

+ (NSString*) temporaryPath
{
	return [DMToolsAppDelegate temporaryPath];
}

@end
