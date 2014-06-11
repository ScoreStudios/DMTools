//
//  NSMutableArray+InstertSorted.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 4/16/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (InstertSorted)
- (NSUInteger) insertSorted:(id)object;
- (NSUInteger) insertSorted:(id)object usingSelector:(SEL)selector;
@end
