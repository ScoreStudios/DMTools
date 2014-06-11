//
//  NSString+XMLConvert.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/30/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XMLConvert)

- (NSString*) stringByAddingXMLEscapeChars;
- (NSString*) stringByReplacingXMLEscapeChars;

@end
