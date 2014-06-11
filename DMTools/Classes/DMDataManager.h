//
//  DMDataLoader.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/15/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMToolsXMLParser.h"

@class DMUnit;
@class DMEncounter;
@class DMLibrary;

@interface DMDataManager : NSObject

// template functions
+ (NSDictionary*) libraries;
+ (NSArray*) defaultLibraryNames;
+ (NSArray*) sortedLibraryNames;
+ (void) addLibrary:(DMLibrary*)library;
+ (void) removeLibrary:(DMLibrary*)library;
+ (BOOL) canCreateLibraryWithName:(NSString *)name;
+ (BOOL) canRenameLibrary:(DMLibrary*)library withNewName:(NSString *)name;
+ (BOOL) renameLibrary:(DMLibrary*)library withNewName:(NSString *)name;

// saved encounters
+ (NSDictionary*) savedEncounterDates;
+ (NSArray*) sortedSavedEncounterNames;
+ (BOOL) canSaveEncounterWithName:(NSString *)name;
+ (void) saveEncounter:(DMEncounter *)encounter withName:(NSString*)name;
+ (void) deleteSavedEncounter:(NSString *)name;
+ (DMEncounter*) loadSavedEncounter:(NSString *)name;

+ (NSArray*) defaultLibraryNames;
+ (DMLibrary*) legacyLibrary;
+ (DMEncounter*) currentEncounter;
+ (void) setCurrentEncounter:(DMEncounter*)encounter;

// icon functions
+ (NSArray*) statusIcons;
+ (UIImage*) avatarNamed:(NSString*)avatarName;

+ (BOOL) loadData:(NSString*)version;	// return YES when data was modified during load
+ (void) saveData;
+ (void) clearCache;

+ (void) saveLibrary:(DMLibrary*)library;
+ (void) saveCurrentEncounter;

+ (BOOL) importImage:(NSString*)imagePath;
+ (DMParserResult) importXml:(NSString*)xmlPath;
+ (NSUInteger) importImages;
+ (BOOL) importData;
+ (void) exportData;

+ (NSString*) librariesPath;
+ (NSString*) iconsPath;
+ (NSString*) avatarsPath;
+ (NSString*) userLibrariesPath;
+ (NSString*) currentEncounterPath;
+ (NSString*) savedEncountersPath;
+ (NSString*) userIconsPath;
+ (NSString*) userAvatarsPath;
+ (NSString*) temporaryPath;

@end
