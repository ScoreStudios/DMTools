//
//  NSMutableString+DMToolsExport.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/15/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "NSMutableString+DMToolsExport.h"
#import "DMNumber.h"
#import "DMUnit.h"
#import "DMEncounter.h"
#import "DMLibrary.h"

@implementation NSMutableString (DMToolsExport)

- (void) appendUnitInfo:(DMUnit*)unit atLevel:(NSUInteger)level
{
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	[self appendFormat:
	 @"%@<Info name=\"%@\" player=\"%@\" avatar=\"%@\" race=\"%@\" class=\"%@\" level=\"%d\" HP=\"%@\" initiative=\"%@\"/>\n",
	 tab,
	 [unit.name stringByAddingXMLEscapeChars],
	 unit.player ? @"true" : @"false",
	 [unit.avatarName stringByAddingXMLEscapeChars],
	 [unit.race stringByAddingXMLEscapeChars],
	 [unit.charClass stringByAddingXMLEscapeChars],
	 (int)unit.level,
	 [unit.HP toShortString],
	 [unit.initiative toShortString]];
}

- (void) appendUnitGroups:(DMUnit*)unit atLevel:(NSUInteger)level
{
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	for (DMGroup *group in unit.groups)
	{
		[self appendFormat:
		 @"%@<Group name=\"%@\"",
		 tab,
		 [group.name stringByAddingXMLEscapeChars]];
		
		const NSUInteger itemsCount = group.keys.count;
		switch (group.type)
		{
			case DMGroupTypeString:
			{
				[self appendString:@" type=\"string\">\n"];
				
				for (NSUInteger i = 0 ; i < itemsCount ; ++i)
				{
					NSString *key = [group.keys objectAtIndex:i];
					NSString *value = [group.items objectAtIndex:i];
					[self appendFormat:@"%@\t<Item name=\"%@\" value=\"%@\"/>\n",
					 tab,
					 [key stringByAddingXMLEscapeChars],
					 [value stringByAddingXMLEscapeChars]];
				}
				break;
			}
			case DMGroupTypeBoolean:
			{
				[self appendString:@" type=\"boolean\">\n"];
				
				for (NSUInteger i = 0 ; i < itemsCount ; ++i)
				{
					NSString *key = [group.keys objectAtIndex:i];
					DMBoolean *boolean = [group.items objectAtIndex:i];
					[self appendFormat:@"%@\t<Item name=\"%@\" value=\"%@\"",
					 tab,
					 [key stringByAddingXMLEscapeChars],
					 boolean.value ? @"true" : @"false"];
					if( boolean.display )
						[self appendFormat:@" display=\"%d\"/>\n",
						 (int)boolean.display];
					else
						[self appendString:@"/>\n"];
				}
				break;
			}
			case DMGroupTypeCounter:
			{
				[self appendString:@" type=\"counter\">\n"];
				
				for (NSUInteger i = 0 ; i < itemsCount ; ++i)
				{
					NSString *key = [group.keys objectAtIndex:i];
					DMNumber *number = [group.items objectAtIndex:i];
					[self appendFormat:@"%@\t<Item name=\"%@\" value=\"%d\"",
					 tab,
					 [key stringByAddingXMLEscapeChars],
					 (int)number.value];
					if( number.display )
						[self appendFormat:@" display=\"%d\"/>\n",
						 (int)number.display];
					else
						[self appendString:@"/>\n"];
				}
				break;
			}
			case DMGroupTypeValue:
			case DMGroupTypeValueModifier:
			{
				if( group.type == DMGroupTypeValue )
					[self appendString:@" type=\"value\">\n"];
				else
					[self appendString:@" type=\"value:modifier\">\n"];
				
				for (NSUInteger i = 0 ; i < itemsCount ; ++i)
				{
					NSString *key = [group.keys objectAtIndex:i];
					DMNumber *number = [group.items objectAtIndex:i];
					[self appendFormat:@"%@\t<Item name=\"%@\" value=\"%d\" modifier=\"%d\"",
					 tab,
					 [key stringByAddingXMLEscapeChars],
					 (int)number.value,
					 (int)number.modifier];
					if( number.display )
						[self appendFormat:@" display=\"%d\"/>\n",
						 (int)number.display];
					else
						[self appendString:@"/>\n"];
				}
				break;
			}
		}
		
		[self appendFormat:@"%@</Group>\n",
		 tab];
	}
}

- (void) appendUnitNotes:(DMUnit*)unit atLevel:(NSUInteger)level
{
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	[self appendFormat:@"%@<Notes>%@</Notes>\n",
	 tab,
	 [unit.notes stringByAddingXMLEscapeChars]];
}

- (void) appendUnit:(DMUnit*)unit atLevel:(NSUInteger)level
{
	const NSUInteger childrenLevel = level + 1;
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	[self appendFormat:
	 @"%@<Unit name=\"%@\">\n",
	 tab,
	 [unit.name stringByAddingXMLEscapeChars]];
	
	[self appendUnitInfo:unit
				 atLevel:childrenLevel];
	[self appendUnitGroups:unit
				   atLevel:childrenLevel];
	[self appendUnitNotes:unit
				  atLevel:childrenLevel];
	
	[self appendFormat:@"%@</Unit>\n",
	 tab];
}

- (void) appendEncounter:(DMEncounter*)encounter atLevel:(NSUInteger)level
{
	const NSUInteger childrenLevel = level + 1;
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	[self appendFormat:@"%@<Encounter name=\"%@\">\n",
	 tab,
	 [encounter.name stringByAddingXMLEscapeChars]];
	
	for( DMUnit* unit in encounter.units )
	{
		[self appendUnit:unit
				 atLevel:childrenLevel];
	}
	
	[self appendFormat:@"%@</Encounter>\n",
	 tab];
}

- (void) appendLibrary:(DMLibrary*)library atLevel:(NSUInteger)level
{
	const NSUInteger childrenLevel = level + 1;
	NSString* tab = @"\t";
	while( level-- )
		tab = [tab stringByAppendingString:@"\t"];
	
	[self appendFormat:@"%@<Library name=\"%@\">\n",
	 tab,
	 [library.name stringByAddingXMLEscapeChars]];
	
	[self appendUnitInfo:library.baseTemplate
				 atLevel:childrenLevel];
	[self appendUnitGroups:library.baseTemplate
				   atLevel:childrenLevel];
	[self appendUnitNotes:library.baseTemplate
				  atLevel:childrenLevel];

	for( DMUnit* unit in library.players )
	{
		[self appendUnit:unit
				 atLevel:childrenLevel];
	}
	for( DMUnit* unit in library.monsters )
	{
		[self appendUnit:unit
				 atLevel:childrenLevel];
	}
	
	[self appendFormat:@"%@</Library>\n",
	 tab];
}

- (void) appendDMToolsHeader
{
	[self appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
	[self appendString:
	 @"<DMToolsData xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n"];
}

- (void) appendDMToolsFooter
{
	[self appendString:@"</DMToolsData>\n"];
}

@end
