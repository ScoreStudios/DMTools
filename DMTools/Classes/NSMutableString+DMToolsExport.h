//
//  NSMutableString+DMToolsExport.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/15/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMUnit;
@class DMEncounter;
@class DMLibrary;

@interface NSMutableString (DMToolsExport)

- (void) appendUnit:(DMUnit*)unit atLevel:(NSUInteger)level;
- (void) appendEncounter:(DMEncounter*)encounter atLevel:(NSUInteger)level;
- (void) appendLibrary:(DMLibrary*)library atLevel:(NSUInteger)level;
- (void) appendDMToolsHeader;
- (void) appendDMToolsFooter;

@end
