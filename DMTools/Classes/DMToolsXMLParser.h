//
//  DMToolsXMLParserOld.h
//  DM Tools
//
//  Created by hamouras on 09/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMLibrary;
@class DMEncounter;
@class DMUnit;
@class DMNote;
@protocol DMToolsXMLParserDelegate;

typedef enum DMParserResult
{
	DMParserOldFormat = -1,
	DMParserFailed = 0,
	DMParserNewFormat = 1
} DMParserResult;

@interface DMToolsXMLParser : NSObject<NSXMLParserDelegate>

@property (nonatomic, assign) id<DMToolsXMLParserDelegate> delegate;

- (id) initWithURL:(NSURL *)URL;
- (id) initWithData:(NSData *)data;
- (void) setData:(NSData *)data;
- (DMParserResult) parse;

@end

@protocol DMToolsXMLParserDelegate <NSObject>

@optional
- (void) parser:(DMToolsXMLParser *)parser parsedLibrary:(DMLibrary *)library;
- (void) parser:(DMToolsXMLParser *)parser parsedEncounter:(DMEncounter *)encounter;
- (void) parser:(DMToolsXMLParser *)parser parsedNote:(DMNote *)note;
- (void) parser:(DMToolsXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

@end
