//
//  DMToolsXMLParser.m
//  DM Tools
//
//  Created by hamouras on 09/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "DMToolsXMLParser.h"
#import "DMToolsAppDelegate.h"
#import "DMDataManager.h"
#import "DMLibrary.h"
#import "DMEncounter.h"
#import "DMUnit.h"
#import "DMGroup.h"
#import "DMNumber.h"
#import "DMHitPoints.h"
#import "UnitEntry.h"
#import "NoteEntry.h"
#import "NotesViewController.h"

@interface DMToolsXMLParser() {
	NSXMLParser *	_parser;
	DMLibrary *		_library;
	DMEncounter *	_encounter;
	DMUnit *		_unit;
	DMGroup *		_group;
	DMNote *		_note;
	BOOL			_rootNode;
	BOOL			_notesNode;
	BOOL			_converted;
	BOOL			_aborted;

	BOOL			_oldDataFormat;
	struct
	{
		NSString *		group;
		NoteEntry *		note;
	} _oldData;
}
@end

@implementation DMToolsXMLParser
@synthesize delegate = _delegate;

- (id) initWithURL:(NSURL *)URL
{
	if( ( self = [super init] ) != nil )
	{
		NSURL *resolvedURL;
		if ([[URL scheme] compare:@"dmtools" 
						  options:NSCaseInsensitiveSearch] == NSOrderedSame)
		{
			// change resource specifier
			NSString *path = [NSString stringWithFormat:@"http:%@", [URL resourceSpecifier]];
			resolvedURL = [NSURL URLWithString:path];
		}
		else
			resolvedURL = URL;
		_parser = [[NSXMLParser alloc] initWithContentsOfURL:resolvedURL];
		_parser.delegate = self;
		_parser.shouldProcessNamespaces = NO;
		_parser.shouldReportNamespacePrefixes = NO;
		_parser.shouldResolveExternalEntities = NO;
	}
	
	return self;
}

- (id) initWithData:(NSData *)data
{
	if( ( self = [super init] ) != nil )
	{
		[self setData:data];
	}
	
	return self;
}

- (void) dealloc
{
	[_oldData.group release];
	[_oldData.note release];
	[_note release];
	[_group release];
	[_unit release];
	[_encounter release];
	[_library release];
	[_parser release];
	[super dealloc];
}

- (void) setData:(NSData *)data
{
	if( _parser )
	{
		[_parser abortParsing];
		[_parser release];
	}
	
	_parser = [[NSXMLParser alloc] initWithData:data];
	_parser.delegate = self;
	_parser.shouldProcessNamespaces = NO;
	_parser.shouldReportNamespacePrefixes = NO;
	_parser.shouldResolveExternalEntities = NO;
}

- (DMParserResult) parse
{
	[_note release];
	[_group release];
	[_unit release];
	[_encounter release];
	[_library release];
	_library = nil;
	_encounter = nil;
	_unit = nil;
	_group = nil;
	_note = nil;
	_rootNode = NO;
	_notesNode = NO;
	_aborted = NO;

	_oldDataFormat = NO;
	[_oldData.group release];
	[_oldData.note release];
	_oldData.group = nil;
	_oldData.note = nil;

	if( [_parser parse] )
		return _oldDataFormat ? DMParserOldFormat : DMParserNewFormat;
	else
		return DMParserFailed;
}

#pragma mark parser for old data format

- (void) oldParserFoundNote:(NSString *)string
{
	if( _unit )
	{
		if( _unit.notes )
			_unit.notes = [_unit.notes stringByAppendingString:string];
		else
			_unit.notes = string;
	}
	else if( _oldData.note )
	{
		if( _oldData.note.notes )
			_oldData.note.notes = [_oldData.note.notes stringByAppendingString:string];
		else
			_oldData.note.notes = string;
	}
}

- (void) oldParserDidStartElement:(NSString *)elementName
		attributes:(NSDictionary *)attributeDict
{
	if( [elementName isEqualToString:@"EncounterEntry"] )
	{
		// create encounter instance
		_encounter = [[DMEncounter alloc] initWithName:[attributeDict objectForKey:@"Name"]];
	}
	else if( [elementName isEqualToString:@"MonsterEntry"] )
	{
		// create a new monster
		UnitEntry *mr = [[UnitEntry alloc] init];
		mr.name = [attributeDict objectForKey:@"Name"];
		mr.player = [[attributeDict objectForKey:@"player"] boolValue];
		mr.HP = [[attributeDict objectForKey:@"hp"] intValue];
		mr.maxHP = mr.HP;
		mr.initiative = 0;
		mr.initMod = [[attributeDict objectForKey:@"init"] intValue];
		mr.notes = @"";
		mr.ac = [[attributeDict objectForKey:@"ac"] intValue];
		mr.fort = [[attributeDict objectForKey:@"fort"] intValue];
		mr.will = [[attributeDict objectForKey:@"will"] intValue];
		mr.reflex = [[attributeDict objectForKey:@"reflex"] intValue];
		mr.hitModifier = [[attributeDict objectForKey:@"hitMod"] intValue];
		mr.acModifier = [[attributeDict objectForKey:@"acMod"] intValue];
		mr.ongoing = [[attributeDict objectForKey:@"ongoing"] intValue];
		mr.stateFlags = [[attributeDict objectForKey:@"states"] intValue];

		_unit = [[DMUnit alloc] initWithUnitEntry:mr];
		[mr release];
	}
	else if( [elementName isEqualToString:@"NoteEntry"] )
	{
		NoteEntry *newnote = [[NoteEntry alloc] init];
		newnote.title = [attributeDict objectForKey:@"Name"];
		newnote.details = [attributeDict objectForKey:@"Details"];
		newnote.group = _oldData.group;
		newnote.notes = @"";
		
		_oldData.note = newnote;
	}
	else if( [elementName isEqualToString:@"NoteGroup"] )
	{
		_oldData.group = [[attributeDict objectForKey:@"Name"] copy];
	}
	else if( [elementName isEqualToString:@"Note"] )
	{
		_notesNode = YES;
	}
}

- (void) oldParserDidEndElement:(NSString *)elementName
{
	DMLibrary* library = [DMDataManager legacyLibrary];
	if( [elementName isEqualToString:@"EncounterEntry"] )
	{
		NSString* encounterName = _encounter.name ? _encounter.name : @"Unnamed";
		NSString* newEncounterName = [NSString stringWithFormat:@"%@ (%@)", encounterName, library.name];
		[DMDataManager saveEncounter:_encounter
							withName:newEncounterName];
		
		[_encounter release];
		_encounter = nil;
	}
	else if( [elementName isEqualToString:@"MonsterEntry"] )
	{
		if( _encounter )
			[_encounter.mutableUnits addObject:_unit];
		else
		{
			// add unit to default lib
			if( _unit.isPlayer )
				[library.mutablePlayers insertSorted:_unit];
			else
				[library.mutableMonsters insertSorted:_unit];
		}
		[_unit release];
		_unit = nil;
	}
	else if( [elementName isEqualToString:@"NoteEntry"] )
	{
		DMToolsAppDelegate* appDelegate = (DMToolsAppDelegate*) [[UIApplication sharedApplication] delegate];
		[appDelegate.notesViewController noteView:nil
										addedNote:_oldData.note];
		[_oldData.note release];
		_oldData.note = nil;
	}
	else if( [elementName isEqualToString:@"NoteGroup"] )
	{
		[_oldData.group release];
		_oldData.group = nil;
	}
	else if( [elementName isEqualToString:@"Note"] )
	{
		_notesNode = NO;
	}
}

#pragma mark parser for new data format

- (void) parseItemWithAttributes:(NSDictionary *)attributeDict
{
	NSAssert(_group, @"group node doesn't exist");

	NSString* itemName = [[attributeDict objectForKey:@"name"] stringByReplacingXMLEscapeChars];
	if( !itemName )
		return;
	id itemObject = nil;
	
	NSString *value = [attributeDict objectForKey:@"value"];
	NSString *display = [attributeDict objectForKey:@"display"];
	switch (_group.type)
	{
		case DMGroupTypeString:
			itemObject = [value stringByReplacingXMLEscapeChars];
			break;
			
		case DMGroupTypeBoolean:
			itemObject = [DMBoolean booleanFromString:value];
			[itemObject setDisplay:( display.integerValue )];
			break;
			
		case DMGroupTypeCounter:
		{
			NSInteger val = [value integerValue];
			val = Clamp( val, -kCounterRange, kCounterRange );
			itemObject = [DMNumber numberWithValue:val];
			[itemObject setDisplay:( display.integerValue )];
			break;
		}
			
		case DMGroupTypeValue:
		case DMGroupTypeValueModifier:
		{
			NSString *modifier = [attributeDict objectForKey:@"modifier"];
			NSInteger val = value.integerValue;
			NSInteger mod = modifier ? modifier.integerValue : 0;
			val = Clamp( val, kValueMinRange, kValueMaxRange );
			mod = Clamp( mod, kModifierMinRange, kModifierMaxRange );
			itemObject = [DMNumber numberWithValue:val
									  withModifier:mod];
			[itemObject setDisplay:( display.integerValue )];
			break;
		}
	}
	
	if (itemObject)
	{
		[_group.keys addObject:itemName];
		[_group.items addObject:itemObject];
	}
}

- (void) parsingUnitElement:(NSString *)elementName
				 attributes:(NSDictionary *)attributeDict
{
	if( _group )
	{
		if( [elementName isEqualToString:@"Item"] )
		{
			[self parseItemWithAttributes:attributeDict];
		}
		else
		{
			NSAssert(0, @"was expecting an Item node");
		}
	}
	else if( _notesNode )
	{
		NSAssert(0, @"Notes node should only contain text");
	}
	else if( [elementName isEqualToString:@"Info"] )
	{
		if( _unit )
			[_unit setInfoFromDictionary:attributeDict];
		else
			[_library.baseTemplate setInfoFromDictionary:attributeDict];
	}
	else if( [elementName isEqualToString:@"Group"] )
	{
		_group = [[DMGroup alloc] initWithDictionary:attributeDict];
	}
	else if( [elementName isEqualToString:@"Notes"] )
	{
		_notesNode = YES;
	}
	else
	{
		NSAssert(0, @"was expecting an Group, Display or Notes node");
	}
}

- (void) parserFoundNote:(NSString *)string
{
	if( _unit )
	{
		if( _unit.notes )
			_unit.notes = [_unit.notes stringByAppendingString:[string stringByReplacingXMLEscapeChars]];
		else
			_unit.notes = [string stringByReplacingXMLEscapeChars];
	}
	else if( _library )
	{
		if( _library.baseTemplate.notes )
			_library.baseTemplate.notes = [_library.baseTemplate.notes stringByAppendingString:[string stringByReplacingXMLEscapeChars]];
		else
			_library.baseTemplate.notes = [string stringByReplacingXMLEscapeChars];
	}
}

- (void) parserDidStartElement:(NSString *)elementName
	 attributes:(NSDictionary *)attributeDict
{
	if( [elementName isEqualToString:@"Library"] )
	{
		NSString* libraryName = [[attributeDict objectForKey:@"name"] stringByReplacingXMLEscapeChars];
		_library = [[DMLibrary alloc] initWithName:libraryName];
		_converted = NO;
	}
	else if( [elementName isEqualToString:@"Encounter"] )
	{
		NSString* encounterName = [[attributeDict objectForKey:@"name"] stringByReplacingXMLEscapeChars];
		_encounter = [[DMEncounter alloc] initWithName:encounterName];
	}
	else if( [elementName isEqualToString:@"Unit"] )
	{
		NSString* unitName = [[attributeDict objectForKey:@"name"] stringByReplacingXMLEscapeChars];
		_unit = [[DMUnit alloc] initWithName:unitName];
	}
	else if( [elementName isEqualToString:@"Note"] )
	{
		// TODO
	}
	else if( _library || _unit )
	{
		[self parsingUnitElement:elementName
					  attributes:attributeDict];
	}
}

- (void) parserDidEndElement:(NSString *)elementName
{
	if( [elementName isEqualToString:@"Library"] )
	{
		if( _delegate
		   && [_delegate respondsToSelector:@selector(parser:parsedLibrary:)] )
		{
			if( !_converted )
			{
				// clear all dirty states since we don't do any actual conversion here
				// just loading stuff from file. 
				[_library clearDirtyStates];
			}
			_converted = NO;
			[_delegate parser:self
				parsedLibrary:_library];
		}
		[_library release];
		_library = nil;
	}
	else if( [elementName isEqualToString:@"Encounter"] )
	{
		if( _library )
		{
			// this is an old format of the library so we need to save the encounter in the saved sessions list
			NSString* encounterName = _encounter.name ? _encounter.name : @"Unnamed";
			NSString* newEncounterName = [NSString stringWithFormat:@"%@ (%@)", encounterName, _library.name];
			[DMDataManager saveEncounter:_encounter
								withName:newEncounterName];
			_converted = YES;
		}
		else
		{
			if( _delegate
			   && [_delegate respondsToSelector:@selector(parser:parsedEncounter:)] )
			{
				[_encounter clearDirtyStates];
				[_delegate parser:self
				  parsedEncounter:_encounter];
			}
		}
		[_encounter release];
		_encounter = nil;
	}
	else if( [elementName isEqualToString:@"Unit"] )
	{
		if( _encounter )
			[_encounter.mutableUnits addObject:_unit];
		else if( _library )
		{
			if( _unit.isPlayer )
				[_library.mutablePlayers insertSorted:_unit];
			else
				[_library.mutableMonsters insertSorted:_unit];
		}
		else
		{
			if( _delegate
			   && [_delegate respondsToSelector:@selector(parser:parsedLibrary:)] )
			{
				DMLibrary* library = [[DMLibrary alloc] initWithTemplate:_unit];
				[_delegate parser:self
					parsedLibrary:library];
				[library release];
			}
		}
		[_unit release];
		_unit = nil;
	}
	else if( [elementName isEqualToString:@"Group"] )
	{
		if( _unit )
			[_unit.mutableGroups addObject:_group];
		else if( _library )
			[_library.baseTemplate.mutableGroups addObject:_group];
		[_group release];
		_group = nil;
	}
	else if( [elementName isEqualToString:@"Notes"] )
	{
		_notesNode = NO;
	}
	else if( [elementName isEqualToString:@"Note"] )
	{
		if( _delegate
		   && [_delegate respondsToSelector:@selector(parser:parsedNote:)] )
		{
			[_delegate parser:self
				   parsedNote:_note];
		}
		[_note release];
		_note = nil;
	}
}
#pragma mark NSXMLParserDelegate functions

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if( _notesNode )
	{
		if( _oldDataFormat )
			[self oldParserFoundNote:string];
		else
			[self parserFoundNote:string];
	}
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
	 attributes:(NSDictionary *)attributeDict
{
	NSAssert(_parser == parser, @"parser pointer doesn't match");
	if (_aborted)
		return;
	
	if( _rootNode )
	{
		if(	_oldDataFormat )
			[self oldParserDidStartElement:elementName
								attributes:attributeDict];
		else
			[self parserDidStartElement:elementName
							 attributes:attributeDict];
	}
	else if( [elementName isEqualToString:@"DMToolsData"] )
	{
		_oldDataFormat = NO;
		_rootNode = YES;
	}
	else if( [elementName isEqualToString:@"DMToolData"] )
	{
		_oldDataFormat = YES;
		_rootNode = YES;
	}
	else
	{
		NSAssert(0, @"invalid node");
	}
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
	if( _aborted )
		return;
	
	if( [elementName isEqualToString:@"DMToolsData"]
		|| [elementName isEqualToString:@"DMToolData"] )
	{
		_rootNode = NO;
	}
	else
	{
		if( _oldDataFormat )
			[self oldParserDidEndElement:elementName];
		else
			[self parserDidEndElement:elementName];
	}
}

- (void) parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"Error %d, Description: %@, %@, Line: %i, Column: %i",
		  [parseError code],
		  [parseError localizedDescription],
		  [[parser parserError] localizedDescription],
		  [parser lineNumber],
		  [parser columnNumber]);
	
	if( _delegate
		&& [_delegate respondsToSelector:@selector(parser:parseErrorOccurred:)] )
	{
		[_delegate parser:self
	   parseErrorOccurred:parseError];
	}
}

@end
