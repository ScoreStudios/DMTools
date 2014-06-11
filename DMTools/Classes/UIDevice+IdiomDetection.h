//
//  UIDevice+IdiomDetection.h
//  DM Tools
//
//  Created by hamouras on 05/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIDevice(IdiomDetection)
- (BOOL) isIPad;
- (BOOL) isIPhone;

#ifndef MASTER
- (BOOL) hasDebuggerAttached;
#endif
@end
