//
//  NSString+XMLConvert.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/30/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "NSString+XMLConvert.h"

@implementation NSString (XMLConvert)

- (NSString*) stringByAddingXMLEscapeChars
{
	NSString* result = [self stringByReplacingOccurrencesOfString:@"&"
													   withString:@"&amp;"];
	result = [result stringByReplacingOccurrencesOfString:@"<"
											   withString:@"&lt;"];
	result = [result stringByReplacingOccurrencesOfString:@">"
											   withString:@"&gt;"];
	result = [result stringByReplacingOccurrencesOfString:@"\""
											   withString:@"&quot;"];
	return result;
}

- (NSString*) stringByReplacingXMLEscapeChars
{
	NSString* result = [self stringByReplacingOccurrencesOfString:@"&amp;"
													   withString:@"&"];
	result = [result stringByReplacingOccurrencesOfString:@"&lt;"
											   withString:@"<"];
	result = [result stringByReplacingOccurrencesOfString:@"&gt;"
											   withString:@">"];
	result = [result stringByReplacingOccurrencesOfString:@"&quot;"
											   withString:@"\""];
	return result;
}

@end
